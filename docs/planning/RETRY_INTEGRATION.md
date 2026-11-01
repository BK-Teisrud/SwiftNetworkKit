# I25 — one-operation read retry integration

Tracking: #108; requirements NK-07-01/02/03/04/08/09. Contract: [ADR-0014](../decisions/ADR-0014-opt-in-retry-proposal.md). I24 was accepted through PR #138/main `f94236b36bd0fa5ea91a2d09f1a7e0782916d4f6`, verified run 41250907636. The owner authorized I24–I27 through #137; publication is separate.

## Behavior

NetworkCallOptions adds `retry: RetryPolicy = .disabled`. Opt-in `.oneRetryForSafeReads` is shared by typed/raw calls. Invalid method/body/body-stream combinations fail before provider invocation or networking; the original typed method is validated before Foundation normalization. Existing call sites retain disabled behavior.

Preparation/authentication happen once inside one NetworkOperation. Both attempts reuse the immutable prepared original request/session/binding and existing per-attempt redirect policy. No recursive send, new admission, provider refresh, session recreation, overlapping attempt or new total deadline is introduced. Failed response data unwinds out of the attempt helper before its sanitized metadata reaches the retry loop and joined cancellable sleep. The final ordinary response/error is returned; decoding and all excluded failures never enter retry waiting.

The small ResponseMetadata boundary is shared by standalone response decoding and live attempts, retaining the existing status/header validation and avoiding duplicated parsing. It collects exposed Retry-After field identities before case-insensitive HTTPHeaders collapsing. Foundation may already have merged/discarded wire fields; the library cannot reconstruct those. Combined/duplicate values still observable at that boundary are rejected. This is not a new raw-wire guarantee.

NetworkOperation.remainingBudget reads admission-time elapsed monotonic duration. The watchdog, retry sleeper, attempts and cleanup remain joined in that same operation. Deadline, cancellation and shutdown checkpoints surround waiting and sending. A wait must fit strictly within the original remaining budget; late wakeups cannot send after the selected deadline. Inactivity applies separately to each transport invocation.

Only `attemptCount` is added to the existing optional terminal diagnostic. It is 0 before invocation, 1 on the first, and 2 only on actual retry invocation. One ID/event/duration/outcome covers the logical call. Status is cleared on each invocation, preventing a second transport failure from reporting the previous response as final-attempt status. Redirects and OS wire attempts are excluded. No reason enum, extra stream or raw history is added.

## Local verification

Xcode 26.3 / Swift 6.2.4, macOS 15.8.1. Fourteen integration tests cover typed/raw 429/503, both allowed transport identities, auth once/request equality, invalid UTF-8 in a rejected first response, accepted-503 precedence, disabled behavior, excluded error classes, invalid replay before auth/network, second-failure finality, cancellation/shutdown/deadline during waiting, original-budget expiry during second transport, insufficient budget, concurrent-call isolation and joined retry/watchdog cleanup.

Fault controls deliberately replaced remaining budget with the original total and enabled retry on disabled calls. The targeted assertions failed (two budget assertions and four disabled-call assertions), and original sources were restored before full verification. No mutation is shipped.

Full local regression passed: 237 tests in 30 suites. Repository integrity and all 19 helper tests passed, with 24 shared test/helper files wired into the device host. Public DocC conversion (warnings as errors) and compiled integration examples passed. PR/main CI remains required for acceptance. Deterministic transports establish control flow; actual native retry/resource/target evidence belongs to I26, not these doubles or prior F2 results.

## Continuous plan and quality assessment

The only internal separation is shared response metadata plus one bounded attempt loop; no public transport/clock/plugin, general retry framework, timer rewrite or dependency is added. I26 #109 retains controlled native 429/503 sequences, TLS exclusion, real header observability and resource measurements across original deadlines. I27 #110 retains additive API/schema/compiled-guide review and the final evidence ledger. The existing four slices remain sufficient; no additional feature issue is justified. Physical Watch #132 and production/workload/security/publication #29 remain mandatory and unchanged.
