# Security, authentication, and network policy for v1

I08 implements strict owned-session storage defaults and bounded injection compatibility checks; see [session transport review](SESSION_TRANSPORT.md). This is not complete HTTPS/redirect/authentication/lifecycle enforcement; those remain later tasks.

Status: Planned contract, 2026-10-19. Core choices are accepted in [ADR-0007](../decisions/ADR-0007-security-and-network-policy.md); details elaborate secure defaults. I02 validates foundational values and their descriptions with local tests. The transport, authentication, storage, and logging policies remain unimplemented; no complete security guarantee is claimed.

I04 adds structural URL validation and same-origin raw-URL checks; see [endpoint evidence](ENDPOINT_URLS.md). These do not implement the execution, TLS, loopback-permission, or redirect policies below.

## URLs, permitted origins, and local development

Production defaults to HTTPS with OS system trust. Each client has an explicit base origin: scheme, normalized host, and effective port. Typed endpoints cannot change it through path/query. Raw requests to another origin require explicit client-configuration permission before execution. A permitted destination does not permit sharing credentials across origins; bind authentication to the specific origin and app account/environment.

An explicit development option may allow HTTP only to normalized localhost or a valid loopback IP (127.0.0.0/8 or ::1). Use actual URL/IP parsing, not suffix/substring matching, concealed numeric representations, or DNS resolution as general permission. Exclude localhost.example.com, .local, RFC1918/LAN addresses, and other domains. Treat IPv4/IPv6 variants conservatively; reject forms not unambiguously validated as loopback.

The option defaults off and is not enabled merely because a URL contains a familiar name. Do not add or weaken host-app ATS settings. The app must assess and verify necessary narrow OS/app exceptions per platform. Library URL permission does not guarantee OS permission to connect.

Do not invoke authentication providers or send sensitive credential headers over HTTP, including loopback. Local services needing authentication use HTTPS with normal trust validation. No invalid certificates, TLS bypass, custom cryptography, or automatic trust-root installation.

## Cookies, credentials, and cache

Create the owned default session from ephemeral configuration, additionally disabling storage explicitly:

- No httpCookieStorage or automatic cookie receipt/sending in configuration/requests.
- No URLCredentialStorage or automatic Basic/Digest/client-identity authentication from stores.
- No URLCache; use a policy that does not use local cache. No hidden library memory/disk cache.
- No payload, token, cookie, or diagnostic file writes as library side effects.

Ephemeral alone allows system data in RAM and is insufficient for this default. Active requests and authentication headers necessarily exist temporarily in memory; this is not a zero-copy, secure-erasure, or no-OS/app-diagnostics guarantee.

An explicit app-managed storage profile may customize URLSession stores/cache or borrow an app session using them. Describe actual storage and app responsibility for account isolation, capacity, and deletion. This adds no custom cache/offline/TTL strategy. Automatic storage remains off without explicit selection. Such profiles cannot weaken HTTPS, origin, redaction, or redirect rules.

## Authentication provider and header precedence

Apps may inject an asynchronous authentication-header provider. Limit input to necessary origin, request ID/method, and explicit account/environment context; do not automatically expose body, all headers, or raw URL parameters. The app makes the provider concurrency-safe or isolates it. It runs within operation cancellation and total time budget.

The app owns login, token/Keychain storage, renewal, logout, and account selection. No automatic 401 refresh, hidden replay, or provider loop. Invoke the provider once per original operation; do not copy its values to a new redirect origin. Callers may explicitly choose a public/no-provider call. This does not disable security; apps must also avoid adding sensitive explicit headers to public calls.

Explicit request headers override ordinary defaults under the HTTP contract. Validate provider headers with the same name/CRLF rules. Differing provider and explicit authentication values for the same name cause invalidRequest rather than hidden credential replacement. Identical values are not distinct credentials. Global sensitive headers must be origin/account scoped; raw calls to another permitted origin do not inherit them.

URL userinfo and query secrets are unsupported authentication mechanisms. Normalize pre-network provider failures to safe invalidRequest with a provider-failure cause; preserve timeout/cancellation categories from the lifecycle contract. Do not dump raw provider error text to logs.

## Redirects and system trust

By default, automatically follow only same-method GET/HEAD redirects within the same normalized origin. Revalidate every destination against URL, scheme, and development rules. Follow at most five hops per operation; loops/excess cause safe invalidResponse. Same origin includes the effective port, not just hostname.

Do not automatically follow cross-origin redirects, HTTPS → HTTP, or redirects replaying a mutating request. The delegate rejects the redirect without contacting the destination. Process the resulting 3xx response under the normal status contract; explicitly accepting 3xx allows reading it, not automatic forwarding. Apps may deliberately make a new, separately validated call.

Never automatically send credentials, cookies, or app-sensitive headers to another origin. The original total budget applies across allowed redirects and does not reset at each hop. Typed and raw requests follow the same limits.

Trust challenges use system verification. The authentication provider is not a challenge/trust provider. Do not silently supply Basic/Digest/mTLS credentials from system stores as fallback; those features are outside this v1 boundary.

## Injected sessions

Injection explicitly trusts the app. The client never changes global session configuration, delegates, or stores, or invalidates the session. On creation, check accessible configuration and compatibility with the selected storage/security profile. Reject background sessions, which may follow redirects without required control.

The strict default profile requires disabled stores and automatic cookie handling on injected sessions too. Ordinary URLSession.shared/default sessions with active stores cannot qualify as strict defaults without an explicit app-managed storage profile.

Use the client's per-task delegate/policy boundary for redirects and task-level challenges where the selected URLSession API supports it. Existing session delegates cannot be replaced and may handle session-level trust challenges. V1 therefore rejects arbitrary external delegates capable of overriding trust/authentication/redirect policy rather than claiming compatibility. A minimal session without such a delegate is the planned injection baseline.

URLProtocol transport may be explicitly selected in tests. It does not prove production TLS, storage policy, or actual networking. App code/custom transports, proxies, OS policy, and external changes are outside a library security sandbox. If required control cannot be documented or enforced, reject the combination and resolve the gap before release; do not silently alter system semantics.

## Retries, offline behavior, and network cost

NetworkKit performs no automatic library retry, 401 refresh, status replay, connectivity probe, or offline-cache fallback in v1. One call starts one logical HTTP operation, but URLSession/OS may manage internal connection attempts. Allowed redirects are not a general retry policy. Do not promise exactly one wire request or rollback of sent mutations.

Owned sessions default waitsForConnectivity off; apps may explicitly select system waiting within the same total budget. Use actual request outcomes, not path monitoring as a preflight guarantee. Cellular/expensive/constrained access follows URLSession defaults with explicit client options where needed, without invented energy guarantees or global mutable policy. Check availability before adding newer platform properties.

## Logs, errors, and error bodies

No external telemetry, analytics, tracking, or SaaS sink. Default local diagnostic events use only a small allowlist: random request ID, known standard method (or “custom” without its raw string), status, measured duration, and safe error/terminal category. Do not automatically log raw URLs, hostname/path/query/fragment, bodies, headers, credentials, model descriptions, or underlying localizedDescription. Logging can be disabled.

App-managed sinks receive the same sanitized event model, without raw request/response hooks bypassing redaction. Sensitive logging by the host app outside the library is outside its protection.

HTTP status errors do not capture raw error bodies, and v1 offers no optional error-body capture mechanism. Retain no extra copy or payload in error text. URLSession's data API may already have read the response into memory; this is not a zero-network/memory-use guarantee for failures. Apps needing a specific API error payload may explicitly accept its status and select JSON/Data under all other contracts.

Return status/headers according to the HTTP contract, but do not expose sensitive headers in automatic error descriptions or logs. Preserve necessary system codes/causes without presenting underlying errors as safe to log.

## Required future acceptance evidence

- No automatic cookie/credential/cache storage in the strict profile; explicit opt-in distinguishes actual app-managed storage.
- Provider, explicit headers, conflicts, opt-out, origin/account scoping, and cancellation/deadlines through provider execution.
- HTTPS/system trust; development access off by default; valid localhost/loopback versus lookalikes, IP variants, private LAN, and redirects outside loopback.
- No credentials over HTTP, trust bypass, or automatic Basic/Digest/mTLS fallback.
- Same-origin GET/HEAD within five hops; no automatic cross-origin, port-changing, downgrade, mutating, or looping redirects.
- Injected-session profiles, delegate compatibility, rejected background/unsupported combinations, and no invalidation of others' sessions/tasks.
- Token/cookie/URL/body/error-description redaction on every error/diagnostic path; no hidden telemetry, error-body capture, or 401/503 replay.
- System connectivity/cost policy and the same 30/60 budget across permitted hooks/redirects.

Break requirements into traceable tasks before Ready and execute only after implementation authorization. [CI_AND_TEST_PLAN.md](CI_AND_TEST_PLAN.md) / ADR-0008 defines planned tests/runtimes. Actual execution and security evidence remain outstanding; I02 tests cover only value validation and safe descriptions; actual transport/storage/authentication/logging verification remains outstanding.
