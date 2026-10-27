"""The offline witness must not classify missing evidence/generic failures as hostname proof."""
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch


class PublicHTTPSWitnessContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        root = Path(__file__).resolve().parents[2]
        spec = importlib.util.spec_from_file_location("public_witness", root / "Tools/PublicHTTPSChecks/certificate_witness.py")
        cls.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.module)

    def test_empty_handshake_cannot_be_a_matching_leaf_witness(self):
        result = SimpleNamespace(returncode=0, stdout=b"", stderr=b"")
        with patch.object(self.module, "command", return_value=result):
            self.assertFalse(self.module.witness()["independent_hostname_witness_complete"])

    def test_generic_policy_failure_is_not_hostname_mismatch(self):
        def fake(args, **options):
            if "s_client" in args:
                return SimpleNamespace(returncode=0, stdout=b"-----BEGIN CERTIFICATE-----\nfixture\n-----END CERTIFICATE-----", stderr=b"")
            if "x509" in args:
                return SimpleNamespace(returncode=0, stdout=b"same-public-leaf", stderr=b"")
            failed = "sha256.badssl.com" not in args
            return SimpleNamespace(returncode=1 if failed else 0, stdout=b"Generic policy failure" if failed else b"", stderr=b"")
        with patch.object(self.module, "command", side_effect=fake):
            self.assertFalse(self.module.witness()["independent_hostname_witness_complete"])
