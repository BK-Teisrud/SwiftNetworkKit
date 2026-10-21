# Work sequence before and after implementation authorization

**Current: implementation authorized on 2026-10-20; [START-00 / #41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41) is closed.** [ADR-0012](../decisions/ADR-0012-implementation-start.md) records the instruction. I01 established the package baseline. I02 implements foundational HTTP values/errors and their tests; I03 adds isolated configuration snapshots and internal transport/clock seams; I04 adds safe endpoint/URL construction and shared raw-URL validation; I05 adds buffered request encoding, call headers/options, and raw preparation; I06 adds real platform/source/DocC CI and required quality-gate enforcement; I07 adds buffered response strategies and per-call status validation; I08 adds the internal owned/borrowed URLSession adapter; I09 adds shared HTTPS/origin/loopback policy and per-operation redirect/trust delegates; I10 connects typed/raw calls to the public shared HTTP pipeline. I11 verifies the F1 contract/evidence boundary; see [F1 review](F1_REVIEW.md) and #52 for actual acceptance. I12 follows after acceptance.

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
| 17 | [[I17] Complete the test matrix and regression suite](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/58) | #23 | #57 |
| 18 | [[I18] Complete API review, DocC, and integration guides](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/59) | #27 | #58 |
| 19 | [[I19] Conduct the v1 security and privacy review](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/60) | #25 | #59 |
| 20 | [[I20] Measure baseline resource use and package quality](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/61) | #27 | #60 |
| 21 | [[I21] Obtain and document minimum-OS runtime evidence](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/62) | #23 | #61 |
| 22 | [[I22] Run representative tests on physical Apple devices](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/63) | #23 | #62 |
| 23 | [[I23] Rehearse the v1 release without publishing](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/64) | #27 | #63 |
| 24 | [REL-01: Actual v1 release gate](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/29) | Governance | #64 and selected core epics |

## Why this sequence

Values/configuration precede URL/request encoding. Real CI follows early meaningful tests and precedes further transport work. Response handling, transport, and network policy form a vertical HTTP slice before the F1 gate. Then verify timing, lifecycle, authentication, and privacy together. API/DocC and security review precede resource measurements and actual runtime/device evidence. Rehearsal publishes nothing.

Every issue includes acceptance criteria and tests. Relevant tests/docs accompany each implementation PR; they are not deferred to I17/I18, which are consolidated reviews. Native blockers/subissues are configured but do not independently enforce merges.

I21 may investigate access to older test environments as preparation without code; actual product tests require implementation. Missing access blocks release. If evidence cannot be obtained, explicitly revisit support rather than automatically downgrading devices or buying equipment.

F3–F6 remain deferred. Their epics have no Order and require a new scope decision. Parent epics may span phases; individual subtasks' milestones define delivery requirements.
