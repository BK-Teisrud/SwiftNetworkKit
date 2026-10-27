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

R10 update, 2026-10-26: I18 main run 40382689252 hit the native borrowed-cache test limit and restarted. #95 is P0 and blocks #59/#60 acceptance. See [storage probe follow-up](STORAGE_TIMEOUT_FOLLOWUP.md); no blind rerun or increased suite bound substitutes for phase/liveness evidence.

R10 follow-up acceptance: PR #96 and main run 40390885712 completed without timeout/restart; bounded fixture gaps are addressed. Original internal stall cause remains unproven and monitored under #23/#86. [QA-01](QUALITY_REVIEW_2026-10-26.md) improves actual production-path test coverage and documentation drift controls before I19, without expanding v1.

I19 review: see the [threat model](../security/THREAT_MODEL.md) and [security/privacy dispositions](SECURITY_PRIVACY_REVIEW.md). Controlled HTTPS access is unavailable/unknown, so native system-trust evidence remains open in #62/#63. #61 owns buffered-resource assessment; #64 owns aggregate privacy/archive verification. #86/#29 require explicit owner residual-risk acceptance; none is inferred from the source review.

I20 finding, 2026-10-26: repeated release calls show continuing RSS growth relative to a direct URLSession control. The [baseline and limits](RESOURCE_BASELINE.md) preserve raw results without attributing a leak from RSS alone. RES-01 / #100 is P1 / Order 20.5, blocks #86 and follows #61 acceptance. No stable memory/leak guarantee is made; provisional workload advice does not enforce response size or cap app memory. #62/#63 must assess actual target constraints.

RES-01 attribution: [local controls and disposition](REPEATED_CALL_MEMORY.md) identify expiry-dependent runtime sleep-helper/dispatch retention, not a proven retained NetworkKit operation graph. No production timer/clock rewrite is justified. Rate, timeout and target memory constraints remain material; #62/#63 require actual target evidence and #86/#29 require explicit owner acceptance/mitigation. A falling live heap is not a zero-RSS or leak-free guarantee.

Environment refresh, 2026-10-27: [local device records](ENVIRONMENT_ACCESS_2026-10-27.md) supply model/OS information for iPhone/iPad/Watch, but connection/services and actual compatibility are unverified; TV remains unknown. Minimum runtimes/macOS 14 and controlled HTTPS remain missing. OS newer than the SDK alone is not proof of incompatibility. Owner deferred device connection; #62/#63 remain Blocked. No support/tool change or release-risk acceptance is inferred.

## TLS-01 native negative evidence

The [macOS rejection regression](NATIVE_TLS_REJECTION.md) exercises typed/raw public calls through real system-trust handling against a disposable untrusted certificate with a matching loopback SAN. Local results are certificate-specific; no trust root or verification bypass is installed. This is owned-session macOS evidence only. #62/#63 still require trusted success, independent hostname mismatch and actual minimum/physical environments; #86/#29 retain resource/risk/release gates. #104 acceptance requires its own PR/main checks.

## Proposed resilience increment — 2026-10-27

[ADR-0013](../decisions/ADR-0013-opt-in-retry-proposal.md) and [retry plan](RETRY_INCREMENT_PLAN.md) propose bounded per-call bodyless reads only. #106 owns scope/use-case approval; #107–#110 remain Backlog behind that decision and #86. A GET may still have server side effects, Retry-After dates depend on clock accuracy, and retry waits may amplify existing runtime helper retention/request rate. Require explicit replay semantics, original-budget enforcement, native/resource evidence and privacy-safe diagnostics. No defaults or v1 scope change from planning.
