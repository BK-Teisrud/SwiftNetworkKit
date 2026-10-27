# NET-01 — owner-selected public HTTPS evidence

Date: 2026-10-27. Task #115, parent #23, F2 CORE/P1, Order 20.95. Baseline is accepted main 0aaee219b7ec9f6a81c943ae7f4d4c87a2d9b7f5 (PREP-02). The owner declined setting up a paid/private test environment and explicitly selected public HTTPBingo/BadSSL checks. This changes the fixture/evidence route for the claims below, not SDK scope, platform minima, TLS/storage defaults or release gates. Production Sources and Package.swift are unchanged.

## Sources and execution boundary

[HTTPBingo](https://httpbingo.org/) documents JSON/status/relative-redirect/delay endpoints. [BadSSL](https://badssl.com/) names valid SHA-256, self-signed and wrong-hostname fixtures; its [source](https://github.com/chromium/badssl.com) explains the client-testing purpose. These are third-party public fixtures, not maintainer-controlled servers, permanent APIs or guaranteed availability.

[The separate verification package/runbook](../../Tools/PublicHTTPSChecks/README.md) has only a local package dependency and is manually executed. Eight serialized tests each run typed/raw input (16 main scenarios). Normal root tests and the default device-host scheme do not execute them. A separate PublicHTTPSChecks scheme loads the same source in the existing host. CI compiles the package/test targets and unsigned optional device route only; it never runs public-service tests. No auto retry, hidden skip, subscription, server provisioning, root install or client TLS override.

## Scenario-to-claim map

| ID | Check | Bounded claim / remaining limitation |
| --- | --- | --- |
| PUB-01 | HTTPBingo JSON, typed/raw | Actual native successful HTTPS and JSON value/status; no arbitrary payload logging |
| PUB-02 | HTTPBingo status 204, typed/raw | Explicit empty result with observed 204 |
| PUB-03 | HTTPBingo status 503 decoded as JSON, typed/raw | HTTP status error precedes decoding; no server request-count or no-wire-retry proof |
| PUB-04 | One same-origin relative redirect, typed/raw | Native final success and echoed final HTTPS host/path; no controlled denied-destination counter |
| PUB-05 | BadSSL valid SHA-256, typed/raw | Normal system-trusted success; corroborating positive control for negative certificate fixtures |
| PUB-06 | BadSSL self-signed, typed/raw | Certificate rejection through default public client, with exact certificate identity/corroboration as below |
| PUB-07 | BadSSL wrong.host, typed/raw | Rejection with independently established fixture condition; no generic TLS/connectivity-only acceptance |
| PUB-08 | HTTPBingo delay 3 with 0.25 total budget, typed/raw | Observed totalBudget outcome; not proof of server contact or exact server timing |

No payloads, account credentials or personal query values are sent. Echo bodies remain in memory; only fixed markers/status/numeric codes are published. Raw logs/xcresults remain private because native tools can include device/network metadata. The public operator inherently sees connection metadata. Use bounded small runs, not public load/resource benchmarking.

## Independent certificate witness

The opt-in certificate_witness.py captures public certificate chains without an HTTP payload, then evaluates Apple's local SSL policy with normal system anchors and no network fetching. The observed valid and wrong-host fixtures supplied the same public leaf fingerprint; the captured wrong-host chain validated for sha256.badssl.com and failed explicitly with Host name mismatch for wrong.host.badssl.com. The self-signed chain was untrusted. This independently separates hostname and chain conditions on the observed Mac. Record rotation/unavailability as inconclusive; never substitute a generic failure or add a trust root. This is not an iPhone peer-certificate fingerprint trace.

## iOS transport-code diagnosis and oracle

The first physical run passed six test declarations and failed both certificate declarations (four typed/raw issues). Actual TLS connections were rejected, but iOS 27.2 reported NSURLErrorDomain/-1200 rather than macOS's -1202. A second, explicitly diagnostic run preserved those strict failures and used ordinary ephemeral Foundation URLSession with performDefaultHandling. On the iPhone it observed actual server-trust callbacks and SecTrust errors errSecNotTrusted (-67843) for self-signed and errSecHostNameMismatch (-67602) for wrong-host, alongside transport -1200. The installed Security SDK declares those exact symbols/codes. No production defect or trust acceptance was demonstrated.

The final oracle accepts direct NSURLErrorDomain untrusted/unknown-root codes. For -1200 only, it additionally requires a same-device ordinary Foundation control to observe a server-trust callback, kCFErrorDomainOSStatus, the exact expected per-fixture SecTrust code and NSURLErrorDomain/-1200. Missing callback, another domain, connectivity, timeout, cancellation, another trust condition or unexpected success fails. Completion always uses performDefaultHandling with no credential; no failed trust is accepted by either client. The test returns no payload for a negative fixture. This refines cross-platform evidence without weakening production TLS or turning any -1200 into a pass. Preserve earlier failed runs as diagnosis evidence.

## Verification and disposition

Actual run summaries, source hashes, certificate witness and negative-control results are in [sanitized NET-01 evidence](evidence/NET01_PUBLIC_HTTPS_2026-10-27.json). The final Mac run passed eight tests/one suite (16 typed/raw cases), and the final iPhone 17 Pro/iOS 27.2 (24B119) run passed eight/eight with zero failed/skipped/expected failures and no unexpected restart/time-limit failure. Existing signing identity/profile only; embedded profile matched, signatures verified and temporary host removed (exit 0). Wired refers to the debugging link; the device Internet interface was not recorded. Each initial physical run passed six of eight test declarations and failed the two certificate declarations with four typed/raw issues; both attempts remain preserved as diagnosis evidence. Mac: macOS 15.8.1/24H32 x86_64, Xcode 26.3/17C529, Swift 6.2.4, SDK 26.2. Public tests are explicitly observed native behavior on their recorded targets, not general CI coverage. Hosted PR/main checks compile these tests only and must be accepted before #115 completion.

The generic-connection negative control uses an isolated copy of the verification package, replacing only the self-signed URL with a closed loopback HTTPS port; it must compile and fail both certificate assertions. Offline helper controls reject missing certificate capture and a generic SSL-policy failure as hostname evidence. Retain fail-closed assertions and no automatic retry.

## Remaining F2 ownership

#62 retains all five minimum destinations; #63 retains other physical targets, complete ENV-01–07 including storage/challenges/transitions and actual resource suitability. These public observations may satisfy their matching scenario portions on recorded targets only. Controlled/local counters still own denied-destination zero-contact and credential absence claims; public echo/status cannot prove them. Existing local/native/deterministic evidence remains valid under its own source/platform limits. Quantitative resource/load tests must use appropriate controlled/native routes, not public services.

#86 reconciles the combined evidence; #64/#27 retain clean-consumer/archive/aggregate privacy-report rehearsal, and #29 retains explicit risk/release/publication decisions. No release or tag is selected. One bounded NET-01 task is justified by the owner's fixture choice; no new SDK feature, broad refactor, duplicate server-provisioning task, milestone or support change is justified. Retry implementation remains deferred.
