# Manual foreground and connectivity checks

Tracking: #63, ENV-06/ENV-07. This is an explicit verification app, outside the shipped SDK. It records observations for review; it never declares F2 or a scenario passed automatically.

## Preparation and limits

`scripts/ci/prepare_manual_host.py` derives one app target from the validated existing host metadata and links the public NetworkKit product into it. It preserves `no.teisruddevelopment.NetworkKitDeviceHost`, disables signing by default, and writes only ignored `.build/manual-host-*` projects. The app embeds its SDK checkout commit, manual-source SHA-256 and platform in the report. Existing generic regression/native test hosts and their membership remain separate.

```sh
python3 scripts/ci/prepare_manual_host.py --platform iOS
xcodebuild -project .build/manual-host-ios/NetworkKitManualChecks.xcodeproj \
  -scheme NetworkKitManualChecks -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

The other explicit platform choices are macOS, watchOS and tvOS. Required CI compiles one unsigned manual app per family, without launching it. The app's minimums remain iOS/iPadOS 17, macOS 14, watchOS 10 and tvOS 17. Signed deployment uses only the appropriate previously approved host profile, device and existing certificate; verify the actual signature and embedded profile before installation. Do not create unrelated IDs, certificates, capabilities or account access. Watch runtime access is still independently blocked by its development tunnel/readiness.

No request starts on launch. Path monitoring records fixed connectivity/interface categories, not addresses, network names or nearby-device discovery. Three owner-driven steps make at most four fixed HTTPS GET calls: one background call, one network-loss call and two concurrent recovery calls. Both delayed calls use HTTPBingo `/delay/8`; recovery uses `/status/204`. This stays within the service's [documented delay endpoint](https://httpbingo.org/). There is no retry, traffic loop, public load benchmark, arbitrary URL, authentication or trust override. The same client is reused across the steps, then explicitly shut down. Limits are the approved 30-second inactivity / 60-second total defaults.

The app records scene transitions, path observations, terminal outcomes, joined completion/shutdown, bounded sanitized SDK diagnostics and whole-process RSS. An unavailable RSS sample is recorded as unavailable. Scene/path callbacks describe observed delivery, not exact server contact or packet timing. Whole-process RSS includes the app, SwiftUI, Foundation and allocator; these four small requests do not establish workload capacity or a universal memory bound.

## One recorded run

Record exact device model/OS/build and source/provenance first. Keep the device unlocked as needed for launch and report retrieval. Use one device at a time. Retrieve any existing test reports before replacing/removing its dedicated host.

1. Select **Background check**, immediately leave the app and return after about five seconds. Require an actual applicable scene transition during the pending call and return to active state. On macOS, hiding/inactivating the app is distinct from iOS background suspension; record what actually occurred.
2. Select **Network loss check**, then use a concrete owner-approved reversible method to interrupt that device's usable connection while its call is pending. Restore connectivity and return to the app. Record the actual method and any fallback interface. If another interface stayed usable or no loss was observed, retain an inconclusive result. Do not disrupt the Mac/chat connection, router or unrelated devices as a side effect.
3. With connectivity restored, select **Recovery check**. Both explicit concurrent requests must return 204 through the same client after the earlier call. Require joined shutdown and four SDK terminal events in a complete run. An HTTP error, timeout or cancellation must retain its own classification; none is automatically a recovery success.
4. Wait at least **61 seconds after recovery completion**, then select **Save final sample**. Waiting after completion is conservatively beyond every call's original 60-second budget. Require the post-budget sample, no additional terminal events and no truncation/overflow/report-write failure. An early save attempt starts no request and asks the owner to wait.

**Cancel active check** is an explicit abort control. Preserve an aborted report; it does not substitute for a natural network-loss outcome. Each step runs once per app session. No failed case is automatically repeated. If a corrected/repeated run is justified, preserve the original report and reason, then start a new session.

## Report custody and acceptance

Reports are separate random-run JSON files under the dedicated app's `Library/Caches/NetworkKitManualChecks`. macOS uses the user's corresponding cache directory. Retrieve only this test app's reports through the authorized device/app-data route. Reports contain no serial number, UDID, account, SSID, IP, credentials, arbitrary errors, URL or request/response headers/bodies. A delayed public response can contain network metadata in memory; it is discarded and never written or printed. Only status and byte count are recorded.

Check the embedded commit/manual-source hash against the reviewed generated project's provenance and actual signed artefact. Review scene/path chronology together with SDK durations and outcomes; UI pending state alone is not proof that a server saw a request at a transition. Public services supply no maintainer-controlled counters. Unsupported/missing callbacks, preserved failures and platform-specific applicability require explicit disposition under #63/#86. Report export or successful compilation alone is not acceptance.

After sanitized evidence is preserved, remove only the dedicated temporary host. No production SDK feature, background-transfer capability, platform-support change, release or owner risk acceptance is added by this tool.

## Verified preparation and physical results — 2026-10-31

All four final unsigned variants compiled with warnings as errors, and their actual built Info.plist platform/commit/source fields were checked. Runtime refuses missing provenance. A local Mac control verified launch without requests, real scene background/active transitions, four successful calls, two concurrent 204s, joined shutdown, early-sample rejection and the post-budget sample. Its network remained connected, so it is not an outage result. See [preparation custody](evidence/MANUAL_TRANSITION_HOST_PREPARATION_2026-10-31.json). Initial project-group, fixture and provenance findings were corrected before physical use and remain recorded as preparation findings.

The owner then performed actual background/home/return and airplane-mode/Wi-Fi interruption on iPad and iPhone. Both reports show an unsatisfied path while the call was pending, transport NSURLErrorDomain/-1009, restored connectivity, two concurrent recovery 204s through the same client, joined shutdown and four terminal events unchanged after more than 61 seconds. Reports and signatures/source identities were verified; temporary hosts were removed. [iPad evidence](evidence/F2_IPAD_MANUAL_TRANSITIONS_2026-10-31.json) and [iPhone evidence](evidence/F2_IPHONE_MANUAL_TRANSITIONS_2026-10-31.json) retain the entire sanitized chronology and finite RSS observations. These are candidate results pending this PR/main acceptance.

The signed TV manual artefact is prepared but its installation/execution was deferred by the owner. Watch still reports disabled Developer Mode/DDI despite owner confirmation and remains unexecuted; a fresh check after phone network restoration did not resolve it. The Mac's actual outage remains a separate owner-driven task. Existing #63 owns these remaining gaps. No physical transition result is inferred across devices, and no generic production refactor or new milestone is justified.
