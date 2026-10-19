# Readiness review before implementation

Date: 2026-10-19. **Preparations are approved and complete; implementation is still not authorized.** ADR-0009 approves planning. The [start gate #41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41) stays open until separate explicit owner authorization.

## Ready foundations

- Rights holder Teisrud Development AS, proprietary policy, HTTP-core scope, and naming/module boundaries are decided.
- OS 17/14/10/17, Xcode 26.3+, tools 6.2, and Swift 6 are approved.
- HTTP/lifecycle/security/CI contracts are versioned; deferred scope is explicit.
- I01–I23 have criteria, test requirements, parent epics, and native blocked-by links. The [work queue](WORK_QUEUE.md) gives the recommended serial order.
- Main requires PRs without bypass. A limited creation exception permits admins to create new v* tags; update/deletion have no bypass. Immutable releases are enabled. Web sign-off is disabled with specific approval because no DCO is used.
- The project has one status model, a sorted work queue, a completed view, and verified import/status transitions.
- No product code, manifest, test code, prototypes, workflows, release tags, or releases exist.

## Outstanding items

| Item | Actual status | Required resolution |
| --- | --- | --- |
| Implementation | Not authorized; #41 open | Before I01 or any code/workflow work |
| Minimum-OS environments | Access unconfirmed; newer runtimes inventoried | Before release; I21 requires evidence or explicit revision of support |
| Physical devices | Owner reports all types on current updates; exact versions unverified | I22 before testing/release |
| Contact address | Owner stated, in translation, “no address yet”; none published | Before offering private licensing/contribution agreements |
| Account security | Owner confirms 2FA; no codes/keys collected | Ongoing maintenance; no independent account audit performed |
| Real CI | Planned; no workflows/checks exist | I06 after authorization; require checks only after verified real runs |
| API symbols | Bounded SDK checks in PLATFORM_MATRIX; inspect actual new overloads per task | Before the relevant task becomes Ready |

The missing contact address and older test environments do not imply full release readiness. Internal implementation may be approved separately without purchases/upgrades. Release remains blocked until actual evidence exists. If minimum environments cannot be obtained, the owner must explicitly revise support; newer simulators are not substitutes.

## After later authorization

Record the owner's exact statement/date/scope on #41, close the gate, and triage I01 to Ready. Then select the lowest Order with closed blockers and satisfied Ready criteria. Complete one task at a time with a PR, tests, and documentation. A completed plan or high priority never closes the start gate automatically. Separate release authorization is required before tagging/publication.

F0 and OPS-01 were completed through PR #65. #41 belongs to F1, preserving the distinction between completed preparation and authorized development. English GitHub content and Norwegian conversations follow [ADR-0011](../decisions/ADR-0011-language-policy.md); this language decision does not authorize code.
