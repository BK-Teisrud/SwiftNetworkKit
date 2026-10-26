# Roadmap

No deadlines are set. Phases are gates, not calendar promises. The owner selected HTTP core first: F0 → F1 → F2 leads to the first stable release. F3–F6 are optional later deliveries, outside v1.0. Repository/package: SwiftNetworkKit; product/module: NetworkKit, with one library module. See [v1 scope](V1_SCOPE.md) and [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md).

Current review: [I20 resource/package baseline](RESOURCE_BASELINE.md). I01–I19, PREP-01, BUG-01 and QA-01 are accepted; F2 remains open. I19 acceptance is recorded in PR #99 / main run 40402676807. RES-01 / #100 (P1, Order 20.5) follows I20 to investigate measured RSS growth and blocks #86. The earlier [quality review](QUALITY_REVIEW_2026-10-26.md) and [plan audit](PLAN_REVIEW_2026-10-26.md) retain their dated findings. Post-v1 planning remains explicit in PLAN-F3–F6.

## F0 – Architecture and decisions

Rights, v1 scope, platforms/toolchain, APIs, concurrency, security, and CI were accepted together on 2026-10-19 in [ADR-0009](../decisions/ADR-0009-f0-approval-no-implementation.md). At that time, implementation was not authorized. All eight decision issues are complete. ADR-0010 and PR #65 completed OPS-01 / #30; F0 is closed. The owner subsequently instructed implementation to begin on 2026-10-20; ADR-0012 and closed START-00 / #41 record this separately. I01 starts F1 with the package baseline.

## F1 – HTTP core

The initial HTTP slice is delivered through I01–I10. I11 / #52 records the [F1 contract and evidence review](F1_REVIEW.md), including cumulative real platform CI, typed/raw parity, known limits and phase closure. F1 acceptance requires successful I11 PR/main checks; the issue records the actual outcome. Open domain epics retain their remaining v1 work in F2.

## F2 – Production hardening and v1 gate

Current review, 2026-10-26: I18 and [BUG-01 / #95](STORAGE_TIMEOUT_FOLLOWUP.md) are accepted through PR #96 / main run 40390885712; original failed evidence and stall-cause uncertainty remain recorded. The owner-requested [QA-01 / #97](QUALITY_REVIEW_2026-10-26.md) quality/maintainability review is accepted; I19 is accepted; I20 measures resources and adds RES-01 / #100 (P1, Order 20.5) for sustained RSS growth relative to a native control. #100 blocks #86 and precedes serial I21 work. Controlled HTTPS access remains unavailable/unknown with native evidence in #62/#63. No extra feature or milestone is selected.

Privacy/logging, cancellation, required authentication boundaries under DEC-04/06, security review, DocC, and a documented release gate. Release v1 only after all accepted core criteria are met. PREP-01 / #85 investigates environment access early; GATE-F2 / #86 reconciles domain requirements and evidence before I23 rehearsal. Minimum-runtime and newer-device execution are independent evidence branches after API/security review, and both must pass.

## F3 – Resilience and extensions

Deferred beyond v1. The owner selected retry/robustness as the first post-core planning priority on 2026-10-26. PLAN-F3 / #87 must select a small opt-in increment and approve its changed contract before implementation. Cache/authentication/monitoring/performance remain separate candidates; split delivery milestones if sizing warrants it.

## F4 – File transfers

Deferred beyond v1. PLAN-F4 / #88 selects use cases and verifies file ownership, cleanup, server support and platform feasibility. Foreground and background deliveries may need separate milestones; neither the entire transfer catalog nor universal background support is promised.

## F5 – Real-time communication

Deferred beyond v1. PLAN-F5 / #89 defines the selected WebSocket lifecycle, backpressure/authentication/shutdown contract and fixtures. Base connection and optional reconnect can become separate deliveries; file transfers are not an automatic dependency.

## F6 – Specialized features and research

Research candidates only. PLAN-F6 / #90 ranks actual product needs and sets bounded feasibility and stop/go criteria. Split unrelated security/networking delivery milestones only after evidence and a scope decision.

## Dependencies and approval

Endpoint contracts precede interceptors/authentication/retry. Error taxonomy and response wrappers precede API stabilization. Cancellation/clocks precede retry/refresh. Redaction precedes detailed diagnostics. OS matrices/entitlements precede background/Bonjour/multicast. Security review precedes pinning/mTLS/OIDC.

Break domain epics into separate testable tasks before Ready. F0 acceptance covers included/deferred CORE subrequirements. Extensions cannot enter v1 without updated scope and impact assessment. Close phase gates only with links to actual evidence.
