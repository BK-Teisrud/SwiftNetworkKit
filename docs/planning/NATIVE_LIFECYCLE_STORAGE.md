# NET-02 — native cancellation, shutdown and isolated cookie profiles

Date: 2026-10-28. Task #117, parent #23, F2 CORE/P1, Order 20.96. Baseline: accepted main 46dd1d2c1298866c2818f0b9a7ca1c992c37f6ee / run 40644612904. NET-01 #115 is Done for its bounded public HTTPS route. Production code, package/API/dependencies/minima, default tests and signing policy are unchanged.

## Selected evidence slice

Four additional parameterized tests in the existing serialized opt-in PublicHTTPSTests suite cover ten cases: typed/raw cancellation, owned shutdown, borrowed shutdown, and typed/raw × owned/strict-borrowed cookie profiles. The complete separate suite is now 12 test declarations/26 parameter cases. This is not a distributed SDK module. Standard CI compiles it only, and the default package/device-host suites keep their existing coverage.

| ID | Scenario | Required observation / evidence limit |
| --- | --- | --- |
| LIFE-01 | Cancel a delayed public call, await its result, then send another request through the same owned client | CancellationError and subsequent 204; no unobserved server-receipt or hard real-time assertion |
| LIFE-02 | Shutdown an owned client with a delayed call, join its result and attempt a later SDK call | CancellationError and clientClosed. No public server counter proves zero-contact for the rejected call; deterministic/local guards retain that claim |
| LIFE-03 | Shutdown a compatible strict-borrowed client during a delayed call, then use the same app-owned session directly | CancellationError and successful native Foundation 204 afterward; app alone invalidates its session during final cleanup |
| STORE-01 | Owned and strict-borrowed clients visit synthetic cookie-set and cookie-echo endpoints | Synthetic marker absent at redirect and follow-up. Each case includes STORE-02 positive control before interpreting absence |
| STORE-02 | Separate appManaged borrowed client with isolated ephemeral cookie store | Identity distinct from shared store, synthetic marker echoed and stored, explicit app deletion, marker absent afterward; no shared-store mutation or real credential |

Each delayed operation is cancelled/joined on success and error paths. Clients shut down even on assertions; private sessions invalidate only after SDK cleanup. Every cookie control verifies private-store identity before any mutation and removes only its synthetic in-memory store contents. Assertions/logs use Boolean/scalar results, never cookie/echo payload descriptions. The query fixture uses the same shared typed/raw construction helper with fixed synthetic input; no general policy/plugin refactor is introduced.

Public traffic remains serialized, finite and manually selected with bounded client limits; no load/resource benchmark or unattended retry. Network loss, OS transitions, cache/challenge behavior, resource suitability and complete ENV-01–07 are not established by these cases. A cancellation can occur during preparation/DNS/TLS; no server contact is inferred merely from scheduling a delayed request.

## Actual verification and disposition

The initial Mac selection passed all four new declarations; the final full Mac suite passed 12 tests/one suite, including the original certificate/status/redirect/budget checks. The first physical attempt signed/built successfully but waited for device unlock and reached its outer 240-second limit before test start. It supplies no physical result. Keep that preparation failure distinct from a product defect. The next test command checks lock state and preserves private logs without echoing device/signing identifiers on timeout.

After the owner unlocked the phone, the same signed artefact passed all 12 declarations on iPhone 17 Pro/iOS 27.2 (24B119), zero failed/skipped/expected failures and no unexpected restart/test time-limit failure. All ten new case markers were verified. Existing identity/profile only, signatures/profile verified, no account/setting change, temporary host uninstalled successfully (exit 0). [Sanitized evidence/source hashes](evidence/NET02_NATIVE_LIFECYCLE_2026-10-28.json) records these results. Wired describes the debugging link; Internet interface was not recorded. The isolated cancellation control compiled and failed exactly two CancellationError assertions after omitting caller cancel. The storage-premise control compiled and failed all four positive marker assertions after disabling cookie acceptance/handling, preventing strict absence from passing when the fixture premise is false. Both copies left repository source unchanged. No production source is mutated. Cookie echo/positive controls establish tested observable handling, not a forensic search of all OS storage.

Required exact PR/main checks remain pending. NET-01's dated eight-test results retain their original source hashes; the expanded suite is a new snapshot and does not rewrite that evidence. No extra production refactor, framework, milestone or duplicate environment issue is justified.

## Next work and minimum access

#63 retains actual remaining physical families and all unproved native scenarios/resources. #62 independently owns [minimum-runtime access](MINIMUM_RUNTIME_ACCESS_2026-10-28.md). The owner approved sequential installation of the three stable runtime candidates, but anonymous archive requests currently redirect to Apple's unauthorized HTML; verify the official download route, import/architecture/boot and actual tests before reporting access. The three authorized Xcode universal download attempts each exited 70, reporting the exact requested version unavailable; no archive was exported and no runtime or macOS image was installed. macOS 14 remains a separate unresolved route.

#86 reconciles completed evidence after blockers; #64/#27 retain consumer/archive/aggregate privacy-report rehearsal; #29 retains explicit risk/release/publication decisions. This work authorizes no support change, paid server, tag or release.
