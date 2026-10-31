"""Negative controls: missing coverage or broken hosting must fail before a green run."""
import copy
from pathlib import Path
import unittest
from device_host import load_project, validate


class DeviceHostContracts(unittest.TestCase):
    def test_manual_group_cycle_is_rejected_before_xcode(self):
        from prepare_manual_host import validate_groups
        objects = {'root': {'isa': 'PBXGroup', 'children': ['source']},
                   'source': {'isa': 'PBXFileReference'}}
        validate_groups(objects, 'root')
        objects['root']['children'] = ['root']
        with self.assertRaisesRegex(RuntimeError, 'group cycle'):
            validate_groups(objects, 'root')

    @classmethod
    def setUpClass(cls):
        cls.root = Path(__file__).resolve().parents[2]
        cls.project = load_project(cls.root)

    def test_current_host_uses_all_shared_sources(self):
        validate(self.root, self.project)

    def test_omitted_test_file_fails(self):
        project = copy.deepcopy(self.project)
        objects = project["objects"]
        target = next(o for o in objects.values() if o.get("name") == "NetworkKitDeviceTests")
        phase = next(objects[p] for p in target["buildPhases"] if objects[p]["isa"] == "PBXSourcesBuildPhase")
        phase["files"].pop()
        with self.assertRaisesRegex(RuntimeError, "omits or duplicates"):
            validate(self.root, project)

    def test_omitted_optional_native_source_fails(self):
        project = copy.deepcopy(self.project)
        objects = project["objects"]
        target = next(o for o in objects.values() if o.get("name") == "NetworkKitPublicHTTPSChecks")
        phase = next(objects[p] for p in target["buildPhases"] if objects[p]["isa"] == "PBXSourcesBuildPhase")
        phase["files"].pop()
        with self.assertRaisesRegex(RuntimeError, "omits or duplicates"):
            validate(self.root, project)

    def test_tool_host_substitution_fails(self):
        project = copy.deepcopy(self.project)
        for o in project["objects"].values():
            if "TEST_HOST" in o.get("buildSettings", {}):
                o["buildSettings"]["TEST_HOST"] = "xctest"
        with self.assertRaisesRegex(RuntimeError, "not app-hosted"):
            validate(self.root, project)

    def test_remote_package_substitution_fails(self):
        project = copy.deepcopy(self.project)
        package = next(o for o in project["objects"].values() if o["isa"] == "XCLocalSwiftPackageReference")
        package["isa"] = "XCRemoteSwiftPackageReference"
        with self.assertRaisesRegex(RuntimeError, "local package only"):
            validate(self.root, project)

    def test_committed_profile_identifier_fails(self):
        project = copy.deepcopy(self.project)
        settings = next(o["buildSettings"] for o in project["objects"].values()
                        if "PROVISIONING_PROFILE_SPECIFIER" in o.get("buildSettings", {}))
        settings["PROVISIONING_PROFILE_SPECIFIER"] = "private-profile-must-not-be-committed"
        with self.assertRaisesRegex(RuntimeError, "Private signing"):
            validate(self.root, project)
