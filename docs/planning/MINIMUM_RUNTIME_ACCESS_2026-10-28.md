# Minimum-runtime access leads — 2026-10-28

Owner: @BK-Teisrud; #62. This is metadata/authorization evidence, not an installed, booted or passed runtime. Actual minimum-version execution remains open. No image or runtime package was successfully downloaded/installed during this investigation; the three authorized official download attempts below were rejected. No device or host OS changed.

## Official route and observed catalogue

Apple's [Xcode requirements table](https://developer.apple.com/xcode/system-requirements/) includes the selected minimum families in the Xcode 26.3 simulator ranges. The [component documentation](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) describes downloadPlatform with buildVersion, exportPath and architectureVariant; Intel Macs use a universal variant. These are feasibility leads, not proof that an arbitrary historical image boots/tests with this exact host/toolchain.

Read-only metadata from [Apple's simulator catalogue](https://devimages-cdn.apple.com/downloads/xcode/simulators/index2.dvtdownloadableindex) contains the exact stable entries below. Unauthenticated HEAD requests initially returned HTTP 200, but follow-up inspection showed text/html at developer.apple.com/unauthorized/, not archive data. Archive access is therefore unverified; no package payload was read. [Sanitized candidate record](evidence/MINIMUM_RUNTIME_CANDIDATES_2026-10-28.json) preserves public identifiers, sizes/builds/URLs and observed headers. Beta entries and 17.0.1 were not substituted for the selected exact minimum.

| Runtime | Build | Advertised archive bytes | Intended evidence |
| --- | --- | --- | --- |
| iOS 17.0 | 21A328 | 7,559,529,352 | Separate compatible iPhone and iPad destinations; one does not prove the other |
| watchOS 10.0 | 21R355 | 4,023,631,243 | Compatible Watch destination/companion and an actual supported test route |
| tvOS 17.0 | 21J353 | 3,745,733,256 | Compatible TV destination and actual test route |

Combined advertised archive size is about 15.33 GB decimal, plus installation/temporary-space requirements. The workspace volume had approximately 251 GiB free at inspection; space must be checked again before starting. A catalogue entry and an HTML 200 response do not establish archive access, provenance, integrity, Intel compatibility, CoreSimulator import, boot or Swift 6 test-framework compatibility. Those remain explicit checks during the selected installation task.

## Owner decision and next action

The owner explicitly approved all three runtime archives sequentially in the conversation on 2026-10-28. Verify access through Apple's official Xcode download mechanism first; a generic unauthenticated fetch currently reaches /unauthorized/. Then proceed in order iOS 17.0 → watchOS 10.0 → tvOS 17.0 using Apple's official download/import mechanisms, validating the selected source/size/image integrity and actual outcomes. No third-party runtime patch, beta, platform/tool upgrade, support-minimum change, purchase, root/trust change or macOS installation is selected. If new terms/account access or incompatible images require a different action, stop for that concrete decision. Do not silently substitute a later OS or treat a failed import/boot as a passed target.

After successful installation/discovery, select actual compatible simulator models and a supported Watch pairing. Run the relevant test suites/public native observations on the exact reviewed source; preserve each actual OS/build/architecture/command/result and failure. Keep minimum iPhone/iPad results separate. Environment preparation does not close #62 without its complete acceptance evidence.

## macOS 14 remains separate

There is no macOS simulator image in these three entries. Apple's [macOS virtualization sample](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon) is for Apple silicon; the observed host is Intel. It does not establish a macOS 14 route here. Xcode 26.3 requires a newer development host, so any separate built-consumer/runner route on macOS 14 needs actual compatibility/execution checks. No new volume/OS install, downgrade, VM tool or remote/paid machine is authorized by this runtime decision.

#62 retains ownership of this access gap; #86/#29 retain its release consequence. No duplicate generic environment issue or milestone is needed. Keep native public/lifecycle/storage observations and actual older-runtime support evidence distinct.

## Authorized official download attempts

After the owner approved the sequence, the installed Xcode 26.3 command was invoked once per platform with downloadPlatform, exact buildVersion, architectureVariant universal and a private temporary export directory. Each exited 70 and explicitly reported its requested exact universal runtime “not available for download”: iOS 17.0, watchOS 10.0 and tvOS 17.0. No runtime archive was exported or imported. No automatic retry, beta/later-version substitution, unofficial mirror or architecture patch was attempted.

The public catalogue and current CLI therefore do not by themselves supply access. Next verify an authenticated official Apple download/archive route or a compatible official download-tool route. Do not infer that the runtimes are globally impossible to obtain or that a new/paid service is required. Any login/terms/user action must be handled explicitly without requesting secrets. Existing approval for these three exact installs remains recorded; actual access and macOS 14 remain #62 blockers.
