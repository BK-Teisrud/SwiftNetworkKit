# Risk register

Owner of initial open risks: @BK-Teisrud. Review weekly during triage and at phase gates.

| ID | Risk / likelihood / impact | Mitigation and trigger | Gate |
| --- | --- | --- | --- |
| R1 | Overengineering / high / high | ADR-0003/V1_SCOPE defines the HTTP core and one library module; new modules require a need and decision. Unjustified scope growth → stop and reassess. | F0 |
| R2 | OS differences / high / high | ADR-0004/PLATFORM_MATRIX sets minimums/tools. Verify symbols, guards, runtime/device behavior; simulator builds alone are insufficient. | F0–F4 |
| R3 | Duplicate retry side effects / medium / high | No unsafe retry by default; require idempotency and bounded attempts. | F3 |
| R4 | Credentials in logs/redirects/cache / medium / critical | Negative redaction/isolation/redirect tests and private security review. | F2 |
| R5 | Refresh storms/deadlocks / medium / high | Single-flight and concurrency/cancellation tests before an authentication module. | F3 |
| R6 | Stale/leaked cache / medium / high | HTTP semantics, account isolation, deletion, explicit offline policy. | F3 |
| R7 | Unsupported background promises / high / high | Entitlements, host-app responsibilities, physical evidence per platform. | F4 |
| R8 | Solo-maintainer review bottleneck / high / medium | PR audit trail, low WIP, team profile once a reviewer exists. | All |
| R9 | Use/contributions without rights / medium / high | DEC-03: Teisrud Development AS, proprietary policy. LICENSE/ADR-0002 clarify permission and GitHub exceptions. Written agreements before external content contributions/distribution. | F0 and release |
| R10 | False confidence from passing CI / medium / high | No dummy checks; real matrix and release evidence. | F1 |
| R11 | Changing GitHub rules/tools / medium / medium | Quarterly settings review, Actions limits, least privilege. | All |

Accept residual risks in the relevant issue, with an ADR for lasting deviations. Critical security findings block release until fixed or the affected scope is explicitly removed with rationale.

## Concrete outstanding release work

R2: Minimum-OS environments are unconfirmed. PREP-01 / #85 investigates access now; I21 / #62 still blocks release; newer devices/runtimes are not substitutes. See TEST_ENVIRONMENTS.md.

R9: No contact address exists. Do not offer private licensing/contribution processes until an appropriate channel is established. This does not block separately authorized internal implementation.

R11: Admins can change rulesets even without main/update/deletion bypasses. No technical protection against the account owner is guaranteed. The owner confirms 2FA; no independent account audit was performed.

R10: I17 / #58 consolidates an evidence ledger; GATE-F2 / #86 reconciles all selected v1 domain criteria before rehearsal. Native wire, scripted transport, minimum-runtime and physical-device evidence must remain distinct.

Planning risk: broad deferred domains can hide missing contracts or create premature commitments. PLAN-F3–F6 / #87–#90 require use cases, explicit exclusions, feasibility, approved contracts and bounded issues. Retry is the first post-core planning priority; other F3 candidates are not implicitly selected.

PREP-01 assessment, 2026-10-26: older runtimes are absent locally and external access is unknown; physical model/OS/build inventory is also unknown. See [environment readiness](ENVIRONMENT_READINESS.md) for evidence, owner actions and native-trust/device scenarios. #62/#63 retain these gaps; preparation does not close them. Xcode development-host requirements and macOS 14 execution must be handled separately.
