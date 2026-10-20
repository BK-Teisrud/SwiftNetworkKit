# CI and test plan after implementation authorization

Status: Core plan accepted 2026-10-19; see [ADR-0008](../decisions/ADR-0008-ci-tools-and-budget.md). I01–I05 provide a real package and 64 local product test functions. I06 introduces the first workflow; hosted validation and required-check activation are in progress. See [CI implementation](CI_IMPLEMENTATION.md) for exact jobs, commands, and actual evidence.

## Planned PR jobs

After real CI is introduced, run every job on pull requests and relevant pushes to main. The owner selected all four platform families on every PR, not only releases. Documentation PRs receive no hidden global bypass of this matrix.

| Job | Runner / tools | Required real checks before success |
| --- | --- | --- |
| source-integrity | Standard GitHub runner; official/bundled tools | Manifest/dependency/platform/language-mode requirements, file formats, and documentation links; no external Swift packages or library SwiftUI imports |
| macos-core | macos-15, arm64, explicitly selected Xcode 26.3 | Product build with macOS 14 minimum and unit/direct integration tests on the actual host OS |
| ios-core | macos-15, arm64, explicitly selected Xcode 26.3 | iOS/iPadOS build with minimum 17 and tests on selected iPhone and iPad simulators; baseline runtime 26.2 |
| watchos-core | macos-15, arm64, explicitly selected Xcode 26.3 | watchOS build with minimum 10 and tests on a selected watchOS 26.2 simulator, with compatible iPhone pairing/harness where needed |
| tvos-core | macos-15, arm64, explicitly selected Xcode 26.3 | tvOS build with minimum 17 and tests on a selected Apple TV simulator; baseline runtime 26.2 |
| documentation | Standard macOS runner, Xcode 26.3 / DocC | Build docs for the actual public API; check warnings/links and guide accuracy |
| quality-gate | Small standard-runner aggregation job | Every mandatory job succeeds; failures, missing jobs, and unexpected skips cannot yield success |

Source integrity and documentation checks are supporting jobs, not product dependencies. Bind and document actual schemes, test plans, and simulator IDs in the first real CI PR once the package exists. An app/test host is test infrastructure, not another distributed library module. Resolve unsupported test harnesses or raise explicit blockers; a build alone cannot be renamed “tests passed.”

## Runner and toolchain verification

The planned primary runner is standard macos-15 (arm64). Set DEVELOPER_DIR to the installed Xcode 26.3 and verify its version. Do not rely on image defaults or macos-latest. Official inventory reviewed 2026-10-19 lists Xcode 26.3 build 17C529 and SDK/simulator runtimes 26.2, but an older default Xcode. The inventory's macOS host is 15.7.9, not the library minimum 14.

Record image version, host OS/architecture, Xcode build, Swift patch, SDK, runtime, and destinations per run. Verify Swift tools 6.2 compatibility and Swift 6 language mode. Declare platform minimums explicitly in the future manifest. Missing toolchain/runtime fails preflight; do not silently fall back or automatically raise minimums.

Inventory establishes potential availability, not successful CI or a frozen image. The first CI PR must demonstrate selected destinations, including Watch pairing. Runner/Xcode/runtime updates go through PRs and retain approved product minimums. Beta/RC tooling cannot be the sole required gate.

## Test strategy and security

Use Swift Testing for new unit/direct integration tests. Use XCTest for specific platform/performance/harness needs; do not arbitrarily mix assertions from both frameworks within a test. Both come from the selected Apple toolchain, without external Swift packages.

Use URLProtocol/mock transports and a controlled internal clock for normal/error paths, timeouts, cancellation, snapshots, concurrency, session ownership, shutdown, and security policy. Use synthetic data/test credentials only. Depend on no public third-party API or real token. Controlled loopback services or physical harnesses may verify transport properties; neither is a backend product.

URLProtocol alone does not verify TLS/system trust, real redirects, cache/cookie storage, or OS-specific behavior. Verify those contracts where applicable before release. Do not substitute an arbitrary coverage percentage for contract coverage; record actual normal/error/race/security cases tested.

Use only necessary GitHub-owned actions pinned to full commit SHAs. Local steps use Apple/official and available system tools. Do not introduce third-party Xcode installers, SwiftLint/SwiftFormat/xcbeautify, or coverage SaaS merely because they are preinstalled. No external reusable workflows. Build DocC using Xcode tools without an external documentation plugin.

Default GITHUB_TOKEN to read-only. Checkout must not retain credentials accessible to untrusted code. No fork-PR secrets, pull_request_target execution of PR code, or trust in untrusted PR artifacts/caches later published with write tokens. This plan adds no automatic publishing job or secret.

## Resource and cost limits

Only standard GitHub-hosted runners in the public repository are authorized. No larger runners, subscriptions, self-hosted services, or paid add-ons. Reassess pricing/minutes before running after a visibility change; free public standard-runner compute does not guarantee free storage or all account services.

The first CI version has no artifact uploads or explicit Actions cache. Retain only necessary sanitized ordinary job logs within current account/repository limits. Before later uploads, agree small size/retention limits and check remaining free storage. No account-wide billing/subscription/budget settings have changed.

Planned initial limits: at most two concurrent macOS matrix jobs per workflow and a 30-minute timeout per heavy job. A new push replaces/cancels obsolete runs on the same PR with clean cancellation. Do not cancel verification already serving as release evidence. These limits are now configured in the I06 bootstrap workflow.

Runtime/time-limit problems fail with a concrete reason. Do not switch to paid runners, install unapproved tools, or skip tests without a separate decision.

## Require checks only after evidence

1. After implementation authorization, create a real package and meaningful tests before introducing CI.
2. Run every mandatory job on the CI PR and then main. Missing Package.swift or an empty test suite is not success.
3. Verify a stable quality-gate check name aggregating all required platform/test/doc jobs without a green skip path.
4. Only then require quality-gate, with the correct Actions integration and updated branch policy. An unrelated/malicious same-name check is not equivalent evidence.
5. Verify enforcement on another PR. Main has no bypass; preserve that property.

The I06 bootstrap workflow exists; required-check activation awaits successful PR/main evidence. No check merely confirming that code does not exist is introduced.

## Separate release and minimum-OS checks

PR runtimes 26.2 and macOS hosts 15.x do not test minimum iOS/iPadOS 17, macOS 14, watchOS 10, or tvOS 17. The inspected macos-15 inventory does not provide this complete set. Do not promise all minimum runtimes on standard runners.

Before the first release, record evidence for the approved minimums using compatible available official simulators/runtimes or existing devices/Macs with suitable test hosts. macOS minimum support needs actual runtime evidence, not a deployment target on a newer host. Do not assume an older runner supports Xcode 26.3 merely because its host OS matches.

Access to minimum runtimes/devices remains unverified and has not been acquired. No equipment purchases, paid services, or self-hosted GitHub runners are authorized. If evidence cannot be obtained within approved constraints, block release or explicitly revise the support decision. Never mark assumed compatibility as passed.

Release checks also cover representative newer stable runtimes, relevant physical scenarios, documented Mac-architecture assessment, security/privacy, public API/DocC, rights policy, and representative performance/memory measurements. Verify installation from the release candidate commit/tag before final publication to avoid discovering failures only after an immutable release.

Update [PLATFORM_MATRIX.md](PLATFORM_MATRIX.md) and REL-01 with commit, environment, test names/results, known limitations, and approved scope changes. No release checks have run.
