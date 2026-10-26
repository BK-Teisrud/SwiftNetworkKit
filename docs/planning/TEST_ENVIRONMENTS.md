# Test environments and evidence plan

Current preparation: [PREP-01 environment readiness, 2026-10-26](ENVIRONMENT_READINESS.md). The inventory was rechecked with unchanged listed runtimes; exact physical devices and older-environment access remain unknown. This page preserves the initial inventory.

Inventory inspected 2026-10-19 using xcrun simctl list runtimes --json. This proves installation, not execution: no simulator was booted and no product tests ran. Xcode/Swift/host details are in [PLATFORM_MATRIX.md](PLATFORM_MATRIX.md).

| Installed runtime | Build | Available according to simctl | Architectures |
| --- | --- | --- | --- |
| iOS 18.2 | 22C150 | Yes | x86_64, arm64 |
| iOS 18.5 | 22F77 | Yes | x86_64, arm64 |
| iOS 26.2 | 23C54 | Yes | x86_64, arm64 |
| tvOS 18.2 | 22K154 | Yes | x86_64, arm64 |
| tvOS 18.5 | 22L572 | Yes | x86_64, arm64 |
| tvOS 26.2 | 23K51 | Yes | x86_64, arm64 |
| watchOS 11.2 | 22S99 | Yes | x86_64, arm64 |
| watchOS 11.5 | 22T572 | Yes | x86_64, arm64 |
| watchOS 26.2 | 23S303 | Yes | x86_64, arm64 |

No iOS/iPadOS 17, watchOS 10, or tvOS 17 runtime is in this inventory. A macOS 14 test host is unconfirmed; the local host was observed as macOS 15.8.1. isAvailable does not guarantee that a specific scheme/destination works with the selected Xcode.

The owner reports access to iPhone/iPad, Mac, Apple Watch, and Apple TV with current updates. This is owner-reported; exact models/OS builds are unverified. Do not publish serial numbers or UDIDs. Before I22, record necessary model/OS/architecture and compatibility without private identifiers.

## Execution after implementation authorization

1. I06 verifies actual runner images, Xcode, schemes, and destinations, and runs all four platform families. No paid runners or installations are preapproved.
2. I17 consolidates deterministic contract tests and controlled URLSession integration tests. Use isolated local services/mocks, not production services or real credentials.
3. PREP-01 / #85 investigates access and exact device inventory now; it may complete with documented gaps but does not satisfy release evidence. I21 establishes documented access to minimum runtimes/hosts. First investigate official compatible runtime/Xcode combinations or available older test machines. Do not automatically downgrade updated devices. Purchases/upgrades require separate decisions.
4. After API/security review and PREP-01, I21 and I22 can execute independently; both remain required. I22 tests representative newer physical devices and real network transitions where relevant. Record minimum-OS and newer-device evidence separately.
5. I23 and REL-01 require all selected evidence before release. Mark missing evidence blocked, not passed.

Per run, record issue/test ID, commit SHA, date, Xcode build, Swift/SDK, OS build/architecture, simulator or device type, command/scenario, expectation/result, and sanitized evidence link. Assess permissions, entitlements, and privacy against actual v1 usage. Do not add irrelevant F3–F6 requirements.
