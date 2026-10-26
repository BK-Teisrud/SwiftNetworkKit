import Foundation
import Testing
@testable import NetworkKit

@Suite struct PrivacyManifestTests {
    @Test func bundledManifestMatchesReviewedSDKPractices() throws {
        let url = try #require(Bundle.module.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        let manifest = try #require(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
        #expect(Set(manifest.keys) == ["NSPrivacyTracking", "NSPrivacyTrackingDomains",
            "NSPrivacyCollectedDataTypes", "NSPrivacyAccessedAPITypes"])
        #expect((manifest["NSPrivacyTracking"] as? Bool) == false)
        for key in ["NSPrivacyTrackingDomains", "NSPrivacyCollectedDataTypes", "NSPrivacyAccessedAPITypes"] {
            let entries = try #require(manifest[key] as? [Any])
            #expect(entries.isEmpty)
        }
    }
}
