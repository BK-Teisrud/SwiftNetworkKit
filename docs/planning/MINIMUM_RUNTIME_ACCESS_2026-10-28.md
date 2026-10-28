# Minimum-runtime access leads — 2026-10-28

Owner: @BK-Teisrud; #62. The initial catalogue/CLI investigation below is historical. The authenticated archive follow-up now confirms successful iOS 17.0, watchOS 10.0 and tvOS 17.0 imports. Actual minimum-version execution remains open. The host OS, physical-device settings, support minimums and toolchain were not changed.

## Official route and observed catalogue

Apple's [Xcode requirements table](https://developer.apple.com/xcode/system-requirements/) includes the selected minimum families in the Xcode 26.3 simulator ranges. The [component documentation](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) describes downloadPlatform with buildVersion, exportPath and architectureVariant; Intel Macs use a universal variant. These are feasibility leads, not proof that an arbitrary historical image boots/tests with this exact host/toolchain.

Read-only metadata from [Apple's simulator catalogue](https://devimages-cdn.apple.com/downloads/xcode/simulators/index2.dvtdownloadableindex) contains the exact stable entries below. Unauthenticated HEAD requests initially returned HTTP 200, but follow-up inspection showed text/html at developer.apple.com/unauthorized/, not archive data. Archive access is therefore unverified; no package payload was read. [Sanitized candidate record](evidence/MINIMUM_RUNTIME_CANDIDATES_2026-10-28.json) preserves public identifiers, sizes/builds/URLs and observed headers. Beta entries and 17.0.1 were not substituted for the selected exact minimum.

| Runtime | Build | Advertised archive bytes | Intended evidence |
| --- | --- | --- | --- |
| iOS 17.0 | 21A328 | 7,559,529,352 | Separate compatible iPhone and iPad destinations; one does not prove the other |
| watchOS 10.0 | 21R355 | 4,023,631,243 | Compatible Watch destination/companion and an actual supported test route |
| tvOS 17.0 | 21J353 | 3,745,733,256 | Compatible TV destination and actual test route |

Combined advertised archive size is about 15.33 GB decimal, plus installation/temporary-space requirements. The workspace volume had approximately 251 GiB free at inspection; space must be checked again before starting. A catalogue entry and an HTML 200 response do not establish archive access, provenance, integrity, Intel compatibility, CoreSimulator import, boot or Swift 6 test-framework compatibility. Those remain explicit checks during the selected installation task.

## Owner authorization and initial sequence

The owner explicitly approved all three runtime archives sequentially in the conversation on 2026-10-28. Verify access through Apple's official Xcode download mechanism first; a generic unauthenticated fetch currently reaches /unauthorized/. Then proceed in order iOS 17.0 → watchOS 10.0 → tvOS 17.0 using Apple's official download/import mechanisms, validating the selected source/size/image integrity and actual outcomes. No third-party runtime patch, beta, platform/tool upgrade, support-minimum change, purchase, root/trust change or macOS installation is selected. If new terms/account access or incompatible images require a different action, stop for that concrete decision. Do not silently substitute a later OS or treat a failed import/boot as a passed target.

After successful installation/discovery, select actual compatible simulator models and a supported Watch pairing. Run the relevant test suites/public native observations on the exact reviewed source; preserve each actual OS/build/architecture/command/result and failure. Keep minimum iPhone/iPad results separate. Environment preparation does not close #62 without its complete acceptance evidence.

## macOS 14 remains separate

There is no macOS simulator image in these three entries. Apple's [macOS virtualization sample](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon) is for Apple silicon; the observed host is Intel. It does not establish a macOS 14 route here. Xcode 26.3 requires a newer development host, so any separate built-consumer/runner route on macOS 14 needs actual compatibility/execution checks. No new volume/OS install, downgrade, VM tool or remote/paid machine is authorized by this runtime decision.

#62 retains ownership of this access gap; #86/#29 retain its release consequence. No duplicate generic environment issue or milestone is needed. Keep native public/lifecycle/storage observations and actual older-runtime support evidence distinct.

## Authorized official download attempts

After the owner approved the sequence, the installed Xcode 26.3 command was invoked once per platform with downloadPlatform, exact buildVersion, architectureVariant universal and a private temporary export directory. Each exited 70 and explicitly reported its requested exact universal runtime “not available for download”: iOS 17.0, watchOS 10.0 and tvOS 17.0. No runtime archive was exported or imported. No automatic retry, beta/later-version substitution, unofficial mirror or architecture patch was attempted.

At the end of the initial CLI investigation, the public catalogue and installed CLI did not by themselves supply access. The next selected action was an authenticated official Apple download/archive route or a compatible official download-tool route. Do not infer that the runtimes are globally impossible to obtain or that a new/paid service is required. Any login/terms/user action must be handled explicitly without requesting secrets. Existing approval for these three exact installs remains recorded; actual access and macOS 14 remain #62 blockers.

## Authenticated archive follow-up

The owner signed in directly to Apple Developer Downloads. The authenticated archive lists the stable September 18, 2023 iOS 17, watchOS 10 and tvOS 17 Simulator Runtime entries. Their Developer_Tools disk-image links match the catalogue sources above. No credentials, cookies, authentication headers or private account details are included in this evidence.

The browser automation download event/file-result handling timed out; the first iOS partial download disappeared without an accessible completed archive and was not accepted. A later complete iOS transfer and the watchOS transfer were retained through their already-open local download file handles into the private temporary export directory. Exact catalogue byte counts and `hdiutil verify` passed before `xcrun simctl runtime add`. Both imports exited 0 and reported Ready. Runtime inventory confirms iOS 17.0/21A328 and watchOS 10.0/21R355, available with x86_64 and arm64 architectures. This resolves archive access/import for those exact images without establishing test success.

Separate task-owned iPhone 14 Pro and iPad (10th generation) destinations were created for iOS 17.0. The first iPhone boot-status observation timed out after 180 seconds during Apple's LaunchServices data migration. One follow-up observation timed out after 55 seconds. Inventory state Booted alone does not satisfy boot readiness or prove any NetworkKit test execution. No tests started, simulator data was not erased, and no runtime patch or security bypass was applied. The task-owned simulator was asked to shut down after these observations.

The delayed tvOS transfer subsequently completed with the exact 3,745,733,256 bytes; disk-image verification and official import both exited 0, with tvOS 17.0/21J353 reported Ready. Final runtime inventory confirms all three selected images available for x86_64 and arm64. Watch/TV destinations, any required pairing, boot and actual tests remain unverified. macOS 14 access and all actual minimum-target results remain open under #62. No additional issue or milestone is justified for these existing access/boot substeps; preserve their priority before the F2 gate.

[Sanitized acquisition record](evidence/MINIMUM_RUNTIME_ACQUISITION_2026-10-28.json) preserves exact source, sizes, commands/results and remaining limits. The boot timeout cause is not established and is not proof of unsupported runtime or a NetworkKit defect.

CoreSimulator disk-image inventory reported signatureState Verified for the imported iOS and watchOS images. Separate explicit `simctl runtime verify` commands each reached the 45-second observation limit without output; these commands are not claimed to have passed. Preserve this distinction from the successful imports and disk-image checksum verification.
