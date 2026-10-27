# ADR-0013: Propose a bounded per-call retry increment

Date: 2026-10-27
Status: Proposed; owner decision pending
Owner: @BK-Teisrud
Issue / requirement: PLAN-F3 #87, NK-07 #14 / specification §4.7

## Context and problem

The owner selected retry/robustness as the first post-core planning priority. The accepted v1 contract prohibits library retries; F2 still lacks required minimum/physical/native/resource evidence. Planning an extension does not change that contract. No consuming-app endpoint/server replay contract has yet been confirmed.

## Alternatives

Keep app-owned manual retry; add a general configurable resilience framework; or select one bounded bodyless-read increment. Manual retry stays possible but easily resets budgets/auth/shutdown boundaries. A broad framework couples unrelated auth, caching, queues and circuit breakers without selected use cases. Recommend the bounded increment, subject to owner approval and actual core evidence.

## Proposed decision and rationale

Review [the complete proposed contract](../planning/RETRY_INCREMENT_PLAN.md): disabled by default, per-call opt-in, bodyless GET/HEAD only, at most two library attempts, closed status/transport allowlist, bounded jitter/Retry-After, one original total deadline, unchanged account/origin/session security, no retry for cancellation/timeouts/auth/TLS/decode failures. Exclude mutating replay, refresh, offline queues, breakers and cache. Small internal pipeline separation may support status-before-decode classification, without a public retry plugin or clock API.

## Security, privacy, platforms, and compatibility

Keep system trust, redirect guards, provider-once account binding, storage profiles and fixed diagnostic allowlist. Proposed additive API must preserve disabled behavior/source compatibility and undergo actual symbol/minimum-platform review. Keep current platform/toolchain/dependency policy. No automatic feature activation. Any incompatible API change requires a new explicit decision and migration guide; no version/date commitment follows from this proposal.

## Consequences and deferred scope

A retry can duplicate server side effects even on an incorrectly designed GET. The app must opt in only where replay semantics permit it. Native internal attempts are outside the library attempt counter. Waiting adds resource/clock-skew considerations and requires deterministic/native/resource evidence. F3 candidate issues are Backlog; no implementation IDs until selected. F2 remains the delivery priority.

## Approval and verification

Owner must explicitly accept/modify/reject this contract and confirm the actual app need. A general request to continue planning, a merged documentation PR or passing CI is not that decision. #87 stays open pending disposition. Even approval requires accepted #86 core evidence and task Ready review before extension code; #29 publication is a separate decision. Required planning PR/main checks are recorded in #87, not assumed here.

## Supersedes / superseded by

Supersedes nothing while Proposed. If accepted, amend ADR-0007's no-library-retry boundary only for the separately selected post-v1 opt-in increment. V1 remains unchanged. Preserve ADR-0003/0005/0006/0007 history and update affected contracts in the selected implementation slices.
