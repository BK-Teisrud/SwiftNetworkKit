import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import macos14


class PrebuiltConsumerContracts(unittest.TestCase):
    def payload(self, folder):
        (folder / 'ResourceProbe').write_bytes(b'synthetic executable control')
        manifest = {'source_commit': 'a' * 40, 'source_hashes': {'source': 'reviewed'},
                    'target': 'arm64-apple-macosx14.0',
                    'files': {'ResourceProbe': hashlib.sha256((folder / 'ResourceProbe').read_bytes()).hexdigest()}}
        (folder / 'manifest.json').write_text(json.dumps(manifest))
        return manifest

    def test_tampered_executable_or_wrong_commit_cannot_pass_provenance(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            with patch.object(macos14, 'command', return_value='a' * 40), patch.object(macos14, 'sources', return_value={'source': 'reviewed'}):
                self.payload(folder)
                macos14.verify_payload(folder)
                (folder / 'ResourceProbe').write_bytes(b'tampered executable')
                with self.assertRaises(ValueError):
                    macos14.verify_payload(folder)
                manifest = self.payload(folder)
                manifest['source_commit'] = 'b' * 40
                (folder / 'manifest.json').write_text(json.dumps(manifest))
                with self.assertRaises(ValueError):
                    macos14.verify_payload(folder)

    def test_unexpected_payload_file_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            self.payload(folder)
            (folder / 'unexpected').write_bytes(b'not reviewed')
            with patch.object(macos14, 'command', return_value='a' * 40), patch.object(macos14, 'sources', return_value={'source': 'reviewed'}):
                with self.assertRaises(ValueError):
                    macos14.verify_payload(folder)

    def test_wrong_os_never_starts_a_probe(self):
        with patch.object(macos14.platform, 'system', return_value='Darwin'), patch.object(macos14.platform, 'mac_ver', return_value=('15.8.1', (), '')), patch.object(macos14, 'command') as command:
            with self.assertRaises(RuntimeError):
                macos14.run(Path('/unused'), Path('/unused'))
            command.assert_not_called()

    def test_wrong_architecture_never_starts_a_probe(self):
        with patch.object(macos14.platform, 'system', return_value='Darwin'), patch.object(macos14.platform, 'mac_ver', return_value=('14.8.9', (), '')), patch.object(macos14.platform, 'machine', return_value='x86_64'), patch.object(macos14, 'command') as command:
            with self.assertRaises(RuntimeError):
                macos14.run(Path('/unused'), Path('/unused'))
            command.assert_not_called()
