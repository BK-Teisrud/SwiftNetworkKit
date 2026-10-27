# Requirements traceability and initial backlog

Original planning baseline: 20 domain epics, seven decision issues, and three governance/release issues. The table below preserves the original domain classification/phase allocation, not live completion. I01–I16 are delivered; I01–I10 implement the initial HTTP slice; [F1 review](F1_REVIEW.md) accounts for delivered work and open domain epics continuing in F2. See the [GitHub register](GITHUB_REGISTER.md) for live links.

| ID | Requirement / task | Classification | Phase |
| --- | --- | --- | --- |
| DEC-01 | Accepted: Minimum OS and Swift/Xcode/SDK matrix (ADR-0004) | governance | F0 |
| DEC-02 | Accepted: V1 scope and package/product/module naming (ADR-0003) | governance | F0 |
| DEC-03 | Accepted: Rights holder and proprietary policy (ADR-0002) | governance | F0 |
| DEC-04 | Accepted: HTTP/response/error contract (ADR-0005) | governance | F0 |
| DEC-05 | Accepted: Session ownership, 30/60 limits, concurrency, shutdown (ADR-0006) | governance | F0 |
| DEC-06 | Accepted: Security/authentication/storage/network policy (ADR-0007) | governance | F0 |
| DEC-07 | Accepted: Four PR platforms, official tools, standard runners, no paid add-ons (ADR-0008) | governance | F0 |
| NK-01 | HTTP and requests | core | F1 |
| NK-02 | Endpoints and URL construction | core | F1 |
| NK-03 | Responses and data handling | core | F1 |
| NK-04 | Error handling | core | F1 |
| NK-05 | Authentication | extension | F3 |
| NK-06 | Security and TLS | extension | F6 |
| NK-07 | Retries and resilience | extension | F3 |
| NK-08 | Caching | extension | F3 |
| NK-09 | File transfers | extension | F4 |
| NK-10 | WebSocket and real-time communication | extension | F5 |
| NK-11 | TCP, UDP, and local networking | research | F6 |
| NK-12 | Network status | extension | F3 |
| NK-13 | Logging and observability | core | F2 |
| NK-14 | Concurrency and lifecycle | core | F2 |
| NK-15 | Configuration | core | F1 |
| NK-16 | Testing and mocking | core | F1 |
| NK-17 | Performance and optimization | extension | F3 |
| NK-18 | Privacy and data protection | core | F2 |
| NK-19 | Apple platform integration | extension | F4 |
| NK-20 | Developer experience and API design | core | F2 |
| GATE-00 | F0 planning accepted; implementation unauthorized (ADR-0009) | governance | F0 |
| REL-01 | Verify the first stable core release | governance | F2 |
| OPS-01 | Verify GitHub setup and the future team transition | governance | F0 |

## Approved scope

[V1_SCOPE.md](V1_SCOPE.md) defines included/deferred scope across all 20 domains. Keep epics open until selected work is delivered. ADR-0005 defines the HTTP contract; ADR-0006 the lifecycle; ADR-0007 the security/network policy. Concrete verification tasks are still needed before Ready.

## Before development

Decompose feature families into testable issues with contracts, test plans, and specification references. Explicitly identify exclusions. Use native dependencies where available and body links regardless; links do not enforce merges. Planning does not mean delivery.

## Concrete implementation queue

I01–I23 are native subissues with criteria and dependencies; see [WORK_QUEUE.md](WORK_QUEUE.md). START-00 / #41 was closed after the owner instruction on 2026-10-20 (ADR-0012). I01 starts implementation; later tasks still require resolved dependencies and Ready checks. Decomposition itself did not authorize code. planning.json is the original seed rather than live status; work-queue.json describes the concrete queue.

## Rolling planning review

The [2026-10-26 audit](PLAN_REVIEW_2026-10-26.md) adds PREP-01 / #85, GATE-F2 / #86 and PLAN-F3–F6 / #87–#90. The owner selected retry/robustness as the first post-core planning priority. Future NK domains remain deferred; concrete extension implementation slices require selected contracts and a new scope decision. Follow PROJECT_MANAGEMENT.md at every task transition, not only weekly.

## First retry candidate decomposition — 2026-10-27

PLAN-F3 #87 now proposes [a bounded retry increment](RETRY_INCREMENT_PLAN.md) and [ADR-0013](../decisions/ADR-0013-opt-in-retry-proposal.md). #106–#110 define decision, eligibility/delay, shared operation integration, native/resource verification and final API/evidence review. Candidate tasks remain Backlog/P2/EXTENSION; no implementation IDs until selection. #106 requires actual owner approval/use-case confirmation; technical candidates also require #86. F2 minimum/physical/native evidence remains the delivery priority.
