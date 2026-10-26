# Endpoint and URL construction

I04 / #45, implemented 2026-10-20. This is URL construction and validation, not a networking client or a complete network security policy.

I05 extends Endpoint with body/call options and buffered request construction; see [current request evidence](REQUEST_ENCODING.md). The API/evidence below records the I04 snapshot.

Current QA-01 / #97 removes the historical internal raw-URL seam described below: it had no production callers. Raw URL tests now exercise actual RequestBuilder preparation and current security reasons. See [quality review](QUALITY_REVIEW_2026-10-26.md); this does not rewrite the original I04 evidence.

## Reviewed public API

- `Endpoint: Sendable` has an associated `Response: Sendable`, `method: HTTPMethod`, `path: EndpointPath`, and ordered `query: [HTTPQueryItem]`. The defaults are GET and no query items. Body/call integration follows in I05; response strategies in I07. Response currently identifies the intended type without decoding it.
- `EndpointPath(segments:) throws` takes decoded strings. An empty array addresses the unchanged base path. Empty segments, dot/traversal components, backslashes, C0/C1 controls, and ambiguous percent-escape triplets are rejected with `invalidRequest(.invalidURL)`.
- `HTTPQueryItem(name:value:) throws` preserves query order, repeated names, Unicode, and nil versus empty values. Omit an item to omit a parameter. Nil produces `name`; an empty string produces `name=`. C0/C1 controls are rejected. No form/bracket/comma encoding is inferred.
- `endpoint.url(relativeTo:) throws -> URL` appends encoded segments to the explicit base path using URLComponents. Both `/api` and `/api/` become `/api/segment`; an empty segment list preserves the base URL, including its trailing slash. Segment/query text cannot replace scheme, host, or port, or introduce query/fragment delimiters.

Example (no network traffic):

```swift
struct UserEndpoint: Endpoint {
    typealias Response = EmptyResponse
    let path: EndpointPath
    let query: [HTTPQueryItem]
}
let endpoint = UserEndpoint(
    path: try EndpointPath(segments: ["users", "a/b"]),
    query: try [HTTPQueryItem(name: "tag", value: "a+b"), HTTPQueryItem(name: "flag")])
let url = try endpoint.url(relativeTo: URL(string: "https://example.invalid/api")!)
// https://example.invalid/api/users/a%2Fb?tag=a%2Bb&flag
```

## Encoding and validation rules

Only unreserved ASCII bytes remain unescaped inside a new segment or query component; other UTF-8 bytes are escaped once. Slash inside a segment is `%2F`, literal query plus is `%2B`, and query delimiters are data. Unicode byte sequences remain distinct, including decomposed accents and compound emoji. A literal percent such as `100%` becomes `100%25`.

Do not pass `a%2Fb` as a path segment: pass `a/b`. Escape triplets in decoded path input are explicitly rejected instead of guessed at, decoded again, or silently double encoded. A literal malformed-looking sequence such as `%ZZ` is plain decoded data and becomes `%25ZZ`. Query input is always literal data, so a query value `%2F` becomes `%252F` and decodes back to the intended literal `%2F`.

The base path's existing valid escapes are preserved. Existing base/raw path segments are decoded once for validation: dot/traversal components (including encoded slash traversal), controls, invalid UTF-8, backslashes, or residual escape triplets are rejected. This conservative rule excludes nested path encoding. It cannot guarantee how a remote server or proxy routes an encoded slash; apps must use a server contract that treats the segment appropriately.

Base URLs must be absolute HTTP(S) URLs without a Foundation relative-base reference, userinfo, fragment (including an empty one), or query (including an empty one). Provide query items explicitly rather than silently inheriting/discarding a base query. A host is required; Foundation's ASCII/IDN representation is restricted to letters, digits, dot, hyphen, and IPv6 colon syntax. Percent-encoded host aliases, zone identifiers, trailing-dot hosts, and invalid ports outside 1–65535 fail conservatively. This is structural URL validation, not DNS resolution or a complete hostname/IP permission policy.

The library receives Foundation URL values, not the original input strings. Foundation can already have encoded/repaired characters when parsing a string; the library cannot recover discarded input spelling. If an app needs strict string parsing, it must also validate at that input boundary. The library still validates the resulting URL and its decoded path/query.

## Raw-request parity and remaining boundaries

The internal `RequestURLBuilder.validatedURL(for:baseURL:)` uses the same structural validator. It preserves the raw URL without rebuilding/reordering its query. It rejects a missing URL or another origin. Origin comparison uses lowercased Foundation ASCII host and scheme, plus effective port (HTTPS 443 / HTTP 80); IDN and ASCII forms therefore compare consistently. IPv6 spelling aliases are conservatively treated as different until further normalization is reviewed. This check is an internal seam for the future raw-call pipeline, not a public raw execution API.

Raw paths can address another path within the same origin; typed paths append to the base path. Base queries remain invalid in both entry paths. Explicit permission for other raw origins and scoped authentication follow in I09/I14; no allowlist or credential forwarding is implemented here.

HTTP is recognized structurally here. It is not authorized for execution. I09 must enforce HTTPS by default, the explicit loopback-only development exception, and redirect rules; I10 must connect both call styles to that policy. Headers/body/session validation also follows in its ordered tasks. No code in I04 performs networking, TLS validation, redirects, encoding/decoding bodies, or request execution.

EndpointPath/HTTPQueryItem descriptions expose only counts/value presence. Errors contain a fixed category without input URLs, query text, or credentials. Explicit properties/returned URLs remain sensitive app data and are not safe automatic log fields.

## Actual evidence

- `swift test`: 44 tests in nine suites passed on macOS 15.8.1 x86_64 with Xcode 26.3 / Swift 6.2.4, including all previous tests and 15 new test functions (parameterized cases count as one function).
- Tests cover base path/root handling, Unicode byte preservation, every ASCII path byte, reserved characters, ordered/repeated/nil/empty query items, invalid URLs/controls/ports, encoded traversal, origin substitution, typed/raw parity, 50 concurrent endpoint copies, and safe errors/descriptions.
- A separate executable consumer imported, linked, and exercised the public Endpoint/EndpointPath/HTTPQueryItem API without @testable.
- An isolated negative control allowing literal slash through the component encoder failed the endpoint suite. The repository implementation was unchanged by that control.
- No requests were sent. CI, four-platform builds, minimum-OS behavior, server routing, and transport/security enforcement remain outstanding; see the platform matrix and later work queue tasks.

Next: I05 / #46, headers and request encoding.
