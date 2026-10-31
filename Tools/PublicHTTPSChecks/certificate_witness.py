#!/usr/bin/env python3
"""Opt-in public certificate metadata capture and Apple SSL-policy witness; no HTTP payload."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile


def command(args, **options):
    return subprocess.run(args, capture_output=True, timeout=20, **options)


def witness():
    records = {}
    with tempfile.TemporaryDirectory(prefix="networkkit-public-cert-") as folder:
        for host in ["sha256.badssl.com", "wrong.host.badssl.com", "self-signed.badssl.com"]:
            result = command(["/usr/bin/openssl", "s_client", "-connect", host + ":443",
                              "-servername", host, "-showcerts"], input=b"")
            certs = re.findall(b"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", result.stdout, re.S)
            if not certs:
                records[host] = {"chain_capture_available": False}
                continue
            paths = []
            for index, certificate in enumerate(certs):
                path = Path(folder) / (host + "-" + str(index) + ".pem")
                path.write_bytes(certificate)
                paths.append(path)
            leaf = command(["/usr/bin/openssl", "x509", "-in", str(paths[0]), "-outform", "DER"])
            if leaf.returncode:
                raise RuntimeError("Public leaf decoding failed")
            args = ["security", "verify-cert", "-p", "ssl", "-L", "-n", host]
            for path in paths:
                args.extend(["-c", str(path)])
            policy = command(args)
            record = {"chain_capture_available": True, "leaf_sha256": hashlib.sha256(leaf.stdout).hexdigest(),
                      "chain_length": len(paths), "apple_ssl_policy_exit": policy.returncode}
            if host == "wrong.host.badssl.com":
                record["hostname_mismatch_reported"] = b"Host name mismatch" in policy.stdout + policy.stderr
                args[args.index(host)] = "sha256.badssl.com"
                record["same_captured_chain_matching_hostname_exit"] = command(args).returncode
            records[host] = record
    valid = records.get("sha256.badssl.com", {})
    wrong = records.get("wrong.host.badssl.com", {})
    untrusted = records.get("self-signed.badssl.com", {})
    complete = (valid.get("apple_ssl_policy_exit") == 0 and bool(valid.get("leaf_sha256"))
                and valid.get("leaf_sha256") == wrong.get("leaf_sha256")
                and wrong.get("hostname_mismatch_reported") is True
                and wrong.get("same_captured_chain_matching_hostname_exit") == 0
                and untrusted.get("apple_ssl_policy_exit") not in (None, 0))
    return {"method": "Public certificate capture without HTTP payload; local Apple SSL-policy evaluation. No client trust/root changes.",
            "independent_hostname_witness_complete": complete, "hosts": records}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = witness()
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print("Public certificate witness complete:", result["independent_hostname_witness_complete"])
    raise SystemExit(0 if result["independent_hostname_witness_complete"] else 1)
