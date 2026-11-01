# Work sequence before and after implementation authorization

## I25 execution — 2026-11-01

I24 #107 is accepted through PR #138/main run 41250907636 (223 Mac tests, four 220-test simulator runs, 19 helpers). I25 #108 integrates explicit per-call retry inside one admitted operation/deadline; see [integration evidence](RETRY_INTEGRATION.md). I26/I27 remain dependent native/resource/API review tasks. No extra issue, dependency, broad refactor or release scope is justified by this change. This supersedes earlier I24-active/no-loop status below; required I25 PR/main acceptance is pending.

## Current F3 execution — 2026-10-31

Planning #87/#106 is accepted through PR #111/main `25e0d52b8316251bb6592d075caead9b05ed9edd`, verified run 41248255517. The owner explicitly authorized implementation of I24–I27 under ADR-0014; START-F3 #137 is completed. I24 #107 implements pure eligibility/delay decisions; I25–I27 remain dependent work. No retry transport loop, publication or other extension is delivered by I24. This status supersedes earlier no-code holds below. Existing four slices remain sufficient; no additional feature issue or broad refactor is justified.

## Complete retry contract approval — 2026-10-31

The owner approves the complete [ADR-0014 contract](../decisions/ADR-0014-opt-in-retry-proposal.md) and expressly withholds code. #87/#106 await planning PR/main acceptance; [START-F3 #137](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/137) separately blocks selected I24–I27 (#107–#110). Existing F3 is now “F3 – Bounded read retries”; open unselected domain catalogs #12/#14/#15/#19/#24 stay outside this delivery milestone. No product code, default behavior, dependency, release/version/date or publication authorization. #132/#29 and accepted F2 remain unchanged.


## Accepted F2 closeout — 2026-10-31

F2 is CLOSED after PR #135/main `cc654ab5faadc0fc7fe00d7ad238b2e3ed5a997c`, [run 41242130528](https://github.com/BK-Teisrud/SwiftNetworkKit/actions/runs/41242130528), with full-log verification of 218 Mac tests, four 215 simulator suites, 19 helpers and four manual-host provenance checks without failure/restart markers. #64/#27 are Done; direct item lists and GraphQL verify no open F2 issues/PRs. [Closeout evidence](F2_CLOSEOUT_2026-10-31.md) records the milestone summary-counter disagreement and actual verified states.

Original candidate evidence files retain their submission-time pending flags and exact executed SDK/platform/failure limits. The owner resource approval is F2-only. #132 physical Watch and #29 actual workload/device-memory/security/publication decisions remain mandatory in their separate milestone, with support unchanged. No release/tag, production suitability or F3 implementation is authorized.

PLAN-F3 #87/#106 are In Review; the complete contract is owner-approved, but START-F3 #137 withholds implementation. I24–I27 are Blocked. Planning PR/main acceptance and a separate explicit code-start instruction remain required. Closed F2 is not publication or extension authorization.

## Next planning and publication lanes

1. #87 is Ready for planning only. Review bounded retry/draft PR #111 against accepted F2, answer contract questions and prepare its delivery backlog. Obtain explicit scope/start approval before F3 code.
2. #132 stays Blocked before #29 publication; actual physical Watch and owner workload/device-memory/security/publication decisions remain mandatory. Do not reopen F2 or mark Watch passed merely to publish.
3. Preserve closed-phase evidence and historical failure limits. No new milestone, dependency, paid service, support change or production feature is selected by closeout.

Stop whenever a GitHub run is pending and await the owner's instruction to continue. Do not poll CI or continue independent work across that stop, as reconfirmed on 2026-10-31. Conversation stays Norwegian; repository and project content stay English.

**Current: implementation authorized on 2026-10-20; [START-00 / #41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41) is closed.** [ADR-0012](../decisions/ADR-0012-implementation-start.md) records the instruction. I01 established the package baseline. I02 implements foundational HTTP values/errors and their tests; I03 adds isolated configuration snapshots and internal transport/clock seams; I04 adds safe endpoint/URL construction and shared raw-URL validation; I05 adds buffered request encoding, call headers/options, and raw preparation; I06 adds real platform/source/DocC CI and required quality-gate enforcement; I07 adds buffered response strategies and per-call status validation; I08 adds the internal owned/borrowed URLSession adapter; I09 adds shared HTTPS/origin/loopback policy and per-operation redirect/trust delegates; I10 connects typed/raw calls to the public shared HTTP pipeline. I11 verifies the F1 contract/evidence boundary; see [F1 review](F1_REVIEW.md) and #52 for actual acceptance. I12 adds per-call cancellation/terminal arbitration and the monotonic total budget; see [timing evidence](CANCELLATION_AND_BUDGET.md). I13 adds explicit shutdown, operation registration and concurrent-call verification; see [lifecycle evidence](SHUTDOWN_AND_CONCURRENCY.md). I14 adds the [bounded authentication-header provider](AUTHENTICATION_PROVIDER.md), with app-owned login/token storage and no refresh/replay. I15 adds [optional sanitized diagnostics](SANITIZED_DIAGNOSTICS.md), disabled by default with a fixed metadata allowlist. I16 verifies [storage profiles against a controlled local server](STORAGE_VERIFICATION.md) and exposes the explicit app-managed borrowed-session selection. I17 accepted the [contract/regression ledger](TEST_EVIDENCE.md) and [test inventory](TEST_INVENTORY.md) through PR #93 / main run 40377796452. I18 reviews the [public API and compiled integration guide](API_REVIEW.md); its acceptance remains recorded in #59. The 2026-10-26 planning review adds PREP-01 / #85 (Order 16.5) as the early planning action (accepted through PR #92 and main run 40374198746; see [environment readiness](ENVIRONMENT_READINESS.md) and #85) and GATE-F2 / #86 (Order 22.5) before rehearsal; see [plan audit](PLAN_REVIEW_2026-10-26.md).

Choose the lowest Order with closed blockers and satisfied Ready criteria. This is a recommended serial sequence for one developer, not a schedule. Reordering requires dependency review rather than new scope. See the [Work Queue](https://github.com/users/BK-Teisrud/projects/6/views/7).

| Order | Task | Parent epic | Dependencies in addition to #41 |
| --- | --- | --- | --- |
| 1 | [[I01] Create the Swift package and test target after authorization](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/42) | #27 | None |
| 2 | [[I02] Define immutable HTTP values, responses, and error taxonomy](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/43) | #11 | #42 |
| 3 | [[I03] Implement configuration snapshots and internal test boundaries](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/44) | #22 | #43 |
| 4 | [[I04] Implement safe endpoint and URL construction](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/45) | #9 | #44 |
| 5 | [[I05] Implement headers and request encoding](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/46) | #8 | #45 |
| 6 | [[I06] Enable real PR CI for all four platform families](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/47) | #23 | #46 |
| 7 | [[I07] Implement response strategies and HTTP status validation](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/48) | #10 | #47 |
| 8 | [[I08] Implement URLSession ownership and the transport adapter](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/49) | #21 | #48 |
| 9 | [[I09] Implement HTTPS, loopback, and redirect policies](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/50) | #25 | #49 |
| 10 | [[I10] Connect typed and raw calls to one secure HTTP pipeline](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/51) | #8 | #50 |
| 11 | [[I11] Verify the initial HTTP core and F1 gate](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/52) | #23 | #51 |
| 12 | [[I12] Implement cancellation and the total time budget](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/53) | #21 | #52 |
| 13 | [[I13] Implement shutdown and concurrency isolation](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/54) | #21 | #53 |
| 14 | [[I14] Implement the bounded authentication-header provider](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/55) | #25 | #54 |
| 15 | [[I15] Implement sanitized optional diagnostics](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/56) | #20 | #55 |
| 16 | [[I16] Verify secure storage and injected-session profiles](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/57) | #25 | #56 |
| 16.5 | [[PREP-01] Prepare minimum-OS and physical-device evidence access](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/85) | #23 | None; planning/inventory only |
| 17 | [[I17] Complete the test matrix and regression suite](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/58) | #23 | #57 |
| 18 | [[I18] Complete API review, DocC, and integration guides](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/59) | #27 | #58, #95 |
| 18.5 | [[BUG-01] Bound native HTTP probe liveness and diagnose main timeouts](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/95) | #23 | None; repair I18 main evidence before acceptance |
| 18.75 | [[QA-01] Review quality and remove stale validation duplication](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/97) | #27 | #59 |
| 19 | [[I19] Conduct the v1 security and privacy review](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/60) | #25 | #59, #97 |
| 20 | [[I20] Measure baseline resource use and package quality](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/61) | #27 | #60 |
| 20.5 | [[RES-01] Diagnose repeated-call RSS growth against native URLSession control](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/100) | #27 | #61 |
| 20.75 | [[TLS-01] Verify native macOS rejection of an untrusted HTTPS certificate](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/104) | #25 | #60 |
| 21 | [[I21] Obtain and document minimum-OS runtime evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/62) | #23 | #60, #85 |
| 22 | [[I22] Run representative tests on physical Apple devices](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/63) | #23 | #60, #85 |
| 22.5 | [[GATE-F2] Reconcile v1 requirements, domain epics, and release evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/86) | #29 | #59, #60, #61, #62, #63, #100, #104 |
| 23 | [[I23] Rehearse the v1 release without publishing](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/64) | #27 | #63, #86 |
| 23.75 | [WATCH-01: physical Watch publication evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/132) | #29; publication milestone | Supported Watch development route; ADR-0013 |
| 24 | [REL-01: Actual v1 release gate](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/29) | Governance | #64 and selected core epics |

Current review: preparation PR #103 is accepted through main run 40550211780. [TLS-01 / #104](NATIVE_TLS_REJECTION.md), Order 20.75, adds independently executable native macOS untrusted-certificate rejection coverage. It blocks #86 while #62/#63 remain Blocked for actual minimum/physical execution. System-trusted positive HTTPS and independent hostname-mismatch evidence are still missing. No support/tool change or owner-risk acceptance is inferred.

## Why this sequence

Values/configuration precede URL/request encoding. Real CI follows early meaningful tests and precedes further transport work. Response handling, transport, and network policy form a vertical HTTP slice before the F1 gate. Then verify timing, lifecycle, authentication, and privacy together. API/DocC and security review precede resource measurements and actual runtime/device evidence. Environment access is investigated early. Minimum-runtime and newer-device execution do not block each other; both must pass the F2 reconciliation. Rehearsal publishes nothing.

Every issue includes acceptance criteria and tests. Relevant tests/docs accompany each implementation PR; they are not deferred to I17/I18, which are consolidated reviews. Native blockers/subissues are configured but do not independently enforce merges.

I21 may investigate access to older test environments as preparation without code; actual product tests require implementation. Missing access blocks release. If evidence cannot be obtained, explicitly revisit support rather than automatically downgrading devices or buying equipment.

## Post-v1 planning queue

| Order | Planning task | Domain coverage | Readiness |
| --- | --- | --- | --- |
| 30 | [PLAN-F3 / #87](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/87) | #14 first; assess #12/#15/#19/#24 separately | Backlog; retry-first planning direction selected, feature contracts pending |
| 40 | [PLAN-F4 / #88](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/88) | #16/#26 | Backlog; transfer use cases/feasibility pending |
| 50 | [PLAN-F5 / #89](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/89) | #17 | Backlog; real-time use case/lifecycle pending |
| 60 | [PLAN-F6 / #90](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/90) | #13/#18 | Backlog; research need/stop-go criteria pending |

These are governance/planning tasks, not authorized extension implementation. F2 retains delivery priority. Future epics have no Order and require new scope decisions; only selected implementation slices receive I identifiers. Parent epics may span phases; individual subtasks' milestones define delivery requirements. Reassess phase boundaries after selection and sizing, without inventing dates.

## F2 closure preparation — 2026-10-27

[Preliminary F2 review](F2_REVIEW.md) indexes the ten core epics and 79 original source bullets without changing approved scope. #104 is accepted through main run 40556606300; #62/#63 actual access/execution and complete HTTPS/resource evidence remain Blocked. Both precede #86; #64 and #27 rehearsal follow, and #29 retains separate release authorization. Preparation does not satisfy those gates. F3 candidate work in other branches remains outside this F2 baseline.

Physical iPhone follow-up: [PREP-02 / #113](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/113) is Ready/P1/CORE/Order 20.9 under #23, blocked by accepted START/I18 and blocking I22. Unsigned/signed builds succeeded, but actual device execution failed before tests because package tool-hosted tests need an app host. See [sanitized evidence](evidence/F2_IPHONE_ATTEMPT_2026-10-27.json). This is the next bounded F2 preparation task; no physical test pass or new host installation is claimed.

PREP-02 implementation: [app-hosted iOS route](IOS_DEVICE_TEST_HOST.md) reuses all shared test files with drift guards and an unsigned device build in ios-core. Its 215-test app-hosted simulator and physical iPhone 17 Pro/iOS 27.2 runs passed; the temporary host was removed. Required PR/main checks remain on #113. Keep #63/#86 open for their complete evidence.

NET-01 / [#115](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/115), P1 CORE Order 20.95 under #23, follows accepted I19/PREP-02 and blocks I22. [Public HTTPS verification](PUBLIC_HTTPS_VERIFICATION.md) supplies bounded native observations without provisioning a paid server; normal CI compiles only. #62 minimum access remains independent and all unproved native/resource/release claims stay open.

NET-01 #115 accepted through PR #116/main 40644612904. NET-02 #117 accepted through PR #118/main 40745209513. NET-02 / [#117](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/117), P1 CORE Order 20.96 under #23, follows accepted NET-01/PREP-02 and blocks I22. [Native lifecycle/storage observations](NATIVE_LIFECYCLE_STORAGE.md) remain separate from full ENV/resource/transition acceptance. [Minimum-runtime leads and authorization](MINIMUM_RUNTIME_ACCESS_2026-10-28.md) belong to independent #62; all three imports and [four separate minimum simulator regression runs](MINIMUM_RUNTIME_EXECUTION_2026-10-28.md) are now verified locally (215/215 each). A fresh iPhone boot completed after earlier migration timeouts. macOS 14 and remaining native/resource requirements remain open; this evidence awaits its PR/main acceptance.

Minimum macOS follow-up, 2026-10-29: [temporary standard GitHub macOS 14 execution route](MACOS14_EXECUTION_ROUTE_2026-10-29.md) prepares an exact-source prebuilt public consumer with the approved builder. Actual macOS 14 results are pending; observe brownout/retirement and stop at CI-dependent points. PR #120 minimum simulator evidence is accepted through main run 40765690271. Remaining native/physical/resource/rehearsal requirements are unchanged.

## Historical planning before complete approval — 2026-10-31

#87 and F3-DEC #106 are planning work. [Proposed ADR-0014](../decisions/ADR-0014-opt-in-retry-proposal.md) and [contract/decomposition](RETRY_INCREMENT_PLAN.md) record owner selections; complete acceptance/code start remain pending. Existing candidates #107/#108/#109/#110 stay Backlog, no I identifiers. Planned order is decision → eligibility/delay contracts → one-operation integration → native/resource verification → increment gate. Preserve the accepted F2 rows and separate #132/#29 publication lane. A documentation PR or generic continue instruction does not authorize retry code.
