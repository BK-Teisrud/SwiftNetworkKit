# Temporary macOS 14 execution route — 2026-10-29

I21 / [#62](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/62). The owner has no second Mac and authorized completing F2 without a paid environment. PR #120 is accepted through main run 40765690271 on 8e490340dd806fde1d93cac28cf22e33e6e6c69e; its four minimum simulator regression results retain their recorded boundaries.

## Access decision and time limit

GitHub's [official retirement announcement](https://github.blog/changelog/2026-10-01-github-actions-macos-14-runner-image-retirement/) says standard macos-14 retires on November 2, 2026, with brownouts including October 29 14:00–October 30 00:00 UTC and October 30 14:00–October 31 00:00 UTC. The former ends October 30 at 01:00 Europe/Oslo. Do not dispatch into a known brownout, wait/poll unattended, substitute a newer execution OS, or infer a successful run from image availability. The build helper refuses this temporary route on/after November 2 UTC. Remove this one-off workflow after its evidence is dispositioned or the route expires; keep the dated evidence.

[Standard GitHub runners are free for public repositories](https://docs.github.com/en/billing/concepts/product-billing/github-actions). The repository had zero Actions artifacts at the access check. Transfer is capped at 20 MiB and one day retention, with no cache, larger runner, paid service, custom image, OS install or host/toolchain change. Storage has separate allowances; this small transfer is within even the documented 500 MB allowance at the observed zero-artifact baseline.

## Concrete verification route

The manually dispatched [workflow](../../.github/workflows/macos14-verification.yml) has two sequential jobs. It never runs on ordinary PR/push events, is not an alternative to the mandatory matrix, has no schedule/retry or caller-controlled shell inputs, and uses read-only contents permission with GitHub-owned SHA-pinned actions and no persisted checkout credentials.

1. On macos-15, use the exact approved Xcode 26.3/17C529 and Swift 6.2.4. Build the existing public [ResourceProbe](../../scripts/benchmarks/Probe.swift) in release mode, Swift 6, warnings as errors, explicitly targeting x86_64-apple-macosx14.0. Check the actual Mach-O architecture and declared minimum. Transfer only this consumer and its package resource bundles with a source-commit/file-hash manifest. No Apple test framework, compiler or SDK is transferred.
2. On standard Intel macos-14, check out the same workflow revision, validate exact commit/source hashes, every payload file/checksum and target, and require the actual host OS major 14 and x86_64. An older preinstalled compiler never rebuilds the package. Binary-load/API/runtime incompatibility fails the run and requires diagnosis; deployment metadata alone is insufficient.
3. Use the existing controlled synthetic loopback fixture and prebuilt executable option in [the probe runner](../../scripts/benchmarks/run.py). Execute the bounded reuse/cancellation smoke and 100-cycle NetworkKit/direct URLSession controls with observation after the original deadlines. No HTTPBingo/BadSSL/public traffic is executed by this workflow. Fixture counts, native contact, cancellation joins and connection reuse remain validated by the existing runner. Exact actual OS patch/build, builder environment and numeric results are printed for review; no secrets, account data, personal payloads or device identifiers are selected.

## Local verification and evidence limits

The concrete Intel/macOS 14.0 consumer built successfully with the approved local toolchain. It ran on the owner's macOS 15.8.1 for route validation: smoke reuse received 5 payloads; cancellation joined 8 calls after native contact; the two 100-cycle controls each received exactly 6,401 payloads and sampled after 12 seconds. These are local macOS 15 observations, not macOS 14 evidence. Deliberate binary corruption and a wrong source commit were rejected before execution; the actual-minimum runner rejected macOS 15. Three permanent helper regressions cover provenance corruption/wrong commit, unexpected payload files and the wrong-OS gate. Source integrity checks pins across both workflow files.

Actual macOS 14 execution is pending. This route exercises a real public SDK consumer/native loopback/resource workload; it is not the 218-test suite, HTTPS/certificate verification, exact macOS 14.0 execution, or a universal memory bound. The [current runner image record](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md) is a later macOS 14 patch. Record the actual runtime honestly. A 14.x result does not establish 14.0 behavior, and these narrower results do not waive any selected minimum/native/resource requirement.

## Remaining F2 work

Use actual results to update #62 and the [F2 reconciliation](F2_REVIEW.md). Minimum native HTTPS/lifecycle/storage and suitable target resources, missing physical-family/transition evidence under #63, reconciliation #86, non-publishing consumer/archive/privacy rehearsal #64 and owner risk/release disposition retain their requirements. This execution-access slice does not justify a new milestone, generic duplicate environment issue or speculative SDK refactor. No release/tag or support-minimum change is authorized by preparing this route.
