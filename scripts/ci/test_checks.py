"""Regression tests for fail-closed CI infrastructure, not product behavior."""
import unittest
from check import select_device, validate_summary


class CheckContracts(unittest.TestCase):
    def test_missing_runtime_and_unavailable_device_fail(self):
        for devices in [{}, {"runtime": [{"name": "iPhone 17", "udid": "x", "isAvailable": False}]}]:
            with self.assertRaises(RuntimeError):
                select_device(devices, "runtime", "iPhone")

    def test_selected_device_is_available_and_exact_runtime(self):
        devices = {"old": [{"name": "iPhone 17", "udid": "old", "isAvailable": True}],
                   "runtime": [{"name": "iPad", "udid": "pad", "isAvailable": True},
                               {"name": "iPhone 17", "udid": "phone", "isAvailable": True}]}
        self.assertEqual(select_device(devices, "runtime", "iPhone")["udid"], "phone")

    def test_empty_failed_and_skipped_runs_fail(self):
        good = dict(result="Passed", totalTestCount=2, passedTests=2, failedTests=0, skippedTests=0, expectedFailures=0)
        validate_summary(good)
        for change in [dict(totalTestCount=0, passedTests=0), dict(result="Failed"), dict(failedTests=1),
                       dict(skippedTests=1), dict(expectedFailures=1), dict(passedTests=1)]:
            with self.assertRaises(RuntimeError):
                validate_summary(dict(good, **change))


if __name__ == "__main__":
    unittest.main()
