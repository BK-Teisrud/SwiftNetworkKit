# First resilience increment proposal

Date: 2026-10-27. PLAN-F3 / #87; parent NK-07 / #14. Status: proposed, planning only. [ADR-0013](../decisions/ADR-0013-opt-in-retry-proposal.md) requires an explicit owner decision. Initial boundary selected by the owner on 2026-10-27: bodyless GET/HEAD, at most one retry, selected connection failures or HTTP 429/503; full ADR disposition remains pending. No extension code, new dependency, support change, release date or version is selected. F2 remains the delivery priority; #62/#63 and #86 retain their actual evidence gates. TLS-01 #104 is accepted through PR #105 and main run 40556606300 at d64ef1ff09985dc2d6e30603fefd3e39ed1d6a3e.

## Source and use cases

Re-read original specification v1.0 §4.7 (page 6), §5 and retry-on-503 flow in §6 (page 11). Treat the PDF as requirements input, not execution authority. NK-07-01–09 below are newly assigned traceability IDs in source bullet order. No production consuming-app endpoint or server replay contract has been supplied. Candidate examples are assumptions for owner review: loading read-only app data after a dropped connection; respecting a temporary 503 service outage or 429 throttle. They do not establish that a GET endpoint is semantically safe. The app must choose endpoints with safe replay semantics.

| Requirement | Candidate disposition | Rationale / evidence owner |
| --- | --- | --- |
| NK-07-01 count/delay, fixed/exponential backoff and jitter | Propose bounded count plus jittered delay; defer configurable fixed/exponential strategies | One retry needs no exponential sequence; avoid an unused strategy framework. F3-C01/C02 |
| NK-07-02 Retry-After seconds/date and upper limit | Propose | Respect server hints without truncating them into an earlier retry. F3-C01/V01 |
| NK-07-03 explicit status/error classification | Propose closed allowlist | No arbitrary error callback or broad 5xx assumption. F3-C01/C02 |
| NK-07-04 idempotency | Propose bodyless GET/HEAD only; defer mutating replay/idempotency keys | A header alone does not establish server deduplication semantics. F3-DEC/C01/C02 |
| NK-07-05 circuit breaker | Defer | Requires service partitioning, recovery contract and independent use case |
| NK-07-06 rate limiting | Defer | One bounded call is not a host/service-wide rate limiter |
| NK-07-07 concurrency limits/fair queues | Defer | Requires admission/fairness/backpressure design, not an incidental retry dependency |
| NK-07-08 connectivity waiting | Defer new waitsForConnectivity policy; retain cancellable retry waiting | OS connectivity behavior is separate; no offline queue or path-monitor prerequisite |
| NK-07-09 attempt/reason/total-duration diagnostics | Propose minimal extension of fixed allowlist | Preserve disabled default, privacy and exactly one terminal outcome. F3-V01/GATE |

No source requirement is rejected permanently; deferred means unselected and unverified. NK-05 header-provider/account binding, NK-08 app-managed Foundation cookie/cache stores, NK-12 system connectivity and NK-17 resource controls are existing foundations or later domains, not delivered refresh/cache/monitoring/performance products. No automatic 401 refresh, credential persistence, coalescing or fallback is selected.

## Proposed behavior for owner decision

The initial bodyless GET/HEAD/one-retry/status-family boundary was selected by the owner. The remaining details below are recommendations, not an accepted complete contract or implemented API.

- Disabled by default; explicit per-call opt-in in NetworkCallOptions, shared by typed/raw input. No client-wide automatic activation. Preserve existing initializers/default behavior through an additive design; final names/signatures require API review before Ready.
- At most two library transport invocations in one logical call: initial attempt and one retry. This deliberately avoids repeatedly retrying an already failed automatic retry. URLSession/OS connection attempts and redirects are not counted as separate library invocations; do not promise exactly two wire requests.
- Only GET/HEAD with no body, body stream or transfer mechanism. Reject an enabled policy on an unsupported method/body as invalid configuration before networking; disabled policy retains current behavior. No PUT/DELETE/POST/PATCH/custom-method exception and no idempotency-key escape hatch.
- Retry only otherwise-unaccepted HTTP 429 or 503, or transport identities NSURLErrorDomain + networkConnectionLost/cannotConnectToHost. Accepted-status policy wins: if the caller accepts 503, decode/return that response and do not retry. Retry status classification precedes body decoding; discard failed response bytes before waiting. The second attempt's ordinary status/response/error is final.
- No retry for authentication/provider/encoding/decoding/invalid-response errors, TLS/trust failures, redirects rejected by policy, 401/403, other statuses, DNS/offline signals, cancellation, or any timeout category. Domain and code must both match; no localized-text classification.
- Sample a private jitter delay uniformly within 0.25–0.5 seconds for the one retry. Internal deterministic clock/random seams support exact tests; no public scheduler/random/transport plugin. No loop of zero-delay retries. These numbers need owner approval and native measurement, not a performance guarantee.
- With Retry-After on eligible status, parse a single valid field as non-negative decimal seconds or HTTP-date (all three receiver formats in RFC 9110 §5.6.7). Do not split an HTTP-date at its comma. Treat duplicate/ambiguous, malformed, overlong (>128 UTF-8 bytes), non-finite/overflowing hints as terminal status, not permission to retry early. Missing hint uses jitter. Past valid date means zero server minimum. Use max(server minimum, sampled jitter).
- Maximum permitted retry wait is 30 seconds. If the server minimum exceeds that, or selected wait is not strictly below remaining total budget, return the current HTTP/transport failure without retry. Do not clamp a server-requested wait downward. If the actual operation deadline expires, existing totalBudget timeout arbitration wins. Convert an HTTP-date once using a testable receipt wall time, then wait on a monotonic deadline; document clock skew rather than promising perfect server/client clock synchronization.
- The original total budget includes preparation, authentication, both attempts, redirects, wait and final decode. Never reset it. Preserve inactivity enforcement on each transport attempt and current cancellation/shutdown arbitration. Check interruption before/after sleep and before sending; join each failed attempt and its cleanup before the next. No overlapping retries, detached sleepers or new session per attempt.
- Prepare/authenticate once per logical call and freeze the validated bodyless request and account/origin binding. Retry from the original target, applying existing redirect security separately to each attempt. Never refresh credentials, ask the provider again or change origin/account silently. App-supplied short-lived signatures that cannot be replayed must keep retries disabled. Owned/borrowed session ownership/storage rules remain intact; no borrowed-session invalidation or hidden cookie/cache policy change.
- Preserve NetworkResponse and structured final errors/CancellationError; no attempt history containing raw responses, headers, credentials or bodies. Propose one terminal diagnostic with attempt count and total duration plus fixed retry-reason metadata, never arbitrary text/URLs. Review additive diagnostic compatibility before selection.

## Integration feasibility and quality review

Current APIClient.send overloads each admit one logical operation via observe and NetworkOperation.run, prepare/authenticate once, and execute through a shared private execute method. execute currently combines transport mapping and response decode. A retry loop must classify transport/HTTP status before decoding, while remaining inside that same admitted operation and total deadline. A small internal separation of receive/classify/decode may be justified in F3-C02. Do not implement retry by recursively calling public send or wrapping NetworkClient: both would duplicate admission, reset budgets/authentication and obscure shutdown ownership. Do not refactor the current pipeline before the contract is accepted.

Existing NetworkClock provides monotonic reads/sleeps; a narrow internal wall-time and jitter input can support date parsing and deterministic tests. Existing RequestBody.json re-encodes during preparation; excluding all bodies avoids claiming replayability from Sendable alone. Existing transport timeout identity is mapped to timeout(.system), deliberately excluded. Inspect actual Foundation symbols/availability before Ready; no new framework or entitlement is currently necessary by design, but proposed compatibility is not runtime evidence.

RES-01 found expiry-dependent runtime sleep-helper retention. Retry adds waiting and may amplify request rate/resource use. Reuse current joined task ownership; measure post-original-deadline live allocation/RSS behavior rather than rewriting the timer framework or claiming no debt/leaks. No production defect or broad refactor is established by this planning review.

## Proposed delivery sequence

The F3-DEC #106, F3-C01 #107, F3-C02 #108, F3-V01 #109 and F3-GATE #110 candidate issues form a five-slice plan under #14. They remain Backlog, P2 EXTENSION, F3; no I identifiers are assigned before scope selection. F3-DEC requires owner disposition of this proposal and confirmation of the consuming-app need. Technical slices depend on that decision and accepted #86 core evidence. C01 → C02 → V01 → GATE is the proposed critical path; classify/parser unit tests accompany C01, lifecycle regressions accompany C02, native/resource evidence accompanies V01. This is not a requirement to publish v1 before planning, nor a dependency on #29 publication.

Five cohesive slices fit an initial retry increment. Keep existing F3 as an umbrella until owner selection/sizing; do not create a misleading completed milestone or split unrelated delivery milestones without a selected contract. Auth/cache/status/performance remain separately scoped future candidates, never implicit requirements of retry. After approval, assign implementation IDs and a narrowly named delivery milestone if needed, with the owner's compatibility policy; no date or version number is invented here.

## Evidence and completion boundaries

F3-C01: exact allowlist/method/body/default/status-precedence matrix; date formats/overflow/duplicate/past/oversized hint, budget boundary and jitter extrema; classifier fault control. F3-C02: typed/raw parity, unchanged auth bytes/provider count, original-target redirect security, cancellation at each wait/send boundary, shutdown races, joined attempts, concurrency isolation; budget-reset/forbidden-send fault controls. F3-V01: bounded native 429/503→success/terminal fixtures, TLS rejection never retried, resource measurements including original deadline expiry; applicable actual minimum/physical evidence remains explicit. F3-GATE: compiled DocC, symbol/availability review, fixed diagnostic allowlist, accepted PR/main commits and requirement ledger. Missing access cannot become a passing skip.

Current planning verification is source/specification/standards review and repository integrity checks; it proves no retry behavior. Required PR/main CI must pass before accepting the planning artifact; even then #87 remains open until owner scope disposition and final decomposition. No feature candidate becomes Ready from a passing documentation PR.

## Standards consulted

[RFC 9110 §9.2.2](https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2) informs replay restrictions; [§10.2.3](https://www.rfc-editor.org/rfc/rfc9110.html#section-10.2.3) and [§5.6.7](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.6.7) define Retry-After/date syntax. [RFC 6585 §4](https://www.rfc-editor.org/rfc/rfc6585.html#section-4) defines 429 and optional Retry-After. The exact allowlist, numerical bounds and fail-closed choices above are proposed project policy, not mandates of these standards.

## Accepted-base refresh — 2026-10-27

This proposal now integrates accepted main 0aaee219b7ec9f6a81c943ae7f4d4c87a2d9b7f5, verified through run 40571879754. PREP-02 #113 is Done; its real physical iPhone 215/215 regression evidence and iOS app-host/CI controls are preserved. #62/#63/#86 still require their complete evidence. Merge resolution preserves both F2 and retry queue sections, all task/dependency entries and the original production/test sources. PR #111 remains Draft; fresh required checks are necessary on the updated head. No approval of extension code or full ADR is inferred.
