# HTTP, response, and error contract for v1

Current I03 evidence: immutable configuration snapshots and internal transport/monotonic clock seams are implemented; 29 local tests passed. See [configuration review](CONFIGURATION.md). The HTTP client, enforced deadlines, and platform-wide verification remain outstanding.

Status: Planned contract, 2026-10-19; see [ADR-0005](../decisions/ADR-0005-http-api-contract.md). The owner selected the core choices; the rules below elaborate them. I02 implements the foundational value/error types with passing local contract tests; the client and transport pipeline remain unimplemented. See [HTTP_VALUES.md](HTTP_VALUES.md) for reviewed signatures, tests, and limitations.

## Public model and entry points

| Concept | Contract |
| --- | --- |
| NetworkClient / APIClient | Injectable client boundary and concrete URLSession-based client; a global singleton is not the only usage pattern |
| Endpoint | Describes an HTTP call, response type/strategy, and explicit call options |
| NetworkConfiguration | Client baseURL, default headers, and configuration; concurrency and snapshots follow DEC-05 / ADR-0006 |
| HTTPMethod | GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, and an explicit valid HTTP method string |
| NetworkResponse | Decoded value, HTTP status, and response headers, including metadata for Data/text/empty responses |
| EmptyResponse | Explicitly indicates that no response model is decoded |
| NetworkError | Structured ordinary failures; cancellation remains separate as CancellationError |

Typed endpoints are the default. Raw URLRequest is an alternative request-building input; consumers still select a response strategy and any status exception. Although raw requests are already constructed, validation and the same client pipeline apply. Reject unsupported inputs rather than ignoring them.

Support JSON models, Data, and text without forcing every response through one generic JSON/Decodable strategy. Exact Swift signatures, enum case names, and source code are not decided here; the concepts and behavior guide later API review.

## URLs and parameters

Inject an explicit baseURL that is a valid absolute HTTP(S) URL. The [security policy](SECURITY_AND_NETWORK_POLICY.md) / ADR-0007 allows HTTPS and an explicit development-only localhost/loopback exception. A relative endpoint path must not inadvertently replace scheme, host, or port. Fragments and URL userinfo are not request parameters or credential channels.

Build paths from explicit segments, encoding each segment. Segment data must not become separators, query text, or a new origin. Handle dot/traversal segments and malformed input explicitly, returning validation errors when they would change the intended path. Pre-percent-encoded text is not the standard input; avoid double encoding and crashes on invalid encoding.

Queries are ordered lists of names and optional values. Preserve ordering and repeated names; represent arrays with repeated names. Omitted parameters are absent, nil means a name without an equals sign, and an empty string means an explicitly empty value. No automatic bracket/comma/form encoding in v1. Use raw requests for special contracts, subject to the same URL/security validation.

Build URLs from components, not unsafe string concatenation. No manual HTTP-version-negotiation guarantee is provided.

## Headers

Compare header names case-insensitively. An explicit request value overrides the client default with the same name, never the reverse. Invalid names and CR/LF input cause invalidRequest before networking. Do not arbitrarily combine conflicting duplicates.

Default Content-Type is application/json for JSON, text/plain with UTF-8 for text, and application/octet-stream for Data when none is explicitly selected. Explicit call Content-Type takes precedence as a deliberate choice; it does not automatically change the body encoder. Do not add a body content type when no body exists.

Do not manually compute transport-managed fields such as Content-Length. URLSession governs final system handling. Authentication providers, header conflicts, and redirect boundaries follow ADR-0007 without a general interceptor framework. Reject differing provider/explicit authentication values for the same name.

Response headers support case-insensitive lookup. Preserve values as URLSession exposes them; do not promise original casing, raw ordering, or repeated wire headers already combined by the system. Metadata accessible to the app is not automatically permitted in logs or error text.

## Body and response strategies

| Variant | Request | Response |
| --- | --- | --- |
| JSON | Encodable payloads with configurable Apple JSONEncoder strategies | Explicitly selected model with Apple JSONDecoder strategies |
| Data | Raw bytes with Content-Type | Raw Data without JSON decoding |
| Text | UTF-8 text | UTF-8 by default; unsupported or invalid declared encoding causes decoding failure rather than silent data loss |
| Empty | No request body | Explicit EmptyResponse, without JSON decoding |

Select encoder/decoder strategies before execution. Mutating a shared instance during a request is outside the contract; ownership and concurrency follow the [lifecycle contract](CONCURRENCY_AND_LIFECYCLE.md). A general custom-decoder/plugin framework is excluded.

Validate status before normal response decoding. HEAD/204 may use the explicit empty-response contract. Empty body with a selected JSON model is a decoding/contract error; do not manufacture a default object. Empty Data/text are valid under those strategies. An explicitly empty response decodes no payload but still returns status/headers.

JSON accepts a missing Content-Type; when supplied, it must be application/json or a +json subtype. Another declared format causes invalidResponse before JSON decoding. Raw Data imposes no JSON content type. There is no general validation-disable mechanism; apps may handle a server's incorrect content type through raw Data and explicit app-side processing.

Multipart, body streams, file upload/download APIs, progress, streaming, XML/other formats, and WebSocket are deferred. Reject raw URLRequest with httpBodyStream as outside v1; it is not a back door to streaming. Entire Data responses are loaded into memory. Do not present v1 as a large-file/streaming library.

## HTTP status and pipeline

Success defaults to 200–299. A call may explicitly replace this with a nonempty valid set/range of HTTP status codes. Document this per-call choice; no hidden global accept-all policy. Accepted status does not bypass body contracts or security.

Status refers to the final HTTP response URLSession exposes after redirect policy. Accepting a status does not control redirects. ADR-0007 permits same-origin GET/HEAD redirects up to five hops, with no automatic cross-origin, downgrade, or mutating replay.

Planned order: validate input → build/validate request and encode body → apply configuration and security boundaries → execute URLSession → confirm HTTP response → validate status and any content type → apply response strategy → return NetworkResponse. Cancellation applies throughout. No library retry engine or token-refresh cycle is included.

## Error contract

| Category | Meaning |
| --- | --- |
| invalidRequest | Invalid URL, method, header, configuration, or unsupported input; local rejection performs no network operation |
| transport | System/network failure; retain relevant URLError code/cause, including trust/TLS failures, without credential dumps |
| httpStatus | Final status falls outside the explicitly accepted set; retain status and necessary metadata |
| invalidResponse | Non-HTTP response or contract violation, such as an incorrect declared Content-Type |
| encoding | Request body could not be encoded; no request is sent |
| decoding | An accepted HTTP response could not be interpreted as the selected model/text |
| timeout | Separate from ordinary transport failures; defaults to 30-second inactivity / 60-second total budget under ADR-0006 |
| CancellationError | Separate from NetworkError for actual cancellation; normalize system cancellation signals using ADR-0006's recorded cause, distinguishing timeout from caller cancellation |

No category automatically authorizes retry. Default error text and diagnostics exclude tokens, cookies, raw URL parameters, and payloads. An underlying Error/metadata object is not permission to log everything. ADR-0007 excludes raw error-body capture in v1. Apps needing an API error payload may explicitly accept its status with a JSON/Data response contract.

## Required future acceptance evidence

- Contract parity between typed endpoints and raw requests; no security/status bypass.
- GET/POST and other selected methods, JSON/Data/text/EmptyResponse, 204/HEAD, status exceptions, and incorrect Content-Type.
- Reserved path characters, duplicate/nil/empty query values, malformed URLs/encoding, and origin/path substitution attempts.
- Case-insensitive headers, defaults versus call overrides, CR/LF rejection, and explicit Content-Type.
- Transport failures, timeouts, encoding/decoding failures, invalidResponse, and cancellation before/during operations.
- Errors/logs without sensitive default data; response headers respect documented system limitations.

Break remaining behavior into traceable tasks before Ready. I02 value/error tests have passed locally; pipeline tests remain outstanding. The [platform matrix](PLATFORM_MATRIX.md), QUALITY.md, and DEC-05–DEC-07 add requirements. F0 acceptance and separate explicit implementation authorization are required before code.
