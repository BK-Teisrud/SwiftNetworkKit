#!/usr/bin/env python3
"""Opt-in macOS runtime allocation control. Does not import or exercise NetworkKit.
Profiles only an owned child. Keeps raw heap/address/stack logs in temporary storage;
exports sanitized counts, tool identities and source hash. No fixed RSS timing gate.
"""
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import select
import subprocess
import tempfile


def command(*args, **kwargs):
    result = subprocess.run(args, text=True, capture_output=True, timeout=kwargs.pop("timeout", 30), **kwargs)
    if result.returncode:
        raise RuntimeError(f"Command failed: {args[0]}\n{result.stdout}\n{result.stderr}")
    return result.stdout.strip()


def phase(process, expected):
    if not select.select([process.stdout], [], [], 30)[0]:
        raise RuntimeError("Timed out waiting for owned control phase")
    result = json.loads(process.stdout.readline())
    if result != {"phase": expected, "cancellations": 6400}:
        raise RuntimeError(f"Unexpected control result: {result}")
    return result


def heap(process):
    text = command("/usr/bin/heap", "-s", str(process.pid), timeout=10)
    totals = re.search(r"All zones: (\d+) nodes \((\d+) bytes\)", text)
    tasks = re.findall(r"^\s*(\d+)\s+(\d+)\s+[\d.]+\s+Task stack\s+Swift", text, re.M)
    if not totals or not tasks:
        raise RuntimeError("Missing heap allocation/type evidence; no silent profiler skip")
    return {"live_nodes": int(totals[1]), "live_malloc_bytes": int(totals[2]),
            "task_stack_nodes": sum(int(t[0]) for t in tasks),
            "task_stack_bytes": sum(int(t[1]) for t in tasks)}


def run(output):
    if platform.system() != "Darwin":
        raise SystemExit("This opt-in allocation control requires macOS.")
    source = Path(__file__).with_name("SleepRetentionProbe.swift")
    results = []
    with tempfile.TemporaryDirectory(prefix="networkkit-sleep-control-") as folder:
        binary = str(Path(folder) / "SleepRetentionProbe")
        command("swiftc", "-parse-as-library", "-O", "-swift-version", "6", "-warnings-as-errors",
                str(source), "-o", binary, timeout=120)
        for mode in ["clock", "nanos"]:
            with open(Path(folder) / "runtime.log", "w") as log:
                process = subprocess.Popen([binary, mode], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                           stderr=log, text=True, env=dict(os.environ, MallocStackLogging="1"))
                try:
                    phase(process, "joined")
                    joined = heap(process)
                    phase(process, "expired")
                    expired = heap(process)
                    process.stdin.write("exit\n")
                    process.stdin.flush()
                    process.wait(timeout=5)
                    if process.returncode:
                        raise RuntimeError("Owned control process failed")
                    results.append({"mode": mode, "cancelled_and_joined": 6400,
                                    "sleep_seconds": 10, "post_join_wait_seconds": 12,
                                    "joined": joined, "expired": expired})
                    print(f"Completed {mode} allocation control", flush=True)
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.wait(timeout=5)
                    process.stdin.close()
                    process.stdout.close()
    data = {"environment": {"os": command("sw_vers"), "architecture": platform.machine(),
                            "xcode": command("xcodebuild", "-version"),
                            "swift": command("xcrun", "swift", "--version"),
                            "probe_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                            "runner_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                            "malloc_stack_logging": True}, "results": results}
    output.write_text(json.dumps(data, indent=2) + "\n")
    print(f"Wrote {output}", flush=True)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    run(parser.parse_args().output)
