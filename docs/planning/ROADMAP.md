# Roadmap

## Current delivery — 2026-11-01

F2 is closed. The bounded read-retry contract/code start is approved under ADR-0014/#137. I24–I26 are Done; I26 final acceptance is PR #142/main run 41296068624. I27 #110 reviews the additive API, diagnostics, evidence and residual risks; its source-compatible initializer and final-budget corrections pass 245 local tests. Owner F3 gate disposition and candidate PR/main acceptance remain pending. See [I27 review](I27_RETRY_REVIEW_2026-11-01.md).

Physical Watch #132 and actual app/workload/security/publication #29 remain mandatory separate gates. No release, version/date, unknown-workload suitability or further extension code is authorized. [Preserved status history](F3_STATUS_HISTORY_2026-11-01.md) retains superseded summaries without presenting them as live next steps.

## F0 – Architecture and decisions

Rights, v1 scope, platforms/toolchain, APIs, concurrency, security, and CI were accepted together on 2026-10-19 in [ADR-0009](../decisions/ADR-0009-f0-approval-no-implementation.md). At that time, implementation was not authorized. All eight decision issues are complete. ADR-0010 and PR #65 completed OPS-01 / #30; F0 is closed. The owner subsequently instructed implementation to begin on 2026-10-20; ADR-0012 and closed START-00 / #41 record this separately. I01 starts F1 with the package baseline.

## F1 – HTTP core

The initial HTTP slice is delivered through I01–I10. I11 / #52 records the [F1 contract and evidence review](F1_REVIEW.md), including cumulative real platform CI, typed/raw parity, known limits and phase closure. F1 acceptance requires successful I11 PR/main checks; the issue records the actual outcome. Open domain epics retain their remaining v1 work in F2.

## F2 – Production hardening and v1 gate

Closed after the accepted non-publishing core rehearsal and [final closeout](F2_CLOSEOUT_2026-10-31.md). #27/#64/#86 are Done. The owner approved only the recorded F2 resource disposition and explicit Watch publication deferral; #29/#132 retain their separate mandatory gates. F2 completion creates no tag/release or production suitability.

## F3 – Bounded read retries

ADR-0014/#137 authorizes only the selected disabled-by-default read-retry increment. I24/I25 implement decisions and the original-operation pipeline; I26 verifies native/minimum/resource evidence; all three are Done. I27 #110 is the current API/evidence/risk gate. [Review](I27_RETRY_REVIEW_2026-11-01.md) records candidate corrections, full baseline-symbol preservation and the pending owner/PR/main decisions. Cache/auth refresh/monitoring/advanced resilience stay unselected; domain catalogs remain open. No extra milestone or version/date promise is warranted.

## F4 – File transfers

Deferred beyond v1. PLAN-F4 / #88 selects use cases and verifies file ownership, cleanup, server support and platform feasibility. Foreground and background deliveries may need separate milestones; neither the entire transfer catalog nor universal background support is promised.

## F5 – Real-time communication

Deferred beyond v1. PLAN-F5 / #89 defines the selected WebSocket lifecycle, backpressure/authentication/shutdown contract and fixtures. Base connection and optional reconnect can become separate deliveries; file transfers are not an automatic dependency.

## F6 – Specialized features and research

Research candidates only. PLAN-F6 / #90 ranks actual product needs and sets bounded feasibility and stop/go criteria. Split unrelated security/networking delivery milestones only after evidence and a scope decision.

## Dependencies and approval

Endpoint contracts precede interceptors/authentication/retry. Error taxonomy and response wrappers precede API stabilization. Cancellation/clocks precede retry/refresh. Redaction precedes detailed diagnostics. OS matrices/entitlements precede background/Bonjour/multicast. Security review precedes pinning/mTLS/OIDC.

Break domain epics into separate testable tasks before Ready. F0 acceptance covers included/deferred CORE subrequirements. Extensions cannot enter v1 without updated scope and impact assessment. Close phase gates only with links to actual evidence.

## Historical public HTTPS route — 2026-10-27

[NET-01 #115](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/115), Order 20.95, uses owner-selected [public native HTTPS checks](PUBLIC_HTTPS_VERIFICATION.md) through the existing client/host. No paid/private test environment is provisioned. Public observations, independent certificate conditions and platform-specific error mapping remain distinct from controlled server counters, minimum/other-device/resource and final release evidence. #62/#63/#86 stay open for their remaining criteria.

## Historical native lifecycle/storage follow-up — 2026-10-28

NET-01 #115 is accepted on main 40644612904. [NET-02 #117](NATIVE_LIFECYCLE_STORAGE.md) adds actual Mac/iPhone cancellation, shutdown/session ownership and isolated cookie observations; local full suite 12/12 passed and PR #118/main 40745209513 are accepted. [Minimum-runtime candidates and authorization](MINIMUM_RUNTIME_ACCESS_2026-10-28.md) remain a separate #62 route: authenticated imports and [four minimum simulator regression results](MINIMUM_RUNTIME_EXECUTION_2026-10-28.md) passed locally at 215/215 each; PR/main acceptance remains pending. Earlier iOS migration timeouts are retained. macOS 14 and separate native/resource scenarios remain open. All unproved F2/native/resource/archive/release criteria remain open.

## Historical F3 refresh before complete approval — 2026-10-31

With F2 closed and main run 41244932962 accepted, #87/#106 now refine [the existing retry proposal](RETRY_INCREMENT_PLAN.md). Proposed ADR-0014 replaces only the draft's colliding identifier; accepted ADR-0013 remains the Watch decision. Owner choices narrow the initial increment and keep reason metadata/advanced resilience products deferred. #107–#110 remain Backlog until complete scope and explicit code-start approval. No new milestone, version/date or implicit dependency on publishing #29.
