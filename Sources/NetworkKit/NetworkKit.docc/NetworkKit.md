# ``NetworkKit``

Construct typed HTTP requests and interpret buffered responses for Apple platforms.

## Overview

NetworkKit currently provides HTTP values, immutable configuration, safe endpoint URLs,
buffered JSON, Data, and UTF-8 request construction, and explicit response strategies. An internal URLSession adapter has ownership and isolated transport tests; a public executing networking client
is not available yet. Constructing a URLRequest does not authorize network access or
prove TLS, redirect, session-storage, cancellation, or minimum-OS behavior.

Define an ``Endpoint`` with an ``EndpointPath`` and optional ``HTTPQueryItem`` values.
Use ``NetworkConfiguration`` for client defaults and ``NetworkCallOptions`` for explicit
call headers/timeouts. ``RequestBody`` describes buffered data; ``JSONEncodingOptions``
selects value-based Apple JSONEncoder strategies with a new encoder per preparation.

Ordinary failures use ``NetworkError``. CancellationError remains a separate Swift error.
See the repository's planning guides for exact request rules, actual test evidence,
remaining implementation tasks, and the proprietary rights policy.

## Response interpretation

Select ``ResponseStrategy`` for JSON models, Data, strict UTF-8 text, or explicit
``EmptyResponse``. ``JSONDecodingOptions`` applies immutable native settings to a fresh
JSONDecoder per response. ``HTTPStatusPolicy`` defaults to 200...299 and allows explicit
per-call replacements through ``NetworkCallOptions``. Status is checked before payload
decoding; returned ``NetworkResponse`` retains status and case-insensitive headers.
An empty JSON response fails decoding; an explicitly empty strategy skips body decoding.
These APIs process buffered values and do not execute HTTP requests.

## Session foundation

An internal foreground URLSession adapter reuses one owned session or borrows an
app-owned session. Strict defaults explicitly disable automatic cookie, credential,
and cache stores. Borrowed sessions are never invalidated by the adapter. This is
not yet the public client or complete redirect/trust/deadline/shutdown pipeline.
See the repository session transport guide for compatibility and lifetime constraints.
