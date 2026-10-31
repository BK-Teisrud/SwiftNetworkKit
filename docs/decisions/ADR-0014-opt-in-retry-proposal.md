# ADR-0014: Propose a bounded per-call retry increment

Date: 2026-10-31 (refresh of the 2026-10-27 proposal)
Status: Proposed full contract; owner use-case/eligibility/timing/auth/diagnostic selections recorded, complete contract acceptance and implementation authorization still pending
Owner: @BK-Teisrud
Issue / requirement: PLAN-F3 #87, NK-07 #14 / specification §4.7

## Context and problem

The owner selected retry/robustness as the first post-core planning priority. The accepted v1 contract prohibits library retries; F2 is closed and its final documentation main d0a522770269617f95660d67e9d0198838dc2bb5 / run 41244932962 is verified. Physical Watch #132 and publication/workload/security #29 remain separate blockers. Planning an extension does not change that contract. On 2026-10-27 the owner selected the recommended first boundary: bodyless GET/HEAD, at most one retry, selected connection failures or HTTP 429/503. The owner confirms general safe read-only app-data calls as the initial need; no specific endpoint/server replay contract is supplied. This selects a planning direction, not all technical details or implementation.

## Alternatives

Keep app-owned manual retry; add a general configurable resilience framework; or select one bounded bodyless-read increment. Manual retry stays possible but easily resets budgets/auth/shutdown boundaries. A broad framework couples unrelated auth, caching, queues and circuit breakers without selected use cases. Recommend the bounded increment, subject to owner approval and actual core evidence.

## Proposed decision and rationale

Review [the complete proposed contract](../planning/RETRY_INCREMENT_PLAN.md): disabled by default, per-call opt-in, bodyless GET/HEAD only, at most two library attempts, closed status/transport allowlist, bounded jitter/Retry-After, one original total deadline, unchanged account/origin/session security, no retry for cancellation/timeouts/auth/TLS/decode failures. Exclude mutating replay, refresh, offline queues, breakers and cache. Small internal pipeline separation may support status-before-decode classification, without a public retry plugin or clock API.

## Security, privacy, platforms, and compatibility

Keep system trust, redirect guards, provider-once account binding, storage profiles and fixed diagnostic allowlist. Proposed additive API must preserve disabled behavior/source compatibility and undergo actual symbol/minimum-platform review. Keep current platform/toolchain/dependency policy. No automatic feature activation. Any incompatible API change requires a new explicit decision and migration guide; no version/date commitment follows from this proposal.

## Consequences and deferred scope

A retry can duplicate server side effects even on an incorrectly designed GET. The app must opt in only where replay semantics permit it. Native internal attempts are outside the library attempt counter. Waiting adds resource/clock-skew considerations and requires deterministic/native/resource evidence. F3 candidate issues are Backlog; no implementation IDs until selected. F2 remains closed; preserve its accepted core and separate publication gates.

## Owner selections and complete decision boundary

The owner confirmed the following on 2026-10-31 in the Norwegian conversation:

- General safe read-only app-data calls; no special API/provider integration is required for this increment.
- Disabled default; per-call bodyless GET/HEAD opt-in; one retry, only otherwise-unaccepted HTTP 429/503 or NSURLErrorDomain networkConnectionLost/cannotConnectToHost. Accepted status wins. All proposed excluded categories remain excluded.
- Private uniform 250–500 ms jitter, server Retry-After respected up to 30 seconds, no retry if the selected delay cannot fit strictly within the original remaining total budget.
- Prepare explicit request/auth headers once, preserve account/origin and original target; no provider repeat, refresh or hidden 401 retry. One-use signatures must keep retries disabled.
- Add only actual library attempt count to the existing optional terminal diagnostic. No retry-reason field/event stream in this increment; total duration remains existing metadata.

The complete [contract](../planning/RETRY_INCREMENT_PLAN.md), including strict hint parsing/invalid-policy behavior, cancellation/lifecycle, storage and compatibility limits, is still Proposed for final owner review under #106. These selections do not authorize implementation. #107–#110 remain Backlog, without I identifiers, until complete scope selection and an explicit code-start instruction. Passing documentation checks or a generic instruction to continue planning is not code authorization. #87 does not depend on publishing #29.

Required planning PR/main checks must pass before the refreshed artifact is accepted. No old-base CI result or stale ADR ID is acceptance. ADR-0013 remains the distinct accepted Watch publication decision.

## Supersedes / superseded by

Supersedes nothing while Proposed. If accepted, amend ADR-0007's no-library-retry boundary only for the separately selected post-v1 opt-in increment. V1 remains unchanged. Preserve ADR-0003/0005/0006/0007 history and update affected contracts in the selected implementation slices.
