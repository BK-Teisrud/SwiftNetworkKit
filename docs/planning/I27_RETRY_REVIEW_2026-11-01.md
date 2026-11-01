# I27 — bounded read-retry API and delivery review

Status: review candidate; owner F3 gate disposition and required PR/main checks pending. I26 is completed through PR #142/main `7ece7cf5c26220a8d6654035585a20cb6f98218b`, verified run 41296068624 (243 Mac tests, four 234-test simulator runs, 22 helpers). The completed Mac route is removed and disabled. I27 implementation/review is explicitly authorized by ADR-0014 / #137; this is not production or publication authorization.

## Outcome and concrete corrections

The bounded design remains one module, no external dependencies, disabled by default, per-call safe bodyless GET/HEAD, at most one additional library invocation. No broad refactor or additional feature issue is justified. Review found and fixes two demonstrated defects inside this slice:

1. Adding a defaulted sixth initializer parameter removed the original five-argument initializer as a function value. A public consumer using either its full original labels or an inferred five-argument function type fails to compile on the accepted pre-review head. Preserve the original initializer/defaults and delegate its validation to the explicit six-argument retry overload; no migration is required. Ordinary omitted/defaulted calls and explicit retry calls remain supported.
2. Time can pass after the delay helper's remaining-budget snapshot. A deterministic clock reproduces an attempted wait extending beyond the original deadline even while time remains positive. Recheck the remaining budget immediately before waiting, after classification/sampling and the interruption checkpoint; preserve the current failure if the wait no longer fits. Actual deadline/cancellation/shutdown arbitration remains unchanged. The negative control fails two assertions before this fix and passes afterward, without real-time thresholds or a timer-framework rewrite.

Full local regression passes **245 tests in 31 suites**. Public DocC conversion and compiled examples pass with warnings as errors. Rebuild the exact accepted pre-retry source `d0a522770269617f95660d67e9d0198838dc2bb5` under the same compiler: all **319** public symbol identifiers remain, with **seven** reviewed additions (**326** total). [Sanitized review evidence](evidence/I27_RETRY_REVIEW_2026-11-01.json) records inventory, negative controls and candidate-source hash; raw graphs contain local paths and remain private.

## Public surface, availability and privacy

| Surface | Reviewed behavior |
| --- | --- |
| RetryPolicy | Sendable/Equatable, disabled or oneRetryForSafeReads; no arbitrary callback/strategy |
| NetworkCallOptions | Original initializer/function references/defaults retained; explicit retry overload shares validation; no client-wide activation |
| NetworkDiagnosticEvent | Exactly six stored fields: requestID, method, final-started-attempt status, total duration, attemptCount and outcome |
| Private execution | RetryTiming/ResponseMetadata/NetworkOperation/transport/clock remain internal; no new public scheduler, transport or raw-response hook |

The count is 0 before transport invocation, 1 for initial only, 2 only after retry invocation starts. It is not a wire/redirect/handshake count. One logical ID/event/duration covers preparation, attempts, waiting and joined cleanup. The reflection/canary tests enforce the six-field allowlist, disabled sinks and no raw request/response/error/account strings. Existing structured errors and separate CancellationError remain. No token refresh, credential store or telemetry export is added.

The package/toolchain and iOS/iPadOS 17, macOS 14, watchOS 10 and tvOS 17 minima are unchanged. The two review corrections introduce only existing Swift/default-initializer/monotonic-budget operations, no new system API/entitlement. Compiling against declared minima enforces availability; it does not prove every patch/device. No binary ABI-stability, publication version/date or universal OS/runtime guarantee is added.

## Selected-contract reconciliation

| Contract / requirement | Actual evidence and limits |
| --- | --- |
| NK-07-01/03/04: disabled per-call opt-in, bodyless GET/HEAD, exact 429/503 and URL domain/code allowlist, accepted status wins, at most two invocations | RetryDecisionTests, RetryIntegrationTests; native counted Mac/minimum fixtures; actual Mac 14 disabled/enabled cases. Nonstandard/unsafe methods and any body/stream are rejected before auth/network. App must choose semantically replay-safe reads. |
| NK-07-02: jitter, strict Retry-After/date/length/ambiguity/overflow, 30-second cap and original remaining budget | Pure boundary/date tests, classifier mutation, native HTTP-date minimum tests and the new post-snapshot regression. Exposed ambiguous hints fail closed; Foundation may have normalized/discarded wire fields before delivery. |
| NK-07-04/08: prepare/auth once, original target/account/origin, same session, one admitted deadline, no overlapping attempts or detached sleeper | Deterministic provider/request equality, joined cleanup, interruption and concurrency tests; native same-origin original-target counters and denied-origin zero contact. Each invocation retains its redirect guard/hop bound. App-managed cookie/cache state is not frozen wire state. |
| Cancellation/shutdown/timeouts/final errors | No retry for actual cancellation, any timeout, DNS/offline/TLS/auth/encoding/decoding/invalid response. Tests cover both allowed connection identities, category/domain collisions, wait/second-transport deadlines, shutdown/cancel and final second failure. |
| NK-07-09: count-only diagnostic addition | Fixed six-field/canary/public-consumer controls, one terminal event, 0/1/2 invocation assertions; no reason enum/event stream/raw history. |
| Native/runtime/ownership/resources | [I26 native ledger](NATIVE_RETRY_VERIFICATION.md), [16 minimum cases](I26_MINIMUM_RETRY_2026-11-01.md), [actual ARM64/macOS 14.8.9](I26_MACOS14_RETRY_EXECUTION_2026-11-01.md), exact accepted PR/main/explicit-run SHAs in those records. |
| NK-07-05/06/07 and remainder of NK-07-01/09 | Breakers, rate limiting, queues, configurable/exponential strategies, mutating replay/idempotency keys and reason streams remain unselected, not delivered. Domain #14 remains open. |

I26 runtime measurements are tied to their recorded source/hashes, not relabelled as execution of this corrected candidate. Current local regressions/DocC/symbol comparison cover the two review fixes; fresh required candidate PR/main platform checks must pass before acceptance. Existing Foundation ownership/security/response boundaries and declared availability remain unchanged. No old F2 physical result becomes new retry proof.

## Concrete residual-risk proposal for the owner

Approve only the bounded F3 technical increment after required candidate checks, keeping the following limitations and mandatory separate gates:

- App-selected replay-safe reads only; GET semantics cannot be guaranteed for an arbitrary server. Default remains disabled. Provider/request binding is reused; one-use signatures must keep retry disabled.
- Foundation-internal attempts/redirects and header normalization are outside a raw-wire guarantee. Only exposed malformed/ambiguous Retry-After values can be rejected. No new HTTP/TLS stack is proposed.
- Buffering has no enforced response-size cap. Mac resource results are finite observations, not consuming-app workload/device-memory validation. ARM64/macOS 14's single 1 MiB workload reaches **33.02 MiB peak RSS**, with approximately **3.41 MiB reported live malloc** at the post-original-deadline sample. Different OS/architecture/host/rate prevent a causal comparison; neither leak absence nor a leak is established. Runtime/allocator retention can last until original deadlines and RSS may remain elevated.
- Actual minimum-simulator observations are iOS/iPadOS 17.0, tvOS 17.0 and watchOS 10.0 on Intel; actual Mac minimum-family observation is ARM64/macOS 14.8.9, not exact 14.0 or Intel Mac 14. Physical Watch #132 remains unexecuted/mandatory before publication. This candidate does not claim new physical-family results.
- #29 still requires real app rate/payload/budget/device-memory fit, security, exact release-source selection and explicit publication approval. F3 acceptance does not silently expand the separately scoped first stable core release, authorize production suitability or create a tag/version/release.

Owner disposition: **pending**. The prior F2-only resource approval and the I24–I27 code-start instruction do not by themselves approve these new measured F3 gate inputs. This is a concrete technical-phase decision, not a request to accept unknown production workloads.

## Plan and quality assessment

I24/I25/I26 are Done; I27 remains In Progress until owner disposition, this review's required PR/main checks and final reconciliation. The selected F3 milestone remains coherent; no new milestone or duplicate bug/planning issue is needed for the two small in-scope corrections. Live planning summaries are consolidated; original statuses remain in the linked history and immutable evidence.

After F3, PLAN-F4 #88 remains the existing next planning candidate: confirm a real transfer use case and feasibility before selecting any implementation. PLAN-F5/#89 and PLAN-F6/#90 remain separate research/backlog, not automatic next-code permission. Existing #29/#132 remain the appropriate app/workload/publication/Watch owners; do not invent another generic production-readiness issue or implement advanced resilience without a new selected scope/start decision.
