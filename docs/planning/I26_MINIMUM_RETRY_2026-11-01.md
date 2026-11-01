# I26 — minimum-runtime retry evidence and remaining Mac route

Current disposition, 2026-11-01: [actual macOS 14 execution](I26_MACOS14_RETRY_EXECUTION_2026-11-01.md) succeeds in run 41294523457. The temporary workflow is disabled; its removal/evidence cleanup awaits PR/main acceptance. Earlier preparation/pending statements below are historical. No physical pass or production/release acceptance is inferred.

Date: 2026-11-01. Tracking: #109, P1 temporarily; contract ADR-0014. PR #140/main `24d030580cc8be0e2b219536184d3381bd91519a` is accepted through run 41290108646: 243 Mac tests, four 234-test simulator runs, 19 helpers. New verification source remains subject to candidate PR/main acceptance; product sources are unchanged.

## Actual minimum execution

The existing Network.framework loopback fixture adds one serialized native declaration with four typed/raw × owned/borrowed cases. Every case exercises 429/503→success, a real HTTP-date Retry-After, terminal/disabled/accepted status behavior, original-target same-origin replay, denied-origin zero contacts, exact SDK invocation vectors and one terminal diagnostic per logical call. No public service is contacted by this selection.

| Actual destination | Version/build | Result |
| --- | --- | --- |
| iPhone 14 Pro simulator | iOS 17.0 / 21A328 | 1 declaration / 4 parameter cases passed |
| iPad (10th generation) simulator | iPadOS 17.0 / 21A328 | 1 declaration / 4 parameter cases passed |
| Apple TV 4K (3rd generation) simulator | tvOS 17.0 / 21J353 | 1 declaration / 4 parameter cases passed |
| Apple Watch Series 9 (45mm) simulator | watchOS 10.0 / 21R355 | 1 declaration / 4 parameter cases passed |

All four summaries have zero failed/skipped/expected-failure tests; all commands and task-started simulator shutdowns exit 0. The Watch uses its already existing task-owned iOS 17 companion pair. All environments execute x86_64 on this Intel Mac; this is not ARM64 or physical-device proof. The matching source/hash/runtime/log-digest record is in [sanitized evidence](evidence/I26_MINIMUM_RETRY_2026-11-01.json). Raw logs, result bundles and unique simulator identifiers remain private.

Use the existing non-shipping SwiftPM workspace/scheme, unsigned, Swift warnings as errors, warning suppression disabled and parallel testing disabled. Select only `PublicHTTPSChecksTests/PublicHTTPSTests/nativeLoopbackReadRetryCounters(input:ownership:)`. No runtime download, new simulator/pairing, device configuration, identity/profile, trust or product-support change is needed. Existing listener/connection teardown remains bounded and checked.

These 16 parameter cases are new actual retry observations, not relabelled F2 results or the full root suite. They do not establish every network condition, physical memory suitability or minimum macOS behavior. The local Mac also passes the same four combinations. The complete local-only fixture regression passes eight declarations with Swift warnings as errors. All 22 CI helper tests pass, including fail-closed read-retry/legacy case-set and opt-in controls.

## Time-critical macOS 14 preparation

GitHub's [official retirement announcement](https://github.blog/changelog/2026-10-01-github-actions-macos-14-runner-image-retirement/) retires standard macos-14 on November 2, 2026 and warns capacity may shrink. On November 1, prioritize its existing exact-source prebuilt-consumer route before I27. This is a temporary scheduling change to #109, not a new delivery milestone, paid runner or support change. Actual capacity is not guaranteed.

Restore only a manual, main-only workflow. The approved Xcode 26.3/Swift 6.2.4 builder on standard macos-15 cross-compiles ARM64/macOS 14.0 public consumers. The standard macos-14 execution job checks actual OS/architecture and exact source/manifest/file hashes before invocation. No older compiler rebuilds the SDK; no Swift Testing framework/toolchain, signing identity or trust anchor is transferred. The existing builder retirement guard remains unchanged.

`--public-https --read-retry` explicitly selects four bounded local release-resource workloads and six fixed public HTTPS cases: typed/raw disabled 503 (one SDK invocation), enabled 503 (two), and opted-in self-signed rejection (one, with the existing exact independent Foundation trust control). The original ten-case HTTPS mode remains separately selected. Fixed public services provide no maintainer wire counter; only the local synthetic workload has independent request counters. No public load benchmark, credential or raw echo/error output is introduced.

[Local preparation evidence](evidence/I26_MACOS14_RETRY_PREPARATION_2026-11-01.json) records six successful native cases on macOS 15, refusal without explicit opt-in, ARM64/macOS 14.0 build/load metadata and verified payload/source hashes. It honestly records a dirty verification checkout and accepted product base. These are preparation results, **not actual macOS 14 execution**. The workflow must rebuild from accepted main; the local payload is not dispatched. Case validation rejects missing/duplicate/unexpected/nonpassing cases and invalid invocation counts; the helper suite includes negative controls.

## Next actions and acceptance boundaries

1. Accept the candidate PR/main checks before any manual workflow dispatch. Stop at each GitHub run as requested; no queue polling or automatic retry.
2. Execute the reviewed workflow on actual standard macOS 14 if it remains available. Record the real patch/architecture and failures honestly. Never substitute macOS 15, Rosetta or paid runners, or turn unavailable access into a pass.
3. Preserve measured/runtime evidence and remove the temporary workflow after disposition or retirement; include that cleanup in existing #109/#110. If the route expires, record the open macOS 14 gap rather than extending the guard or claiming coverage.
4. I26 remains open for this exact remaining native observation and candidate acceptance. I27 retains API/schema/guide/evidence review and applicable owner residual-risk disposition. #132/#29 remain mandatory physical Watch/workload/security/publication gates; simulator success does not satisfy them or expand the separately scoped core-release candidate.

The existing four delivery slices remain sufficient. No product defect or reason for a timer/framework refactor is established by these results. The temporary P1 priority ends when the route is dispositioned; general workload suitability and publication still need their existing separate decisions.
