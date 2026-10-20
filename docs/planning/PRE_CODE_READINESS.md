# Readiness review before implementation

I03 foundation evidence: immutable configuration snapshots and internal transport/monotonic clock seams are implemented; 29 local tests passed. See [configuration review](CONFIGURATION.md). I04 adds endpoint/URL construction; I05 adds request encoding and header precedence with 64 passing local tests. See [request review](REQUEST_ENCODING.md). The HTTP client, enforced deadlines, and platform-wide verification remain outstanding.

Updated: 2026-10-20. **The owner has instructed implementation to begin; START-00 / #41 is closed.** [ADR-0012](../decisions/ADR-0012-implementation-start.md) records the instruction in context. I01 adapts the owner's Xcode starter into the approved package baseline. F0 remains the historical planning approval.

## Ready foundations

- Rights holder Teisrud Development AS, proprietary policy, HTTP-core scope, and naming/module boundaries are decided.
- OS 17/14/10/17, Xcode 26.3+, tools 6.2, and Swift 6 are approved.
- HTTP/lifecycle/security/CI contracts are versioned; deferred scope is explicit.
- I01–I23 have criteria, test requirements, parent epics, and native blocked-by links. The [work queue](WORK_QUEUE.md) gives the recommended serial order.
- Main requires PRs without bypass. A limited creation exception permits admins to create new v* tags; update/deletion have no bypass. Immutable releases are enabled. Web sign-off is disabled with specific approval because no DCO is used.
- The project has one status model, a sorted work queue, a completed view, and verified import/status transitions.
- The manifest, library/test targets, and I02 value/error contract tests now exist. The HTTP client and pipeline remain unimplemented. No workflows, tags, or releases exist.

## Outstanding items

| Item | Actual status | Required resolution |
| --- | --- | --- |
| Implementation | Authorized for the approved HTTP core; #41 closed | Follow the ordered tasks and existing scope/contracts |
| Minimum-OS environments | Access unconfirmed; newer runtimes inventoried | Before release; I21 requires evidence or explicit revision of support |
| Physical devices | Owner reports all types on current updates; exact versions unverified | I22 before testing/release |
| Contact address | Owner stated, in translation, “no address yet”; none published | Before offering private licensing/contribution agreements |
| Account security | Owner confirms 2FA; no codes/keys collected | Ongoing maintenance; no independent account audit performed |
| Real CI | Planned; no workflows/checks exist | I06 after authorization; require checks only after verified real runs |
| API symbols | Bounded SDK checks in PLATFORM_MATRIX; inspect actual new overloads per task | Before the relevant task becomes Ready |

The missing contact address and older test environments do not imply full release readiness. Internal implementation may be approved separately without purchases/upgrades. Release remains blocked until actual evidence exists. If minimum environments cannot be obtained, the owner must explicitly revise support; newer simulators are not substitutes.

## Implementation workflow

The owner instruction is recorded on #41 and in ADR-0012; I01 passed Ready triage. Continue to select the lowest Order with closed blockers and satisfied Ready criteria. Complete one task at a time with a PR, tests, and documentation. A completed plan or high priority never closes the start gate automatically. Separate release authorization is required before tagging/publication.

F0 and OPS-01 were completed through PR #65. #41 belongs to F1 and records the later authorization separately. English GitHub content and Norwegian conversations follow [ADR-0011](../decisions/ADR-0011-language-policy.md); the language decision itself did not authorize code.
