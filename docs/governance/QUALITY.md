# Quality gates and future test strategy

I03 foundation evidence: immutable configuration snapshots and internal transport/monotonic clock seams are implemented; 29 local tests passed. See [configuration review](../planning/CONFIGURATION.md). The executing HTTP client, enforced deadlines, and minimum-OS/physical-device verification remain outstanding.

These are requirements for later implementation. I01 verified package wiring. I02 adds passing local value/error contract tests; I04 adds endpoint URL construction and raw-URL validation; I05 adds request encoding and header precedence, and the full local suite passed 64 tests. See [request evidence](../planning/REQUEST_ENCODING.md). See [endpoint evidence](../planning/ENDPOINT_URLS.md). I06 adds hosted platform/source/DocC CI with required quality-gate enforcement; see [CI evidence](../planning/CI_IMPLEMENTATION.md). I07 adds local response strategy/status-policy contract tests; see [response evidence](../planning/RESPONSE_DECODING.md). I08 adds isolated URLProtocol session-ownership/storage-profile tests; see [session evidence](../planning/SESSION_TRANSPORT.md). I09 adds HTTPS/origin/loopback/redirect/challenge tests and real macOS loopback integration; see [security evidence](../planning/NETWORK_SECURITY.md). The public executing HTTP pipeline, native device/TLS evidence and full lifecycle/security review remain outstanding.

## Before implementation

Approved v1 scope, rights policy, platform/toolchain matrix, API/error model, concurrency/cancellation contract, and test strategy. Each included requirement has an input/output contract, normal/error paths, availability constraints, and requirement ID. Explicit implementation authorization remains a separate prerequisite.

## Pull requests after implementation starts

- Build with selected Swift/Xcode and strict concurrency; no undocumented warnings or unchecked Sendable exemptions.
- Deterministic unit tests without public networking. Use mock clients, URLProtocol, and a controlled clock where appropriate.
- Cover success, errors, coding, empty responses, timeouts, cancellation, redirects, and cleanup.
- Follow the [lifecycle contract](../planning/CONCURRENCY_AND_LIFECYCLE.md) for ownership, snapshots, controlled-clock 30/60 limits, unambiguous terminal outcomes, and shutdown. Do not invalidate injected sessions or cancel other consumers' tasks.
- Security-critical negative tests: redaction, credential isolation, host changes, and idempotency.
- Shared-state, bounded-queue, and single-flight concurrency tests when those features are selected.
- Updated public API, availability, DocC, and migration guidance; no external Swift package dependencies.

## Platform matrix

[PLATFORM_MATRIX.md](../planning/PLATFORM_MATRIX.md) / ADR-0004 sets iOS/iPadOS 17, macOS 14, watchOS 10, tvOS 17, Xcode 26.3+, Swift tools 6.2, and Swift 6 mode. It distinguishes planned support from outstanding build/runtime evidence. Update tested OS, Swift, Xcode/SDK, builds, unit/integration tests, and devices after actual execution. visionOS is deferred. Check exact API symbols against every minimum before Ready. Simulator builds do not prove background execution, Keychain, entitlements, or physical-device networking.

## Introducing CI

[CI_AND_TEST_PLAN.md](../planning/CI_AND_TEST_PLAN.md) / ADR-0008 defines source-integrity, macos-core, ios-core, watchos-core, tvos-core, documentation, and quality-gate. Standard GitHub runners without paid add-ons build all four platform families on every PR once introduced. I06 implements real build/test/DocC/dependency checks with Apple/official tools; CI_IMPLEMENTATION.md records actual evidence. No always-green workflow or skipped product checks for missing Package.swift. Require checks only after successful real runs on main and a PR. Avoid path filters that leave required checks pending.

GITHUB_TOKEN defaults to read-only; justify write jobs individually. No pull_request_target execution of untrusted code or fork-PR secrets. Use Swift Testing primarily and XCTest for specific needs, with only necessary GitHub-owned actions pinned to full commit SHAs. Repository settings enforce SHA pinning too. No external reusable workflows. Introduce Dependabot/workflows only when actual manifests and approved tooling exist.

## Release

Require a documented test matrix and platform limitations, security review, chosen rights policy, complete public API/DocC, examples and migration guidance where relevant, changelog, and known issues. Do not impose an arbitrary coverage percentage; measure coverage and require evidence for selected contracts and negative security cases. Measure representative p50/p95 and memory usage on a documented machine/scenario before setting thresholds.
