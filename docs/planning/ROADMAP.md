# Roadmap

Current rehearsal, 2026-10-31: #86 and nine selected-core epics are Done through PR #134/main 41238957032. [Formal rehearsal](RELEASE_REHEARSAL_2026-10-31.md) is executed and awaits its PR/main acceptance; only #64/#27 remain open in F2. #132/#29 remain a separate mandatory publication lane. No release/tag, production acceptance or F3 implementation is authorized. Earlier dated progress retains its original context.


Current reconciliation, 2026-10-31: #62 and revised #63 are Done. [GATE-F2 review](F2_REVIEW.md) reconciles the 79 stable core IDs and recorded owner F2-only resource disposition; its PR/main acceptance precedes eligible core epic closures. #27 remains open for formal #64, then F2 closure. #132/#29 remain separate publication blockers; #87/draft PR #111 is planning, not F3 implementation authorization. Dated progress notes below preserve their original state.


Current owner decision, 2026-10-31: [ADR-0013](../decisions/ADR-0013-watch-publication-gate.md) moves only missing physical Watch verification to #132/#29 in the separate “v1.0 – Publication gate” milestone. watchOS 10 support is unchanged. F2 remains open for revised #63, #86 and formal #64/#27; publication and F3 implementation remain unauthorized. [Applicability matrix](F2_PHYSICAL_APPLICABILITY.md) and [work queue](WORK_QUEUE.md) supersede dated access notes below.


No deadlines are set. Phases are gates, not calendar promises. The owner selected HTTP core first: F0 → F1 → F2 completes non-publishing core hardening/rehearsal; a separate publication gate precedes the first stable release. F3–F6 are optional later deliveries, outside v1.0. Repository/package: SwiftNetworkKit; product/module: NetworkKit, with one library module. See [v1 scope](V1_SCOPE.md) and [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md).

Current review: [TLS-01 native macOS rejection](NATIVE_TLS_REJECTION.md), a bounded P1 regression at Order 20.75 under #25. Preparation PR #103 is accepted through main run 40550211780; #62/#63 execution remains blocked by readiness/access. TLS-01 supplies local native negative evidence without selecting a new TLS product feature. F2 remains open for complete native/platform/resource and explicit owner-risk gates; no new milestone or support/tool change is selected.

## F0 – Architecture and decisions

Rights, v1 scope, platforms/toolchain, APIs, concurrency, security, and CI were accepted together on 2026-10-19 in [ADR-0009](../decisions/ADR-0009-f0-approval-no-implementation.md). At that time, implementation was not authorized. All eight decision issues are complete. ADR-0010 and PR #65 completed OPS-01 / #30; F0 is closed. The owner subsequently instructed implementation to begin on 2026-10-20; ADR-0012 and closed START-00 / #41 record this separately. I01 starts F1 with the package baseline.

## F1 – HTTP core

The initial HTTP slice is delivered through I01–I10. I11 / #52 records the [F1 contract and evidence review](F1_REVIEW.md), including cumulative real platform CI, typed/raw parity, known limits and phase closure. F1 acceptance requires successful I11 PR/main checks; the issue records the actual outcome. Open domain epics retain their remaining v1 work in F2.

## F2 – Production hardening and v1 gate

[Preliminary F2 requirement reconciliation](F2_REVIEW.md) maps 79 source bullets across the ten core epics to accepted scope, evidence and explicit deferrals. TLS-01 #104 is accepted through main run 40556606300. The connected iPhone builds/signs successfully, but tool-hosted device testing is unsupported; PREP-02 #113 adds the required app-host route before #63 execution. This preparation closes no phase/epic; #62/#63 actual target/HTTPS/resource evidence still precedes #86, #64 and the separate #29 release decision.

Current review, 2026-10-27: I20, RES-01 and preparation PR #103 are accepted; main run 40550211780 confirms the preparation baseline. TLS-01 / #104 is a selected P1 regression at Order 20.75, adding independently executable native macOS untrusted-certificate rejection. The original fixture/opaque iOS incident uncertainties remain recorded. #62/#63 execution remains Blocked by actual minimum/physical/controlled-HTTPS readiness. #86 requires #104 plus native/resource evidence, with explicit owner disposition before #29. No new milestone or product feature is selected.

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

## Public HTTPS route — 2026-10-27

[NET-01 #115](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/115), Order 20.95, uses owner-selected [public native HTTPS checks](PUBLIC_HTTPS_VERIFICATION.md) through the existing client/host. No paid/private test environment is provisioned. Public observations, independent certificate conditions and platform-specific error mapping remain distinct from controlled server counters, minimum/other-device/resource and final release evidence. #62/#63/#86 stay open for their remaining criteria.

## Native lifecycle/storage follow-up — 2026-10-28

NET-01 #115 is accepted on main 40644612904. [NET-02 #117](NATIVE_LIFECYCLE_STORAGE.md) adds actual Mac/iPhone cancellation, shutdown/session ownership and isolated cookie observations; local full suite 12/12 passed and PR #118/main 40745209513 are accepted. [Minimum-runtime candidates and authorization](MINIMUM_RUNTIME_ACCESS_2026-10-28.md) remain a separate #62 route: authenticated imports and [four minimum simulator regression results](MINIMUM_RUNTIME_EXECUTION_2026-10-28.md) passed locally at 215/215 each; PR/main acceptance remains pending. Earlier iOS migration timeouts are retained. macOS 14 and separate native/resource scenarios remain open. All unproved F2/native/resource/archive/release criteria remain open.
