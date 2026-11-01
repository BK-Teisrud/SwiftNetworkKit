# Requirements traceability and initial backlog

## I26 native/resource execution — 2026-11-01

I25 #108 is accepted through PR #139/main run 41287067291. I26 #109 adds [native retry/resource evidence](NATIVE_RETRY_VERIFICATION.md): actual Mac URLSession contacts, TLS exclusion, public HTTPS ownership composition and bounded release measurements. Candidate CI and target-applicability review remain pending; no new minimum/physical pass or publication acceptance is inferred. Existing #109/#110 and #132/#29 retain their distinct gates; no new feature issue or broad refactor is justified.

## I25 execution — 2026-11-01

I24 #107 is accepted through PR #138/main run 41250907636 (223 Mac tests, four 220-test simulator runs, 19 helpers). I25 #108 integrates explicit per-call retry inside one admitted operation/deadline; see [integration evidence](RETRY_INTEGRATION.md). I26/I27 remain dependent native/resource/API review tasks. No extra issue, dependency, broad refactor or release scope is justified by this change. This supersedes earlier I24-active/no-loop status below; required I25 PR/main acceptance is pending.

## Current F3 execution — 2026-10-31

Planning #87/#106 is accepted through PR #111/main `25e0d52b8316251bb6592d075caead9b05ed9edd`, verified run 41248255517. The owner explicitly authorized implementation of I24–I27 under ADR-0014; START-F3 #137 is completed. I24 #107 implements pure eligibility/delay decisions; I25–I27 remain dependent work. No retry transport loop, publication or other extension is delivered by I24. This status supersedes earlier no-code holds below. Existing four slices remain sufficient; no additional feature issue or broad refactor is justified.

## Complete retry contract approval — 2026-10-31

The owner approves the complete [ADR-0014 contract](../decisions/ADR-0014-opt-in-retry-proposal.md) and expressly withholds code. #87/#106 await planning PR/main acceptance; [START-F3 #137](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/137) separately blocks selected I24–I27 (#107–#110). Existing F3 is now “F3 – Bounded read retries”; open unselected domain catalogs #12/#14/#15/#19/#24 stay outside this delivery milestone. No product code, default behavior, dependency, release/version/date or publication authorization. #132/#29 and accepted F2 remain unchanged.


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

## Historical selection refresh before complete approval — 2026-10-31

F2 is closed; #87/#106 review Proposed [ADR-0014](../decisions/ADR-0014-opt-in-retry-proposal.md) and the [bounded retry plan](RETRY_INCREMENT_PLAN.md). Existing #107–#110 remain Backlog without I identifiers or implementation authorization. Owner selections: general safe app-data reads, per-call bodyless GET/HEAD one retry for exact allowlist, 250–500 ms jitter/30-second cap, auth preparation once and diagnostic attempt count only. Full contract/code start remain separate decisions. Preserve all core/host/native rows and #132/#29 publication gates; no duplicate task or new milestone.
