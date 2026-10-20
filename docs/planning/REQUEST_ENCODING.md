# Headers and buffered request encoding

I05 / #46, implemented 2026-10-20. Request construction is local and sends no traffic. It does not authorize network execution or implement the complete network security policy.

## Reviewed API

`Endpoint` now also provides `body: RequestBody?` (default nil) and `options: NetworkCallOptions` (default `.default`). `endpoint.request(configuration:) throws -> URLRequest` constructs an independent request with the endpoint method/URL, effective headers, encoded body, and resolved inactivity timeout. Response strategies follow in I07, and execution in I10.

`RequestBody` is an immutable Sendable description with `.data(Data)`, `.text(String)`, and `.json(value, options:)` factories. JSON models must conform to Encodable and Sendable. Nil is no body; empty Data/text are explicit zero-byte bodies. Data and strings use Swift value semantics. JSON retains the Sendable model until encoding; it does not deep-clone application reference types or make an incorrectly unchecked-Sendable model safe.

`JSONEncodingOptions` is a value policy mapped to Apple JSONEncoder settings:

| Setting | Choices | Default |
| --- | --- | --- |
| Dates | deferredToDate, secondsSince1970, millisecondsSince1970, iso8601 | deferredToDate |
| Keys | useDefaultKeys, convertToSnakeCase | useDefaultKeys |
| Data | base64, deferredToData | base64 |
| Nonconforming floats | throw, explicit strings for positive/negative infinity and NaN | throw |
| Output | Native JSONEncoder.OutputFormatting flags | [] |

Every JSON preparation creates a new JSONEncoder. No mutable encoder, DateFormatter, userInfo dictionary, or public generic codec factory is shared/exposed. Custom formatter/key closures are outside this API; apps needing another representation may explicitly encode their own Data. App Encodable implementations must be concurrency-safe and cooperative; synchronous custom encoding cannot be forcibly interrupted.

Ordinary encoding errors become the fixed `NetworkError.encoding`, without retaining error text/model/coding paths. CancellationError stays separate, and preparation checks task cancellation before and after encoding. Total deadlines, operation cancellation races, and cleanup remain I12/I13 work.

## Headers and supported inputs

Header names compare case-insensitively through HTTPHeaders. Typed requests resolve client defaults < endpoint call headers. Raw preparation resolves client defaults < raw URLRequest fields < explicit NetworkCallOptions headers. No list concatenation or inferred authentication-provider merging occurs. Auth providers/scoped credentials remain I14 work.

| Body | Derived Content-Type if no explicit value exists |
| --- | --- |
| JSON | application/json |
| UTF-8 text | text/plain; charset=utf-8 |
| Data, including an existing raw httpBody | application/octet-stream |
| No body | No derived header |

Explicit Content-Type from call/raw/client headers remains deliberate and does not change how bytes are encoded. Explicit headers may remain on a bodyless request; the library adds no inferred body type in that case.

Content-Length, Transfer-Encoding, and Host are rejected as unsupported request fields; URLSession must control framing/origin. The library never calculates Content-Length. GET/HEAD with a body (including empty Data) are rejected before transport in both call styles. The bounded foreground-data API offers no GET/HEAD body semantics or stream/multipart/file/streaming escape hatch.

Custom HTTPMethod values remain case-sensitive. If Foundation changes a typed method's spelling when storing it in URLRequest (for example `get` to `GET`), construction fails with unsupportedRequest rather than silently changing the method. Standard methods use their explicit uppercase HTTPMethod constants.

## Raw request boundary

Internal `RequestBuilder.prepare` preserves the raw URL/body and unrelated request settings in a copy, checks URL/origin through I04's shared validator, validates the exposed method/headers, and rejects httpBodyStream. Explicit call/client timeouts determine the copy's inactivity limit; URLRequest.timeoutInterval alone is not an override. The prepared internal value also carries the total budget, which is not yet enforced.

Foundation may already discard CR/LF-containing raw fields, collapse differently cased keys, or normalize method spelling before NetworkKit receives a URLRequest. Original discarded input cannot be recovered. The library validates all exposed values and does not recreate rejected fields. Use HTTPHeaders/typed call options to validate original header input and conflicting case variants before Foundation handles it. This boundary is covered by tests and is not a claim that the library can diagnose already-erased input.

Raw construction remains an internal seam until the executing API is connected in I10. Header validation alone does not enforce HTTPS, loopback permissions, redirects, cookies/credential storage, or injected-session policies. I08/I09/I14/I16 must apply those contracts before release. No transport is invoked by these builders.

RequestBody, JSONEncodingOptions, and internal PreparedRequest descriptions exclude payloads, URLs, header values, and custom float strings. Returned URLRequest and explicitly accessed properties are sensitive application data; default Foundation descriptions are not library diagnostic events and must not be dumped to logs.

## Actual evidence

- `swift test`: 64 tests in 11 suites passed on macOS 15.8.1 x86_64, Xcode 26.3 / Swift 6.2.4. All existing tests and 20 new test functions passed (parameterized functions count as one).
- Tests cover JSON native strategies/null/nonconforming floats/formatting, exact binary and Unicode UTF-8 bytes, header precedence/casing/conflicts/controls, Content-Type and no-body behavior, raw parity/copy/timeout behavior, unsupported methods/managed fields/streams, sanitized encoding failures, separate CancellationError, and 100 concurrent preparations reusing JSON bodies with distinct strategies and per-call headers.
- A separate executable consumer built from a fresh scratch directory, imported the public API without @testable, and constructed/inspected a JSON request successfully.
- A deliberate snake-case strategy mutation in an isolated copy failed the encoding tests. The repository source was unchanged by that negative control.
- No requests were sent. No CI workflows, all-platform/minimum-OS runtime evidence, transport, total-deadline enforcement, or release artifacts are included. See the platform matrix and work queue for remaining gates.

Next: I06 / #47, real PR CI for all four platform families.
