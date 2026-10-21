# URLSession ownership and the internal transport adapter

I08 / #49, 2026-10-21. `URLSessionTransport` implements the internal NetworkTransport
boundary using one foreground URLSession. It is not a public HTTP client. The adapter
is only exercised with explicit test URLProtocol fixtures in this task; no public
network requests or production TLS/security claims are made.

## Construction and storage

The owned configuration starts from ephemeral and explicitly disables even automatic
in-memory stores. Ephemeral alone is insufficient: Apple documents its private memory
cookie/cache stores.

| Setting | Owned strict default |
| --- | --- |
| httpCookieStorage | nil |
| httpShouldSetCookies | false |
| httpCookieAcceptPolicy | never |
| urlCredentialStorage | nil |
| urlCache | nil |
| requestCachePolicy | reloadIgnoringLocalCacheData |
| waitsForConnectivity | false |
| timeoutIntervalForRequest | Selected inactivity limit, default 30 seconds |
| timeoutIntervalForResource | Platform ephemeral default, independently limiting calls |

The strict request copy also sets httpShouldHandleCookies=false and the same cache
policy, preventing raw request settings from re-enabling automatic handling. The
original request remains unchanged. Explicit header fields are not automatic storage;
scoped authentication and sensitive-header rules remain I09/I14 work.

An owned adapter validates and copies its configuration before constructing one session;
all sends reuse that session. Custom protocolClasses are an internal test seam, not a
public transport plugin. Background configurations and invalid finite/positive session
timeouts are rejected before creating an owned session. Protocol fixtures intercept
all requests in their selected test sessions; an unknown fixture fails locally.

## Borrowing and compatibility

`init(session:storagePolicy:)` borrows the app's existing session. It checks accessible
configuration without changing it. Background sessions and any external session
delegate are rejected as unsupportedRequest. A delegate could override future trust,
authentication, or redirect policies; accepting arbitrary delegates would overpromise
compatibility.

The default strict profile requires all disabled-store/cookie/cache settings above.
An ordinary ephemeral/default/shared session with active stores does not qualify.
An explicit internal appManaged policy accepts app-controlled stores/cache/cookie
settings, while retaining foreground/no-external-delegate checks. It is an assembly
boundary for the later client API, not a public storage/cache feature added here.
Apps retain responsibility for account isolation, deletion and limits under that policy.

The adapter never changes an injected session's global configuration/stores, calls
reset/flush/getAllTasks, or invalidates it. It never creates a replacement when the
borrowed session fails. App-managed storage cannot bypass the security pipeline that
must be connected in I09/I10 and verified in I16.

## Concurrency, invalidation, and system limits

The adapter is an actor; network awaits are reentrant, allowing concurrent operations
on one session rather than serializing all network waiting. send returns buffered Data
and URLResponse. Body streams are rejected before transport. It checks cancellation at
entry and after data delivery; safe transport-error normalization and terminal-cause
arbitration remain later pipeline/lifecycle work.

`invalidateOwnedSession()` is an internal ownership primitive. It is idempotent, rejects
later owned sends as clientClosed, and cancels/invalidates only an owned session.
Borrowed sessions are untouched. Deinitialization also invalidates only owned sessions.
Full client shutdown, active-operation registries, borrowed-operation cancellation,
shared completion and watchdog cleanup remain I12/I13; this primitive is not that API.

External invalidation can stop a currently active borrowed operation; a test verifies
Foundation's URLError.cancelled is preserved for later cause classification. The app
must keep an injected session valid while lending it. In an isolated local experiment,
starting a *new* async data task after session invalidation raised an Objective-C
NSException rather than a catchable Swift error. Foundation exposes no reliable public
is-invalidated query. The adapter does not promise to detect/recover from an already
invalid session; the later client must prevent reuse after its own closure, and app
invalidation remains outside the ownership contract. No replacement/retry hides it.

The adapter preserves the system resource timeout instead of setting a hidden 60-second
cap. A shorter injected/system resource timeout still wins, and an arbitrarily longer
library total budget cannot extend it. The per-request inactivity limit is already set
by RequestBuilder; the monotonic whole-operation budget remains I12 work. Synchronous
hooks and OS scheduling do not gain a hard real-time guarantee.

The current internal adapter uses Foundation data(for:), without the I09 redirect/trust
policy delegate. It must not be exposed as a complete secure client before that policy
and the shared typed/raw pipeline are connected. No automatic library retry/cache or
file/stream/background API is introduced.

## Verification and availability

The full local suite passes 98 test functions in 15 suites on macOS 15.8.1 x86_64,
Xcode 26.3 / Swift 6.2.4. Fourteen new tests cover strict configuration, request copies,
owned reuse/snapshots/invalidation, borrowed reuse after adapter cleanup/deinit, explicit
app-managed storage, rejected delegates/stores/limits/backgrounds, streams, cancellation
at entry, 20 concurrent calls, active external invalidation, and resource-budget limits.
The background constructor is tested where available (macOS/iOS/watchOS); tvOS instead
asserts the owned foreground configuration because it does not offer that constructor.

The test-only URLProtocol subclass restates Foundation's inherited unchecked Sendable
conformance. Its instances have no mutable fields; the shared per-URL fixture registry
is protected with OSAllocatedUnfairLock. No library unchecked Sendable declaration is
introduced. Unique fixture URLs and per-session protocolClasses prevent cross-test
or public-network dependencies.

The inspected SDK 26.2 Foundation interface declares data(for:delegate:) from macOS 12,
iOS 15, watchOS 8 and tvOS 15, within every selected minimum. The test lock is available
from macOS 13/iOS 16/watchOS 9/tvOS 16. Actual hosted PR/main evidence is recorded on
[issue #49](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/49) before completion.
No minimum-OS, physical-device, TLS, redirect, secure-erasure or full shutdown claim follows.

Primary references: [Apple URLSession](https://developer.apple.com/documentation/foundation/urlsession),
[ephemeral configuration](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/ephemeral),
[cookie storage](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/httpcookiestorage),
and [session invalidation](https://developer.apple.com/documentation/foundation/urlsession/finishtasksandinvalidate()).
