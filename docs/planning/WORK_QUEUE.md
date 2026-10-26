# Work sequence before and after implementation authorization

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
| 21 | [[I21] Obtain and document minimum-OS runtime evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/62) | #23 | #60, #85 |
| 22 | [[I22] Run representative tests on physical Apple devices](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/63) | #23 | #60, #85 |
| 22.5 | [[GATE-F2] Reconcile v1 requirements, domain epics, and release evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/86) | #29 | #59, #60, #61, #62, #63, #100 |
| 23 | [[I23] Rehearse the v1 release without publishing](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/64) | #27 | #63, #86 |
| 24 | [REL-01: Actual v1 release gate](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/29) | Governance | #64 and selected core epics |

Current review: I20 / #61 is accepted through PR #101 and main run 40408266400. [RES-01 / #100](REPEATED_CALL_MEMORY.md) attributes the observed local RSS trend before serial I21 work. It remains open until its own PR/main checks pass. Expiry-dependent runtime retention still requires target resource evidence and explicit #86/#29 owner disposition. #62/#63 retain minimum/physical/native HTTPS access gaps.

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
