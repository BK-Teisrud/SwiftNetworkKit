# I29 foreground download implementation

Date: 2026-11-01
Status: Implementation candidate; required PR/main acceptance pending. I30–I32 remain open.

## Authorization and resulting behavior

After completed I28/#146 and PLAN-F4/#88, the owner explicitly approved code start for I29–I32 under ADR-0015 and the [accepted design](I28_DOWNLOAD_DESIGN.md). This instruction supersedes earlier no-I29 statements only for those selected tasks, in order starting #147. New signing/device installation, purchases and publication remain excluded.

`APIClient.download(_:maximumBytes:options:)` now accepts only bodyless GET, a positive Int64 output maximum and DownloadOptions. HTTP 200 (including empty) returns NetworkResponse<DownloadedFile> with actual stored size. No body decoding, status override, retry, typed-file endpoint or new NetworkClient conformance requirement is introduced. Unsupported methods/bodies, Range/If-Range from request/default/call headers and invalid limits are rejected before provider/network; provider-supplied range headers are rejected before transport.

## Reused boundaries and narrow changes

The owned/borrowed URLSession adapter adds a file-backed native operation. A small shared validatedTask helper keeps existing request/storage/origin/delegate guards identical for data and file tasks. Register a returned native file before any throwing cancellation/delegate check. Existing send behavior and public constructors/protocol/error enums retain their signatures/defaults. The internal NetworkTransport has a default unsupported file method so existing test doubles remain valid; this is not a public transport/plugin API.

An operation-scoped candidate owner survives NetworkOperation terminal arbitration and child join. On failure it attempts cleanup before diagnostics/admission release; successful arbitration hands off once without a late cancellation check. Shutdown waits on the existing client registration before invalidating only owned sessions. No generic NetworkOperation rewrite or detached task/sleeper is added.

File preservation uses exclusive same-volume rename with no overwrite, buffering or cross-volume copy fallback. Inspection opens without following symlinks or blocking on special files, requires a regular file/nonnegative size and applies owner-only permissions. Cleanup unlinks only the operation's known candidate; a missing path is already absent, other removal errors are not swallowed. An unrelated collision target is never removed. Server filenames never select paths. The private fault seam is internal-only and filesystem work is serialized by the per-operation lifecycle.

DownloadError carries only bounded file/size/cleanup categories. Existing NetworkError and CancellationError remain separate. Ordinary failure plus removal failure maps to cleanupFailed(primary:); cancellation/timeout remain primary without a separate cleanup-error stream. New file errors use existing diagnostic outcome .other and at most one attempt; no event field/path/filename/byte count is added.

## Actual local validation

[Source-hashed evidence](evidence/I29_FOREGROUND_DOWNLOAD_2026-11-01.json) records the unchanged base, exact candidate file hashes and host. Swift 6 compilation/test runs use warnings as errors.

- Whole Mac regression: **256 declarations in 32 suites passed** (245 previous plus 11 new). Parameterized cases are not extra declarations.
- DownloadTests: **11 declarations / 24 expanded cases**, including 200/empty ownership and auth once, pre-provider invalid requests/limits, 206/204/503 rejection without retry, exact-size/oversize file behavior, preserve/inspect/remove injection, original-deadline discard cleanup, cancellation with/without cleanup failure, unrelated-target collision, native-return cancellation ordering for owned/borrowed adapters, and joined shutdown/admission closure.
- Meaningful negative control: move native adoption after the cancellation check. Both session variants fail the source-file existence assertion. Restore source; all 11 download declarations pass again. This validates that the tests detect the real ownership-order invariant.
- Typecheck-only minimum targets: x86_64 iOS 17, watchOS 10 and tvOS 17 simulator targets passed. No simulator/device/native minimum execution claim is made from this.
- Shared iOS test-host membership now includes the new suite (26 shared files). Only source references change, not signing/settings/installations. Actual host/platform checks remain required in CI.
- Local source-integrity and its 22 helpers passed. DocC converted with warnings as errors; existing compiled integration examples build. New compiled download examples remain I32 work.

## Limits and next work

This task uses an injected native-return closure to test adapter ownership ordering; it has not run the candidate public API against real URLSession downloads. Earlier I28 native evidence stays tied to its older source. I30 owns the broader deterministic/security/isolation/failure matrix; I31 owns actual controlled native/trusted HTTPS/auth/storage/current/minimum and finite resource observations. I32 owns compiled download examples, final API/compatibility and owner technical gate. Local full-core success does not complete those tasks.

The maximum bounds only the successful stored file, not transient disk/memory. Foundation-owned partial files whose URL is never exposed cannot be attested deleted. Filesystem refusal/crash can leave known candidate files; synchronous IO can extend terminal return beyond the network deadline. Post-handoff retention/protection/backup/account deletion belongs to the app. No secure-erasure, workload suitability or production guarantee is claimed.

No additional issue, milestone or generic refactor is justified: #148–#150 already own the remaining work. After I29 PR/main acceptance, the next selected task is I30 #148. Domain #16/#26 remain open for deferred catalogs. #29 actual app/workload/security/publication and physical Watch #132 remain mandatory. No version/tag/release/publication.
