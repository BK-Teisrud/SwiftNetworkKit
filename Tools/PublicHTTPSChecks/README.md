# Opt-in public HTTPS verification

NET-01 / #115. The owner selected HTTPBingo and BadSSL on 2026-10-27 instead of provisioning a paid/private HTTPS environment. This separate verification package is not a shipped library product or an SDK dependency. Its only package dependency is the local repository. Normal root tests never run these checks.

## Explicit execution only

On the observed Mac, from the repository root:

```sh
swift test --package-path Tools/PublicHTTPSChecks -Xswiftc -warnings-as-errors
python3 Tools/PublicHTTPSChecks/certificate_witness.py --output /private/tmp/networkkit-public-cert-witness.json
```

For iOS use the existing device-host project with the separate PublicHTTPSChecks scheme. Its test target directly references this package's PublicHTTPSTests.swift. The default NetworkKitDeviceHost scheme still runs only the original regression suite. See [host signing/install/cleanup procedure](../DeviceTestHost/README.md). Existing host/profile authorization remains scoped; create no profile, certificate, registration or trust exception as a side effect. Recheck actual device readiness and compatible existing profile before deployment.

CI uses only swift build --build-tests for this package and unsigned build-for-testing for its separate iOS scheme. It never runs public-service scenarios. Compilation/discovery is not execution evidence. Source controls retain default-suite membership and require the public target's explicit separate scheme.

## Traffic and privacy

Eight serialized parameterized tests exercise typed/raw input: 16 ordinary public requests per full run, no automatic rerun/retry. A failed certificate classification can add one bounded ordinary Foundation diagnostic request per failed input; at most 20 requests total. Client limits are inactivity 5 / total 10 seconds, except two calls selecting a 0.25-second total budget. No load/performance benchmark, bulk payload, credential, real account header, personal query or unattended schedule is selected. Fixed public addresses are HTTPBingo and the three named BadSSL fixtures only.

The redirect echo can contain a client IP: inspect only the expected URL fields in memory, never print/publish/save its body or arbitrary JSON-decoder errors. Logs contain fixed case IDs/input modes/status or numeric error identities. Raw tool logs/xcresults can still contain network/device details and stay private; publish sanitized scalar summaries only. Public services inherently observe the connection and ordinary protocol metadata.

## Evidence boundaries

- JSON success, 204, status 503 before decode, same-origin redirect and total-budget outcome are observations through actual native URLSession/public NetworkKit calls. The budget case does not prove the server received a call before cancellation; timing includes DNS/TLS/network scheduling.
- Valid HTTPS and two rejected certificate fixtures require correct outcomes for both typed/raw calls. The certificate assertion requires direct NSURLErrorDomain untrusted/unknown-root codes, or -1200 plus a same-device default-Foundation control observing the exact expected SecTrust failure/domain and transport code. A generic TLS, DNS, connection, timeout or cancellation failure alone cannot pass.
- Certificate witness captures public server certificates without an HTTP payload, then checks Apple SSL policies locally without adding anchors or changing client trust. Require matching valid/wrong-host leaf, trusted captured chain under the correct hostname, explicit hostname mismatch under the wrong hostname, and untrusted self-signed chain. Certificate rotation/unavailability yields inconclusive failure, not a substituted pass. This witness runs on the Mac; it is not a device peer-certificate trace.
- The optional Foundation corroboration preserves performDefaultHandling and returns no credentials. It records only whether a server-trust callback occurred, numeric SecTrust error and transport code. Only NSURLErrorDomain/-1200 with a server-trust callback, kCFErrorDomainOSStatus and exact errSecNotTrusted/errSecHostNameMismatch plus matching default-Foundation transport failure can satisfy the conditional oracle. It does not classify every -1200 as a certificate failure.
- Public services supply no maintainer-controlled server counters. Denied-destination zero-contact/secret absence, native request/contact timing, cache/challenge scenarios and quantitative resources retain controlled/local or separately observable evidence requirements. Do not infer those claims from a returned status or an echo endpoint.
- Minimum-runtime, other physical-device, transition/resource, archive/privacy-report and owner release gates remain separate. See [NET-01 findings](../../docs/planning/PUBLIC_HTTPS_VERIFICATION.md). Service outages or changed fixtures are evidence problems to investigate; no hidden skip or automatic flaky retry.
