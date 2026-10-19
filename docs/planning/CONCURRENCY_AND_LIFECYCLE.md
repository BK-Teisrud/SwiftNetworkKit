# Concurrency, session ownership, and lifecycle in v1

Status: Planned contract, 2026-10-19; see [ADR-0006](../decisions/ADR-0006-concurrency-and-lifecycle.md). No product code or tests exist.

## Concurrent use and isolation

Multiple tasks must be able to use one client safely, without a global singleton or one session per request. Public client boundaries, request configuration, and values shared across tasks must satisfy the selected Swift 6/Sendable contract. App models must be suitable; do not hide unsafe shared state behind blanket unchecked Sendable declarations.

Client configuration is immutable after construction. Capture per-call overrides as snapshots. Caller changes during execution must not alter an in-flight request. Body, headers, baseURL, and decoder policy belong to that snapshot.

Isolate shared active-request registries, lifecycle state, and terminal causes using actors/synchronization. Do not hold locks across await or serialize all network waiting and decoding globally. The client is not MainActor-isolated; later API review documents Sendable/isolation requirements for adapters and closures. Do not move the entire operation to an unstructured detached task to hide these requirements.

Create or own encoders/decoders per operation according to the selected strategy. Concurrent mutation of shared JSONEncoder/JSONDecoder instances is unsupported. App-defined coding hooks follow documented concurrency requirements and must not mutate unprotected shared state.

Batch APIs, generic deduplication, rate limiters, resource queues, and public scheduling frameworks are outside v1. Concurrent use guarantees neither transport order nor unlimited connections; URLSession/OS manages transport resources.

## Owned versus injected sessions

| Ownership | Construction and reuse | Permitted shutdown behavior |
| --- | --- | --- |
| Owned | Create one session from a configuration snapshot and reuse it | Close the client, cancel its operations, and invalidate that session |
| Injected | Borrow a session constructed and owned by the app | Close the client and cancel only operations it created; never invalidate/reset/flush the entire session |

Timeout/shutdown must not cancel other users' tasks on an injected session. Do not substitute getAllTasks + cancel for tracking the client's own operations. Do not mutate an injected session's global configuration or cookie/credential/cache stores as a hidden side effect.

Only foreground data requests within the HTTP-core contract are supported. Reject background sessions and body streams explicitly. External invalidation of a borrowed session may stop calls; do not silently create a replacement session to conceal it.

The [security policy](SECURITY_AND_NETWORK_POLICY.md) / ADR-0007 defines storage profiles and provider/delegate boundaries for injection. Reject incompatible sessions with documented reasons instead of silently weakening the contract.

## Default limits and precedence

| Setting | Default | Meaning |
| --- | --- | --- |
| Inactivity / request timeout | 30 seconds | URLSession's wait for new data; new data resets the timer. Not a total deadline or a guarantee of measurement in every OS phase |
| Total budget | 60 seconds | Monotonic budget from operation entry through the final pre-delivery check |

Explicit per-call options override client options, which override 30/60 library defaults. Durations must be finite and positive; reject NaN, negative, zero, and infinity before networking. A total budget may be shorter than the inactivity limit; the first expiring limit wins.

Raw URLRequest follows the same policy. URLRequest's built-in timeout value alone is not an explicit per-call override. Consumers choose overrides through the client call policy; apply the effective timeout to the executed request copy. Document this in the eventual API.

Injected sessions may impose shorter resource timeouts or other system limits. A longer library budget cannot extend them. Do not lock an owned session's resource timeout to 60 seconds while promising longer explicit calls. Distinguish the system resource limit from the library budget and document the effective constraint.

Connectivity waiting may follow different system semantics from request timeout. The total library budget still applies. ADR-0007 disables waitsForConnectivity by default, allowing explicit app-controlled waiting within the same budget.

## Clock, deadline, and cleanup

Use a monotonic clock, planned as ContinuousClock in production. Do not use Date/wall-clock time for elapsed/deadline calculations. Start the budget before preparation and include encoding, permitted hooks, transport, and response handling. ContinuousClock advances during system sleep but does not guarantee process wakeup at the deadline.

An injectable internal clock/sleeper boundary allows time to advance deterministically in tests. Add no external clock dependency or generic public scheduler. The watchdog and operation require clear ownership, cancellation, and cleanup on every terminal outcome. Task groups await child tasks; selecting the first completion alone is not a correct timeout implementation.

At expiration, record timeout and cancel the relevant request. Check cancellation/deadlines before network start, after suspension points, and before returning a response. Swift cancellation cannot forcibly interrupt synchronous coding or app hooks. They may delay return; no hard real-time guarantee is provided. When control returns after expiration, deliver timeout rather than late success.

## Cancellation and unambiguous outcomes

| Event | Observable result |
| --- | --- |
| Caller cancelled at entry or cancels an active operation | CancellationError; stop underlying work/waiting as far as the system supports |
| Total client budget expires | NetworkError.timeout, even if the network task ends with cancellation |
| System reports an actual timeout | NetworkError.timeout with safe cause/system code preserved |
| Client shutdown cancels an active operation | CancellationError with shutdown cause in privacy-safe internal diagnostics |
| External session invalidation or unexplained URLError.cancelled | Transport error preserving cause, unless attributable to the client's recorded cancellation/timeout/shutdown |
| Valid success or another error completes before interruption is recorded | Preserve the already selected terminal outcome |

Each operation has exactly one terminal outcome and one cleanup. The first recorded terminal event in isolated state wins a genuine race. Check already-observed task cancellation or deadline expiration before recording success. Do not choose categories arbitrarily based on the last callback read. Post-completion callbacks cannot produce another result or revive an operation.

Cancelling one call must not cancel others. No automatic retry, refresh, detached leftover work, or retained watchdog after completion. A sent mutating request may already have affected the server; cancellation is not transaction rollback.

## Shutdown

Explicit shutdown is idempotent, transitioning open → closing → closed. Once closing is recorded, reject new calls as invalidRequest with a client-closed cause before networking. Cancel active owned operations and clean their registries/watchdogs. Invalidate only an owned session.

Shutdown must not await an actor-blocking call that prevents cleanup. Concurrent shutdown callers share completion. Cancelling a shutdown waiter must not reverse initiated shutdown or lose cleanup ownership. A closed client cannot reopen; construct a new one.

V1 has no separate drain-all-requests mode. Apps may await their calls before shutdown. Deinit cannot guarantee asynchronous completion; document explicit shutdown for controlled closure. Cleanup never affects an app-owned session or other app tasks.

## Required tests after implementation authorization

1. Concurrent calls on one client, isolated snapshots, and no global serialization of network work.
2. Owned-session reuse; injected sessions remain usable by others after client shutdown.
3. Cancellation before request start, during networking, and at response-decoding checkpoints, without affecting other calls.
4. Controlled clock: 30/60 defaults, per-call overrides, total deadlines during connectivity waiting, no late success, and watchdog cleanup.
5. Timeout versus caller cancellation versus external invalidation; completion/cancel/shutdown races with exactly one outcome and cleanup.
6. Idempotent shutdown, rejected new calls, cancelled shutdown waiters, and no cleanup deadlock.
7. Invalid durations, raw-request precedence, stricter session resource limits, and no false hard-deadline guarantees for synchronous work.

These are planned acceptance requirements, not passed tests. [CI_AND_TEST_PLAN.md](CI_AND_TEST_PLAN.md) / ADR-0008 defines infrastructure and the planned matrix; actual CI/runtime verification remains outstanding. F0 acceptance and separate explicit implementation authorization remain prerequisites.
