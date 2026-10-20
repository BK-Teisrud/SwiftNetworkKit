# Configuration snapshots and execution boundaries

I03 / #44, implemented 2026-10-20. This is a configuration foundation, not an executing HTTP client.

## Reviewed API

- `NetworkTimeouts(inactivity:total:) throws`: immutable seconds, default 30/60; each value must be positive and finite. `NetworkTimeouts.default` needs no throwing initialization. Total may be shorter than inactivity. All finite positive values are retained without arbitrary caps; the future deadline implementation must handle representational limits without overflow.
- `NetworkConfiguration(baseURL:headers:timeouts:)`: explicit URL, immutable validated HTTPHeaders and NetworkTimeouts. An omitted timeout policy uses the defaults.
- `NetworkCallOptions(headers:inactivityTimeout:totalTimeout:) throws`: immutable explicit overrides. Each nil limit inherits its client counterpart. Header values replace client defaults case-insensitively; unspecified headers remain. This does not implement auth-provider merging or origin-scoped credential forwarding.
- Internal `ConfigurationSnapshot` resolves each operation into independent Sendable values: call > client > defaults. There are no shared mutable dictionaries, encoder/decoder instances, or session settings.

Configuration accepts a Foundation URL as data. It does not yet validate URL construction, HTTPS/loopback, origins, redirects, or borrowed-session constraints. I04/I09 and the pipeline must validate before any networking; constructing a configuration is not proof that its URL is safe. No HTTP opt-in or network execution is exposed by this task. Body and codec snapshots will be added with their corresponding request/response strategies.

Configuration/call-option descriptions expose only header counts, excluding the URL and header names/values. Explicit properties remain accessible to the app and must not be dumped into logs.

## Internal seams

`NetworkTransport.send` accepts URLRequest and returns buffered Data plus URLResponse, allowing future non-HTTP response validation. It is internal and has no live adapter yet; I08 supplies URLSession ownership and transport behavior. It is not a public plugin framework.

`NetworkClock` uses ContinuousClock.Instant for now/deadline sleep. `ContinuousNetworkClock` delegates to Apple's monotonic ContinuousClock, including cancellable sleep. A test actor can supply scripted advancement without wall-clock delays. These are seams only: no watchdog, operation lifecycle, shutdown, cancellation normalization, or enforced HTTP budget is implemented. I12/I13 own those races and cleanup tests. URLRequest.timeoutInterval is not interpreted as an override.

## Actual evidence

- `swift test`: 29 tests in seven suites passed on macOS 15.8.1 x86_64, Xcode 26.3 / Swift 6.2.4. Eight new test functions cover defaults, independent override precedence, NaN/infinities/zero/negative rejection, finite extremes, 100 concurrent isolated snapshots, safe descriptions, a scripted transport, scripted monotonic advancement, and production sleep cancellation (parameterized tests count as one function).
- A separate executable consumer imported, linked, and exercised the public configuration API without @testable.
- An isolated copy with call-total precedence deliberately removed failed the configuration suite. The repository source was unchanged by this negative control.
- No network requests or actual timeout delays were used. No CI workflows or all-platform/minimum-OS evidence is claimed. Existing I02 tests also passed in the full run.

Next: I04 / #45, safe endpoint and URL construction.
