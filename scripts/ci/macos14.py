#!/usr/bin/env python3
"""Opt-in prebuilt public-consumer verification; never builds with an older Swift."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def command(*args, timeout=300):
    return subprocess.check_output([str(x) for x in args], cwd=ROOT, text=True, timeout=timeout).strip()


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sources():
    paths = [ROOT / 'Package.swift', ROOT / 'scripts/benchmarks/Probe.swift',
             ROOT / 'scripts/benchmarks/run.py', ROOT / 'scripts/ci/macos14.py']
    paths += sorted(p for p in (ROOT / 'Sources').rglob('*') if p.is_file())
    return {str(p.relative_to(ROOT)): digest(p) for p in paths}


def verify_payload(folder):
    manifest = json.loads((folder / 'manifest.json').read_text())
    if manifest['source_commit'] != command('git', 'rev-parse', 'HEAD') or manifest['source_hashes'] != sources():
        raise ValueError('Prebuilt consumer does not match the exact checked-out source')
    if manifest['target'] != 'arm64-apple-macosx14.0':
        raise ValueError('Unexpected consumer deployment target')
    if not manifest['files'] or 'ResourceProbe' not in manifest['files']:
        raise ValueError('Missing consumer')
    actual = {str(p.relative_to(folder)) for p in folder.rglob('*') if p.is_file() and p.name != 'manifest.json'}
    if actual != set(manifest['files']):
        raise ValueError('Missing or unexpected payload files')
    for name, expected in manifest['files'].items():
        path = folder / name
        if Path(name).is_absolute() or '..' in Path(name).parts or path.is_symlink() or digest(path) != expected:
            raise ValueError('Invalid payload path or checksum')
    return manifest


def build(folder):
    if datetime.now(timezone.utc).date().isoformat() >= "2026-11-02":
        raise RuntimeError("The temporary GitHub macOS 14 route has reached its retirement date")
    version = command('xcodebuild', '-version')
    if version != 'Xcode 26.3\nBuild version 17C529' or 'Swift version 6.2.4' not in command('xcrun', 'swift', '--version'):
        raise RuntimeError('Approved builder toolchain missing')
    folder.mkdir(parents=True, exist_ok=False)
    with tempfile.TemporaryDirectory(prefix='networkkit-macos14-build-') as temporary:
        package = Path(temporary)
        target = package / 'Sources/ResourceProbe'
        target.mkdir(parents=True)
        shutil.copy2(ROOT / 'scripts/benchmarks/Probe.swift', target / 'Probe.swift')
        (package / 'Package.swift').write_text('''// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "ResourceProbe", platforms: [.macOS(.v14)],
 dependencies: [.package(path: %s)], targets: [.executableTarget(name: "ResourceProbe",
 dependencies: [.product(name: "NetworkKit", package: "SwiftNetworkKit")])], swiftLanguageModes: [.v6])
''' % json.dumps(str(ROOT)))
        args = ['swift', 'build', '--package-path', package, '-c', 'release', '--triple', 'arm64-apple-macosx14.0']
        command(*args, '-Xswiftc', '-warnings-as-errors')
        products = Path(command(*args, '--show-bin-path'))
        shutil.copy2(products / 'ResourceProbe', folder / 'ResourceProbe')
        for bundle in products.glob('*.bundle'):
            shutil.copytree(bundle, folder / bundle.name)
    binary = folder / 'ResourceProbe'
    if 'arm64' not in command('lipo', '-archs', binary):
        raise RuntimeError('Missing ARM64 consumer slice')
    load = command('vtool', '-show-build', binary)
    if 'minos 14.0' not in load:
        raise RuntimeError('Consumer does not declare macOS 14.0 minimum')
    files = {str(p.relative_to(folder)): digest(p) for p in folder.rglob('*') if p.is_file()}
    if sum(p.stat().st_size for p in folder.rglob('*') if p.is_file()) > 20 * 1024 * 1024:
        raise RuntimeError('Unexpectedly large transfer payload')
    manifest = {'source_commit': command('git', 'rev-parse', 'HEAD'), 'source_hashes': sources(),
                'target': 'arm64-apple-macosx14.0', 'builder_xcode': version,
                'builder_swift': command('xcrun', 'swift', '--version'),
                'builder_os': command('sw_vers'), 'builder_architecture': platform.machine(),
                'sdk': command('xcrun', '--sdk', 'macosx', '--show-sdk-version'), 'files': files}
    (folder / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    verify_payload(folder)
    print('Built and verified exact-source ARM64/macOS 14.0 consumer; no test framework or toolchain is transferred.')


def run(folder, output):
    if platform.system() != 'Darwin' or platform.mac_ver()[0].split('.')[0] != '14' or platform.machine() != 'arm64':
        raise RuntimeError('Actual ARM64 macOS 14 execution host required')
    manifest = verify_payload(folder)
    output.mkdir(parents=True, exist_ok=False)
    for name, flags in [('smoke', ['--smoke']), ('post-budget', ['--post-budget', '--cycles', '100'])]:
        command('python3', ROOT / 'scripts/benchmarks/run.py', '--executable', folder / 'ResourceProbe',
                '--output', output / (name + '.json'), '--repetitions', '1', *flags, timeout=300)
    record = {'manifest': manifest, 'execution_os': command('sw_vers'),
              'execution_architecture': platform.machine(), 'results': {
                  name: json.loads((output / (name + '.json')).read_text())
                  for name in ['smoke', 'post-budget']},
              'limits': ['Not the 218-test regression suite or HTTPS/TLS evidence.',
                         'Actual macOS 14 patch/build is recorded; no claim of macOS 14.0 execution.',
                         'No universal memory cap or owner release-risk acceptance.']}
    (output / 'evidence.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['build', 'run'])
    parser.add_argument('--payload', type=Path, required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    if args.mode == 'build':
        build(args.payload.resolve())
    else:
        if args.output is None:
            parser.error('run requires --output')
        run(args.payload.resolve(), args.output.resolve())
