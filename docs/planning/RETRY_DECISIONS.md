# I24 — bounded retry decisions

Tracking: #107. Contract: [ADR-0014](../decisions/ADR-0014-opt-in-retry-proposal.md), [approved increment](RETRY_INCREMENT_PLAN.md). The owner explicitly authorized I24–I27 through START-F3 #137 on 2026-10-31, after planning PR #111/main run 41248255517 acceptance.

## Delivered boundary

`RetryPolicy` is an immutable Sendable/Equatable value with disabled and one-retry-for-safe-reads choices. I24 adds the pure internal method/body validator, exact status/domain-code classifier and bounded delay/date parser. No public callback, configurable strategy, clock, shared formatter or new dependency is introduced. The value is deliberately not connected to `NetworkCallOptions` until I25 implements its behavior; existing calls cannot accidentally opt into an unimplemented feature.

The private decision helper requires exactly one completed attempt, caller-supplied 250–500 ms jitter, a finite positive remaining budget, and a wait no greater than 30 seconds and strictly below that budget. Accepted status takes precedence. Retry-After is parsed from distinct field values: absent uses jitter; duplicate, combined, malformed, overflow, overlong and disallowed waits fail closed. IMF-fixdate, RFC 850 and asctime forms use local strict POSIX/GMT formatters, calendar validation and the rolling 50-year interpretation. Date hints are converted using the supplied receipt time; monotonic sleep and interruption belong to I25.

## Verification

Local Xcode 26.3 / Swift 6.2.4 on macOS 15.8.1:

- Five new deterministic tests pass, covering all 500 valid status codes and accepted-status overrides, exact transport identities/domain collisions, excluded failure categories, method/body/body-stream combinations, all date forms and malformed/duplicate/oversized hints, cap/budget/jitter boundaries and attempt exhaustion.
- A deliberate classifier mutation replacing eligible 429 with 500 is detected by two failed assertions. The original source is restored before normal verification.
- Full `swift test`: 223 tests in 29 suites pass (218 existing plus five new).
- Shared device-host source membership includes the new test file, preserving derived Watch/TV host coverage. These are wiring checks, not new physical execution evidence.

PR/main CI is still required before I24 acceptance. Existing runtime/minimum/physical evidence is not relabelled as evidence for the future retry loop.

## Integration and quality follow-up

I25 must validate original typed method/body intent before Foundation normalization, and validate the effective raw request; Foundation may normalize standard lowercase methods. Preserve distinct Retry-After field identity before `HTTPHeaders` can collapse identical case-insensitive values; document Foundation's raw-header observability limits rather than claiming wire fidelity. Keep status-before-decode, provider-once/original-target security, one admitted operation/deadline and joined attempts in I25. The pure helper never sleeps, starts transport, retries cancellation or arbitrates shutdown.

The four selected slices remain coherent and sufficient. These integration obligations belong in existing I25, with native/resource verification in I26 and API/diagnostic review in I27; no additional feature issue or general pipeline/timer refactor is justified. Physical Watch #132 and publication #29 remain independent mandatory gates.
