# Security

## Report privately

Use GitHub's **Report a vulnerability** under this repository's Security tab when private reporting is enabled. If the button is unavailable, open a public issue containing only “Requesting a private channel for a security report,” without details, and wait for a private channel. Do not publish vulnerability details, credentials, or personal information in public issues.

Maintainer: @BK-Teisrud. Targets: an initial response within three business days and an initial assessment within seven. These are goals, not a staffed 24/7 service or guaranteed SLA.

No product versions have been released. After 1.0, the latest stable minor of the current major receives maintenance; exceptions are documented in the release policy. Prereleases carry no production-readiness guarantee.

## Requirements for future implementation

System trust and HTTPS by default; no TLS bypass. [ADR-0007 and the security policy](docs/planning/SECURITY_AND_NETWORK_POLICY.md) specify an explicit development-only HTTP exception for localhost/loopback, no automatic cookie/credential/cache storage, a small authentication-header provider, and bounded redirect and diagnostic policies. These are planned requirements, not implemented or successfully tested security properties. No sensitive logging or external telemetry by default. Isolate credentials by account, host, and environment. Security review covers redirects, idempotency, cancellation, caching, and concurrency. Pinning, mTLS, and OIDC require separate decisions and review.

## Incidents

Confirm and contain the impact, rotate exposed secrets at the issuer, remove them from active surfaces, and assess history separately. Deleting a file does not make a public secret safe. Keep a private timeline of affected versions, remediation, and coordinated disclosure. Publish an advisory and corrected release when appropriate.

## Other confidential inquiries

No general private contact or licensing address has been published. Do not post confidential business information in public issues. GitHub's private vulnerability reporting is reserved for security findings; licensing and contribution processes will be offered only after the company establishes an appropriate contact channel.
