# Platform and toolchain matrix

Status: Support plan accepted 2026-10-19; see [ADR-0004](../decisions/ADR-0004-platforms-and-toolchain.md). This is not verified product support; only the package baseline and I02 value/error layer are implemented; HTTP transport is not.

## Approved delivery baseline

| Platform | Minimum v1 OS | Locally observed SDK | Build | Unit / integration | Tested runtime / device |
| --- | --- | --- | --- | --- | --- |
| iOS | 17.0 | iOS 26.2 | Not run | Not run | Unverified |
| iPadOS | 17.0 | iOS/iPadOS 26.2 | Not run | Not run | Unverified |
| macOS | 14.0 | macOS 26.2 | I01/I02 builds passed | I02: 21 value/error tests passed on macOS 15.8.1 | Minimum OS unverified |
| watchOS | 10.0 | watchOS 26.2 | Not run | Not run | Unverified |
| tvOS | 17.0 | tvOS 26.2 | Not run | Not run | Unverified |
| visionOS | Deferred; no v1 support | Outside selected delivery | Outside v1 | Outside v1 | Outside v1 |

A newer SDK supplies build-time APIs; it does not require the host app to run that OS version. iOS/iPadOS share SDK/deployment foundations, but relevant device/environment differences still need assessment. Mac Catalyst, Linux, Windows, and Android support are not selected.

## Tools

| Setting | Approved requirement | Locally observed 2026-10-19 |
| --- | --- | --- |
| Xcode | 26.3 or a newer stable version, verified before claiming support | 26.3, build 17C529 |
| Swift tools | Minimum 6.2 | Apple Swift 6.2.4 |
| Swift language mode | Swift 6, strict concurrency | No package configured yet |
| Host macOS | Meets selected Xcode's system requirements | 15.8.1 |
| Host architecture | Planned standard GitHub macos-15 arm64; no job run | Compiler reports x86_64 |
| CI SDK / runtime / runner | ADR-0008 / CI_AND_TEST_PLAN.md baseline; actual runs must verify images, schemes, and destinations | No CI created |

Development-host requirements are separate from the library's macOS 14.0 minimum. Local version inspection is not a library test result.

## Symbol checks before Ready

For each selected API, record requirement ID, full symbol name, framework, inspected SDK, availability per target OS, required guard/fallback, and behavioral test plan. Use SDK/Apple documentation; do not infer availability from framework names.

| Area | Foundation | Outstanding checks |
| --- | --- | --- |
| HTTP/session | Foundation / URLSession / URLRequest | Exact async methods, configuration, delegates, timeout, cancellation |
| URL/JSON | URLComponents / Codable / JSONEncoder / JSONDecoder | Selected overloads, parameter semantics, coding strategies |
| Logging | OSLog | Selected logging API, privacy markers, data minimization |
| Concurrency | Swift Concurrency | Sendable, isolation, cancellation, clock APIs; assess language and OS requirements separately |
| Testing | Apple/official tools | ADR-0008 selects Swift Testing/XCTest; actual runtime/harness verification remains |

This is a review checklist, not proof that every symbol is verified. Newer Foundation/OSLog/Concurrency APIs may require higher OS versions than the approved minimums.

## Future test evidence

For each check record commit SHA, date, Xcode build, Swift version, SDK, actual runtime/architecture, simulator/device, test type, and result or concrete reason for missing execution.

Cover builds on every selected platform and relevant normal/error/cancellation/concurrency tests. [CI_AND_TEST_PLAN.md](CI_AND_TEST_PLAN.md) / ADR-0008 separates PR runtimes from release tests on minimum OS versions and representative newer stable runtimes. If CI cannot run a minimum, establish an explicit alternative with real evidence before release; a newer simulator build is insufficient.

Use physical devices where scenarios require them. Background transfers, Keychain groups, and local networking are deferred by v1 scope and are not established by this matrix. No build/runtime verification has passed.

## Bounded declaration check for DEC-04

Inspected 2026-10-19 in local macOS SDK 26.2, Foundation.swiftmodule/x86_64-apple-macos.swiftinterface. Availability annotations name all four platforms, but this does not replace each platform SDK's inspection/builds or runtime tests.

| Symbol | Declared minimum in inspected interface | Relation to v1 minimums |
| --- | --- | --- |
| URLSession.data(for:delegate:) | iOS 15, macOS 12, watchOS 8, tvOS 15 | Within every selected minimum |
| URLComponents | iOS 8, macOS 10.10, watchOS 2, tvOS 9 | Within every selected minimum |
| URLQueryItem | iOS 8, macOS 10.10, watchOS 2, tvOS 9 | Within every selected minimum |
| JSONEncoder / JSONDecoder base classes | iOS 8, macOS 10.10, watchOS 2, tvOS 9 | Within every minimum; check newer members separately |

This is positive declaration evidence for those candidates, not an implemented/tested HTTP contract. Inspect actual HTTPURLResponse/URLRequest overloads/properties, other JSON strategies, OSLog, and concurrency APIs before relevant tasks become Ready. These checks do not change build/test statuses.

## Bounded source/declaration check for DEC-05

Inspected 2026-10-19 in local SDK 26.2. _Concurrency.swiftmodule/x86_64-apple-macos.swiftinterface declares ContinuousClock from iOS 16/macOS 13/watchOS 9/tvOS 16 and CancellationError from iOS 13/macOS 10.15/watchOS 6/tvOS 13. Both fit the selected minimums. No new OS 26-specific clock properties are selected.

Foundation/Headers/NSURLSession.h confirms the distinction between wait-for-data request timeout, resource timeout, and session invalidation effects on tasks. It also distinguishes connectivity waiting from request timeout, motivating a separate total library budget. These reading checks establish neither actual cancellation/timeout behavior nor availability on every SDK/runtime. Build/test statuses remain unchanged.

## Environment inventory before implementation

[TEST_ENVIRONMENTS.md](TEST_ENVIRONMENTS.md) records installed newer runtimes, owner-reported devices, and missing minimum-OS environments. Inventory does not change the test statuses above.

## I01 package-build evidence — 2026-10-20

The macOS library and test target compile with Xcode 26.3 / Swift 6.2.4 on the local x86_64 macOS 15.8.1 host. A separate local consumer compiles and links the NetworkKit product. This is build/import evidence only, not a runtime contract test or a macOS 14 execution result. Other platform builds/runtimes remain unverified. See [PACKAGE_BASELINE.md](PACKAGE_BASELINE.md).

## I02 value-layer evidence — 2026-10-20

[HTTP_VALUES.md](HTTP_VALUES.md) records the API review, bounded SDK declaration check, 21 passing local contract tests, negative control, and public consumer check. These establish value/error semantics only; no HTTP transport, all-platform build, or minimum-OS runtime claim is made.
