# Roadmap

No deadlines are set. Phases are gates, not calendar promises. The owner selected HTTP core first: F0 → F1 → F2 leads to the first stable release. F3–F6 are optional later deliveries, outside v1.0. Repository/package: SwiftNetworkKit; product/module: NetworkKit, with one library module. See [v1 scope](V1_SCOPE.md) and [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md).

## F0 – Architecture and decisions

Rights, v1 scope, platforms/toolchain, APIs, concurrency, security, and CI were accepted together on 2026-10-19 in [ADR-0009](../decisions/ADR-0009-f0-approval-no-implementation.md). At that time, implementation was not authorized. All eight decision issues are complete. ADR-0010 and PR #65 completed OPS-01 / #30; F0 is closed. The owner subsequently instructed implementation to begin on 2026-10-20; ADR-0012 and closed START-00 / #41 record this separately. I01 starts F1 with the package baseline.

## F1 – HTTP core

Satisfy selected endpoint/request/response/error/configuration contracts with deterministic tests and real platform CI.

## F2 – Production hardening and v1 gate

Privacy/logging, cancellation, required authentication boundaries under DEC-04/06, security review, DocC, and a documented release gate. Release v1 only after all accepted core criteria are met.

## F3 – Resilience and extensions

Explicitly selected retry/cache/authentication/monitoring/performance modules with policy and concurrency tests.

## F4 – File transfers

Upload/download/progress/cleanup and documented per-platform background limits.

## F5 – Real-time communication

Verified WebSocket state, backpressure, reconnect, authentication, and shutdown.

## F6 – Specialized features and research

Only for approved product needs, with technical validation, entitlements, and separate security review.

## Dependencies and approval

Endpoint contracts precede interceptors/authentication/retry. Error taxonomy and response wrappers precede API stabilization. Cancellation/clocks precede retry/refresh. Redaction precedes detailed diagnostics. OS matrices/entitlements precede background/Bonjour/multicast. Security review precedes pinning/mTLS/OIDC.

Break domain epics into separate testable tasks before Ready. F0 acceptance covers included/deferred CORE subrequirements. Extensions cannot enter v1 without updated scope and impact assessment. Close phase gates only with links to actual evidence.
