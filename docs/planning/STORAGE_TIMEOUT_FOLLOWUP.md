# Storage-probe liveness follow-up — BUG-01

Date: 2026-10-26. Task: [#95](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/95). This acceptance blocker precedes I19; I18 / #59 remains unaccepted until its failed main evidence is reconciled.

## Observed failure and uncertainty

PR #94 passed all seven checks, but [main run 40382689252](https://github.com/BK-Teisrud/SwiftNetworkKit/actions/runs/40382689252) on `5ea73b3f8f4045bea23dd32bd0b8b3273c2a9358` failed. StorageIntegrationTests.strictProfileCannotServeAnAutomaticHTTPCacheEntry(borrowed: true) exceeded its original 60-second limit. Xcode restarted the test process. macos-core and quality-gate failed; the other platform/source/DocC checks succeeded. No accepted I18 main result exists from that run.

The retained log does not identify whether the storage server's readiness, strict I/O, raw cache positive control, client shutdown or child teardown stalled. Nearby socket warnings are not proof of a cause. This is distinct from previous jobs that never acquired a hosted runner. Do not erase the failure with a blind rerun or claim an OS/cache/product root cause without evidence.

## Concrete liveness and diagnostic changes

The previous test fixture performed an unbounded stdout read for its port and an unbounded Process.waitUntilExit in teardown. Its stderr pipe was never drained. The raw Foundation cache control used default timeouts that could exceed the enclosing test. These are observed source-level gaps even though the original stalled phase is unknown.

A macOS-only [test child-process helper](../../Tests/NetworkKitTests/BoundedFixtureProcess.swift) now bounds the readiness handshake to three seconds and 128 bytes, uses monotonic elapsed time with poll/read, and routes synthetic fixture stderr directly instead of retaining an undrained pipe. Teardown requests termination, waits at most one second, then force-stops only its owned running child and waits at most one additional second. A failed join is an assertion failure, not ignored acceptance. This is a test-helper boundary; Process launch/OS scheduling are not hard real-time guarantees.

The cache probe emits immediate, synthetic phase labels for owned/borrowed startup, each strict request, wire-record retrieval, client shutdown, positive cache control, teardown and completion. It logs no URLs, tokens, bodies or real account/device identifiers. The private raw positive-control session now has five-second request and ten-second resource limits. Library defaults, per-client 5/10 fixture limits and all original cache/owned/borrowed assertions remain unchanged. The suite's one-minute limit is unchanged.

No production transport/cache behavior is changed. If the test recurs, the phase labels and bounded child/raw-I/O failures narrow the next investigation. These changes do not prove that Foundation's internal cache path was the original cause or that the issue can never recur.

## Meaningful failure-path verification

[FixtureProcessTests.swift](../../Tests/NetworkKitTests/FixtureProcessTests.swift) is explicitly macOS-only. One test starts a child that never reports readiness and requires a startup-timeout error plus successful idempotent cleanup. Another waits for a child to install SIGTERM-ignore, then requires successful forced stop and idempotent cleanup. Only child processes created by these tests are signalled. Neither test contacts a network service.

These two declarations add native fixture-lifecycle coverage on macOS only. Other runtime destinations retain the 214 declarations from I18; do not create dummy passes elsewhere to make counts equal. The source inventory lists 216 declarations with these two marked macOS-only; actual counts must come from each runtime result.

Local final-candidate verification passed: `swift test --parallel -Xswiftc -warnings-as-errors` reported 216 tests / 26 suites; a separate StorageIntegrationTests run passed all eight test functions. Both owned/borrowed probes reached every phase through teardown/completion. Local DocC passed with warnings as errors on macOS 15.8.1 x86_64, Xcode 26.3 / 17C529, Swift 6.2.4. Hosted PR/main acceptance is pending and recorded in #95 and its PR after execution. The failed original run remains part of the acceptance record. Do not waive skipped/failed/incomplete tests, increase original timeouts, suppress native assertions or infer release readiness.

## Backlog adjustment

BUG-01 / #95 is P0 at Order 18.5 under testing epic #23 in F2. I18 #59 is explicitly blocked by #95, so I19 remains blocked transitively. #95 does not depend on #59 acceptance: this avoids a cycle while allowing repair of its main evidence. Remaining security/privacy/minimum-runtime/device/resource/release owners are unchanged.

Review the original timeout disposition after successful follow-up PR/main evidence. If a distinct unresolved defect appears, keep #95 open or create a precise blocking follow-up; a green run alone does not establish an undocumented root cause. No new milestone or product-scope change is justified. No parallel independent delivery is started at this failed-main boundary.
