# ``NetworkKit``

Construct typed HTTP requests for Apple platforms.

## Overview

NetworkKit currently provides HTTP values, immutable configuration, safe endpoint URLs,
and buffered JSON, Data, and UTF-8 request construction. An executing networking client
is not available yet. Constructing a URLRequest does not authorize network access or
prove TLS, redirect, session-storage, cancellation, or minimum-OS behavior.

Define an ``Endpoint`` with an ``EndpointPath`` and optional ``HTTPQueryItem`` values.
Use ``NetworkConfiguration`` for client defaults and ``NetworkCallOptions`` for explicit
call headers/timeouts. ``RequestBody`` describes buffered data; ``JSONEncodingOptions``
selects value-based Apple JSONEncoder strategies with a new encoder per preparation.

Ordinary failures use ``NetworkError``. CancellationError remains a separate Swift error.
See the repository's planning guides for exact request rules, actual test evidence,
remaining implementation tasks, and the proprietary rights policy.
