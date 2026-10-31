# NET-04 native storage and TLS controls

Tracking: #126, with native execution owned by #62 and physical evidence by #63. This investigation changes verification tools, not the production SDK or approved timeout defaults.

## Findings and corrections

The original watchOS 10 simulator failures are retained in [minimum native execution](MINIMUM_NATIVE_EXECUTION_2026-10-31.md). Independent Foundation sessions and NetworkKit app-managed sessions both failed to retain or echo the synthetic automatic cookie on that destination. A direct HTTP 200 seed and an explicitly assigned ephemeral store did not restore that behavior. An explicit synthetic Cookie header was echoed through both clients. Therefore, a universal positive automatic-storage assumption was incorrect; no SDK defect or platform-wide guarantee has been established.

The revised app-managed test compares echo, retention and deletion with an independent Foundation reference on the same destination. A separate explicit-header test preserves a positive fixture check. Strict cookie absence checks execute independently. Matching absent automatic storage is recorded as such, never as successful automatic persistence.

The private Foundation credential store contained the synthetic credential, but the Watch automatic challenge returned 401 with zero authorization headers. A fresh Foundation session with an explicit synthetic header returned 200 with exactly one authorization header. The revised control checks both observations separately. NetworkKit still does not support injecting a credential store. A compiled negative control with the wrong synthetic credential failed as expected.

## TLS configuration and limits

Certificate acceptance/rejection semantics now use the approved production defaults: 30 seconds of inactivity and 60 seconds total, with a two-minute outer test guard. Other ordinary public probes retain 5/10-second limits; deliberately short deadline assertions are unchanged. This validates the selected production operating context. It does not convert the earlier 5/10-second failures into passes or explain their cause. Independent default-budget Foundation and SDK self-signed checks both rejected the certificate in less than five seconds, which does not establish that the earlier timeout was caused by the shorter budget. System trust handling and exact certificate-error assertions remain intact.

With these working-tree sources, watchOS 10.0 and tvOS 17.0 each passed all 21 declarations / 44 parameter cases, with no failures, skips or expected failures. Task-owned simulators were shut down successfully. Exact source hashes and environment details are in the [sanitized evidence record](evidence/NET04_NATIVE_CONTROLS_2026-10-31.json). These results still require normal PR/main acceptance.

## Physical Watch applicability

[Apple TN3135](https://developer.apple.com/documentation/technotes/tn3135-low-level-networking-on-watchos) restricts low-level networking in ordinary Watch applications. Simulator success of the seven NWListener-based local declarations does not establish their applicability to the physical Watch host. The physical Watch plan runs the 215 shared regression tests and explicitly selects the 14 public HTTPS declarations. Record the seven local declarations as outside this host's supported physical scope, not as passed or silently skipped. Do not add audio/VoIP capabilities to bypass this restriction. Physical storage, foreground/background, network transitions and bounded resource evidence remain separately owned by #63.

No F2 gate, minimum platform, publication requirement or owner risk decision is waived by this investigation.

## Physical iPad result

The owner-authorized iPad Pro (11-inch, 3rd generation), iPadOS 27.2 / 24B119, passed all 215 app-hosted regression declarations. Native execution passed 20 of 21 declarations with zero skips or expected failures. The raw self-signed case observed SDK NSURLErrorDomain/-1200; its independent Foundation control also returned -1200 but received no server-trust challenge. The strict certificate oracle therefore correctly failed. This is inconclusive certificate-rejection evidence, not an accepted trust result or proven SDK defect. No automatic rerun occurred, and the temporary test host was removed successfully. See [iPad execution](evidence/F2_IPAD_NATIVE_EXECUTION_2026-10-31.json).

Both unsigned schemes also built successfully for generic physical watchOS and tvOS destinations. These builds establish compilation only. Device pairing, compatible profiles, signing permission and actual execution remain separate prerequisites.
