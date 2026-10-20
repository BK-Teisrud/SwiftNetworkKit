# Changelog

## Unreleased

### Package baseline

- Implementation started under ADR-0012 on 2026-10-20. Adapted the owner's Xcode starter into a repository-root Swift package: SwiftNetworkKit / NetworkKit, tools 6.2, Swift 6, OS minimums 17/14/10/17.
- Removed the empty example test; recorded actual macOS build and consumer-import smoke checks without claiming behavioral tests. No HTTP functionality or workflows yet.

### Project setup (historical)

- English is now the language of all documentation and editable GitHub project content; owner–assistant conversations remain in Norwegian. Existing decisions, identifiers, links, and implementation restrictions are preserved.
- Preparations completed through PR #65: one project status model, a sorted work queue, 23 implementation tasks, a separate start-authorization gate, hardened main/tag rules, immutable releases, and a test environment inventory. OPS-01 / #30 and F0 are complete; START-00 / #41 remains open.
- GATE-00 / #28 accepted: the owner approved the complete F0 planning baseline and documented defaults. Implementation remains unauthorized.
- Repository, workflow, security policy, roadmap, requirements traceability, and issue templates established.
- No library code or product release. No SemVer tag created.
- DEC-07 accepted: standard GitHub-hosted runners without paid add-ons, all four platform families on PRs, and separate release/minimum-OS checks. Action SHA pinning is enabled; no workflows exist.
- DEC-06 accepted: no automatic cookie/credential/cache storage, an injectable authentication-header provider, HTTPS with an explicit loopback exception, and bounded redirect/injection/diagnostic policies.
- DEC-05 accepted: a reused owned session plus injection, 30-second inactivity timeout / 60-second total budget, isolated state, cancellation, and controlled shutdown.
- DEC-04 accepted: typed endpoints and raw URLRequest, response wrapper, JSON/Data/text/empty responses, structured errors with a separate CancellationError, and explicit HTTP-status exceptions.
- DEC-01 accepted: iOS/iPadOS 17, macOS 14, watchOS 10, and tvOS 17; Xcode 26.3+, Swift tools 6.2, and Swift 6 language mode. The platform matrix distinguishes planned support from outstanding evidence.
- DEC-02 accepted: HTTP core first. Repository/package SwiftNetworkKit; product/module/import NetworkKit, with one library module in v1.
- DEC-03 accepted: Teisrud Development AS is the rights holder; proprietary rights policy with separate written permission required for third-party use.
