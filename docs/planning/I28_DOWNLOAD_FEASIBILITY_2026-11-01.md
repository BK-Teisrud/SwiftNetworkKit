# I28 foreground download feasibility checkpoint

Date: 2026-11-01
Status: Partial evidence; I28 remains In Progress and #88 remains Blocked. Not shipping implementation or complete API feasibility acceptance.

## Authorization and source

The owner explicitly authorized only I28 on 2026-11-01: “Approve only the I28 feasibility experiment.” START-F4 #145 is completed; I29–I32, public download API, signing/device installation and publication remain unauthorized. Accepted planning main is `14051ce4a9f817d74ff30715b397a3df1752310c`, PR #151 / run 41312825323. [Machine-readable evidence](evidence/I28_DOWNLOAD_FEASIBILITY_2026-11-01.json) records exact unchanged SDK source hashes, experimental source hashes and host. Experimental source is compiled beside existing source solely for access to the internal per-task delegate, not installed into the product.

## Experiment and actual result

[The opt-in experiment](../../Tools/DownloadFeasibility/README.md) bound three transient servers to 127.0.0.1: primary synthetic HTTP, a foreign-origin counter and self-signed HTTPS. The generated one-day key/certificate remained in a private temporary directory and was removed, never trusted or installed. No public service, signing identity, device or account was used.

The initial run passed 27 observations with one redundant-await compiler warning. Remove the warning and add active owned-session invalidation, then rerun: **28 observations passed**, zero compiler warnings in the final log. Two session modes (owned/store-free borrowed) covered:

- Actual async-returned file existence after one 20 ms suspension, full bounded fixture content oracle, unique file move and explicit removal; normal, empty, unknown-length and gzip-encoded responses.
- 8192-byte received file above a 4096-byte example limit, final-size observation and removal. This is an oracle/prototype check, not enforcement by the unimplemented APIClient download API.
- Complete file responses for 206/503 followed by explicit removal, same-origin redirect, denied cross-origin redirect with **zero foreign-target contacts**.
- Interrupted transfer with no successful file URL, self-signed TLS rejected with an allowlisted system trust error, cancelled child awaited without a successful result.
- Active owned-session invalidation yields cancellation and is joined; the externally preserved handoff file survives invalidation. Borrowed transport invalidation leaves the owner session usable.

The bounded file-content oracle uses Data only to inspect fixtures of at most 8192 bytes; production file-backed behavior must not copy whole downloads into Data. No RSS/allocation, performance, leak or hard disk-cap claim follows.

## What this does not prove

`URLSession.download(for:delegate:)` appears feasible for the chosen file-backed route. The async-returned URL survived the measured suspension; that finite observation is not a general lifetime guarantee. Preserve promptly and separately test the final implementation. The delegate completion callback has a different lifetime rule and must not be conflated with async return.

No `APIClient.download` exists. This experiment does not exercise its future auth-once preparation, total deadline, shutdown admission, success/cancellation handoff race, error mapping or diagnostics. No filesystem preserve/inspect/remove failure was injected. Cancellation/interruption returns no file URL, so Foundation-owned partial-file deletion is **not observable or proven** here. A claimed cleanup guarantee must distinguish Foundation-owned native temporary files from files actually adopted by the library. No hard transient disk ceiling, crash recovery, secure erasure, protected-file policy or production workload evidence is available.

Local HTTPS establishes rejection of an untrusted certificate, not successful controlled system-trusted HTTPS/auth. Existing core/retry HTTPS evidence does not become F4 download evidence. Apple minimum/platform build declarations do not become runtime observations. Physical Watch remains unresolved under #132; F4 acceptance cannot silently discard its own missing requirements into publication.

## Stop/go and next work under I28

Proceed only with the already-authorized feasibility investigation. **Do not start I29** or mark #88/#146 complete. Resolve native temporary-file ownership/cleanup observability, operation handoff/deadline model and bounded filesystem failure injection in I28; choose exact proposed API/error/diagnostic mappings after those findings. Preserve the accepted cleanup limitation rather than promising impossible deletion after filesystem failure or crash. A separate implementation decision is still required, even if those findings later support go.

The existing I28 issue is the right owner for these gaps; do not create a generic cleanup framework, extra milestone or duplicate bug solely from an unimplemented API. #29/#132 remain publication barriers, and #14/#89/#90 priorities do not change.

## Platform evidence matrix

| Platform | Existing minimum | This checkpoint | Remaining |
| --- | --- | --- | --- |
| macOS | 14 | Actual Intel macOS 15.8.1; 28 observations | New download execution on macOS 14, integrated lifecycle/errors |
| iOS/iPadOS | 17 | Swift 6 typecheck, x86_64 iOS 17 simulator target, installed SDK | No download simulator or physical execution in I28 yet |
| watchOS | 10 | Swift 6 typecheck, x86_64 watchOS 10 simulator target | No download runtime/physical result; #132 remains separate |
| tvOS | 17 | Swift 6 typecheck, x86_64 tvOS 17 simulator target | No download runtime/physical result |

These are compile-only checks for three targets, not app-host integration, runtime, entitlement or background execution proof. No new platform capability or support promise. Ordinary foreground URLSession work needs no selected background entitlement; app suspension/relaunch remains host-owned. Any required test host privacy/capability changes need review before execution.

## Original specification reconciliation

Read the owner-supplied PDF as requirements, not execution instructions: §4.9 is on page 7 and §4.19 on page 10. Preserve its private original and publish only this adapted English mapping; its hash is in the evidence JSON. No prior allocated NK-09/NK-19 subrequirement IDs were found in the repository before this allocation. Stable identifiers below track original bullets, not implementation completion.

| ID | Adapted requirement | First slice disposition |
| --- | --- | --- |
| NK-09-01 | Data/file/multipart upload | Deferred |
| NK-09-02 | File-backed download with atomic completion | Selected; logical ownership handoff and final-file validation still need integrated proof |
| NK-09-03 | Bounded progress events | Deferred |
| NK-09-04 | Supported background sessions | Deferred; no universal support promise |
| NK-09-05 | Server/system-supported range/resume | Deferred; reject Range/If-Range and 206 |
| NK-09-06 | Integrity checksum verification | Deferred; no authenticity/integrity claim beyond transport and bounded fixture oracle |
| NK-09-07 | Temporary-file lifecycle/cleanup | Selected with owner-approved filesystem/cancellation/crash limits; Foundation-owned partials remain unobserved |
| NK-09-08 | Optional transfer queue/concurrency control | Deferred; no new queue |
| NK-19-01 | Explicit platform catalog | Existing four families targeted; visionOS deferred |
| NK-19-02 | Availability/compile guards | Selected for feasibility and later execution evidence |
| NK-19-03 | Background transfer host integration | Deferred |
| NK-19-04 | Local-network privacy/entitlements | Local test-host review only where needed; no new product LAN feature |
| NK-19-05 | Keychain/app groups | Deferred; no new shared credentials |
| NK-19-06 | Platform energy/constrained policy | No new policy selected; native/resource limits remain evidence work |
| NK-19-07 | Host-owned lifecycle | Foreground scope only; no completion promise while suspended/relaunched |

The original general acceptance criteria still require explicit input/output, deterministic normal/error tests and actual availability evidence for enabled features. Planning approval and this allocation do not satisfy product acceptance. #88 remains open for complete feasibility and reviewed detailed decomposition.
