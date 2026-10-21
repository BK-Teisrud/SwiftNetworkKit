# SwiftNetworkKit

[![CI](https://github.com/BK-Teisrud/SwiftNetworkKit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/BK-Teisrud/SwiftNetworkKit/actions/workflows/ci.yml)

A native networking library for Apple platforms, planned as a Swift package with no external package dependencies.

**Status: Implementation started; HTTP values, configuration, buffered request construction, and response interpretation implemented; an internal URLSession adapter is available.** The Swift package is named SwiftNetworkKit and exposes the NetworkKit library. Public HTTP request execution is not implemented yet; do not treat this as a functional networking library. See [implementation authorization](docs/decisions/ADR-0012-implementation-start.md) and [package-baseline evidence](docs/planning/PACKAGE_BASELINE.md).

Open the repository-root Package.swift in Xcode. The original nested Xcode starter has been moved into the standard root package layout. The NetworkKit test target now contains contract tests for values, errors, configuration, URLs, JSON/Data/text request construction, and JSON/Data/text/empty response interpretation. The internal adapter has isolated URLProtocol tests; the public networking client and security pipeline are not implemented.

## Project foundations

Foundation/URLSession is the primary HTTP transport. Swift Concurrency, injectable services, system trust, and privacy-preserving defaults guide the design. Network.framework may be considered for specific low-level requirements. The project will not implement its own HTTP, TLS, or cryptographic stack, or provide a backend product.

The repository and package are named **SwiftNetworkKit**. The library product, module, and import name will be **NetworkKit**, with one library module in v1. The first stable release is limited to the HTTP core; other modules are deferred. The package and target now exist; HTTP request execution remains planned. See [v1 scope](docs/planning/V1_SCOPE.md) and [ADR-0003](docs/decisions/ADR-0003-v1-scope-and-naming.md).

## Documentation

- [Session ownership, internal transport, and limitations](docs/planning/SESSION_TRANSPORT.md)

- [Response strategies, status policies, and test evidence](docs/planning/RESPONSE_DECODING.md)

- [Real CI, required quality gate, and verification evidence](docs/planning/CI_IMPLEMENTATION.md)

- [Request bodies, header precedence, and actual test evidence](docs/planning/REQUEST_ENCODING.md)

- [Endpoint API, URL validation, and test evidence](docs/planning/ENDPOINT_URLS.md)

- [Configuration API, internal seams, and test evidence](docs/planning/CONFIGURATION.md)
- [HTTP value API and actual test evidence](docs/planning/HTTP_VALUES.md)
- [Readiness review before implementation](docs/planning/PRE_CODE_READINESS.md)
- [Numbered work queue](docs/planning/WORK_QUEUE.md)
- [Test environment inventory and outstanding minimum-OS evidence](docs/planning/TEST_ENVIRONMENTS.md)
- [Setup status and verification](docs/governance/SETUP_STATUS.md)
- [GitHub settings and rules](docs/governance/GITHUB_CONFIGURATION.md)
- [Workflow and project management](docs/planning/PROJECT_MANAGEMENT.md)
- [Historical F0 planning approval](docs/planning/F0_REVIEW.md)
- [CI and test plan](docs/planning/CI_AND_TEST_PLAN.md)
- [Security and network policy](docs/planning/SECURITY_AND_NETWORK_POLICY.md)
- [Concurrency and lifecycle](docs/planning/CONCURRENCY_AND_LIFECYCLE.md)
- [HTTP, response, and error contract](docs/planning/HTTP_API_CONTRACT.md)
- [Platform and toolchain matrix](docs/planning/PLATFORM_MATRIX.md)
- [Roadmap and delivery gates](docs/planning/ROADMAP.md)
- [Requirements traceability and backlog](docs/planning/BACKLOG.md)
- [Specification baseline](docs/planning/SPECIFICATION_BASELINE.md)
- [Decision log](docs/decisions/README.md)
- [Quality gates and test strategy](docs/governance/QUALITY.md)
- [Release and compatibility policy](docs/governance/RELEASE_POLICY.md)
- [Risk register](docs/planning/RISKS.md)
- [Contributing](CONTRIBUTING.md), [security](SECURITY.md), and [governance](GOVERNANCE.md)

## Platforms and rights

Approved v1 targets: **iOS/iPadOS 17+, macOS 14+, watchOS 10+, and tvOS 17+**. visionOS is deferred. Development baseline: **Xcode 26.3+, Swift tools 6.2, and Swift 6 language mode with strict concurrency checking**. See the [platform matrix](docs/planning/PLATFORM_MATRIX.md) and [ADR-0004](docs/decisions/ADR-0004-platforms-and-toolchain.md). PR CI now builds all four platform families and runs the product contract tests on macOS plus iPhone, iPad, Apple Watch, and Apple TV simulators. The required quality-gate also covers source integrity and DocC. Minimum-OS and physical-device release evidence remains outstanding; see the CI implementation and platform matrix.

**Rights holder: Teisrud Development AS. SwiftNetworkKit is proprietary.** Third-party use requires separate written permission from the company, subject to statutory rights and GitHub's applicable terms. Public visibility permits viewing and forking through GitHub; the project grants no additional open-source license or general permission to use the material in applications.

See the [rights notice](LICENSE) and [ownership and rights decision](docs/decisions/ADR-0002-ownership-and-rights.md). Ask maintainer @BK-Teisrud for a confirmed permission-request contact channel; do not share confidential information publicly.

## Language

All repository documentation and GitHub project content use English. The owner and assistant continue to communicate in Norwegian. See [the language policy](docs/governance/LANGUAGE_POLICY.md).
