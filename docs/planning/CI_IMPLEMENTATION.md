# Real CI implementation and activation

I06 / #47. Bootstrap PR: [#72](https://github.com/BK-Teisrud/SwiftNetworkKit/pull/72).
Activation is in progress; no required status check has been enabled yet. This document
records the implementation and local evidence without claiming pending hosted runs passed.
Hosted PR/main evidence and the enforcement negative control must be recorded before closure.

## Checks and exact environment

`.github/workflows/ci.yml` runs on every pull request, pushes to main, and manual dispatch.
There are no path filters, documentation-only bypasses, secrets, or publishing triggers.
Every matrix entry uses standard `macos-15` arm64 and explicit
`/Applications/Xcode_26.3.app/Contents/Developer`. Preflight requires Xcode 26.3 build
17C529, Swift 6.2.4, and the macOS/iOS/watchOS/tvOS device/simulator SDKs 26.2. The
actual image version, host OS, architecture, Xcode, Swift, SDKs, runtimes, selected
simulator names/UUIDs, and test summaries appear in job logs. No implicit tool fallback,
runtime download, or product minimum change is allowed.

| Stable check name | Actual work |
| --- | --- |
| source-integrity | Parse the real Swift manifest; verify product, targets, no external dependencies, tools/language mode, and OS minimums; parse tracked JSON and validate local Markdown file links; reject library SwiftUI imports/unchecked Sendable; verify matrix/action pins and run CI helper regression tests |
| macos-core | Generic macOS build and actual package-scheme tests on the runner host |
| ios-core | Generic iOS device build; actual tests on selected iPhone 17 and iPad (A16) simulators, iOS 26.2 |
| watchos-core | Generic watchOS device build; actual tests on a selected Series 11 watchOS 26.2 simulator, paired with an available iPhone 17 / iOS 26.2 companion if needed |
| tvos-core | Generic tvOS device build; actual tests on a selected Apple TV 4K (3rd generation) / tvOS 26.2 simulator |
| documentation | Extract real public NetworkKit symbol graphs and build the module's DocC catalog with warnings as errors, without a package plugin |
| quality-gate | On standard ubuntu-24.04, require the aggregate mandatory matrix result to be success; fail on failure, cancellation, missing result, or skip |

The Swift package's actual Xcode scheme is **SwiftNetworkKit**, distinct from the
**NetworkKit** product/module. A generated ignored `.swiftpm/xcode/package.xcworkspace`
uses Xcode's self-reference to open the package; no second distributed product or
hand-maintained application project is introduced. Test results must contain passed
executions, no failures/skips/expected failures, and no empty test plan. xcodebuild
build/test failures propagate. Unit/direct contract tests are meaningful at the current
implementation stage; unimplemented HTTP transport behavior is not claimed as tested.

## Resource and trust boundaries

The matrix has `max-parallel: 2`, `fail-fast: false`, and 30-minute job limits.
Only obsolete PR runs are cancelled automatically; main-run evidence is not deliberately
cancelled by a later PR push. Checkout is GitHub-owned and pinned to a verified full SHA,
with persisted credentials disabled. GITHUB_TOKEN is contents-read only. There are no
artifact uploads, cache actions, third-party setup/install/formatter tools, write jobs,
larger/self-hosted runners, paid services, or fork-PR secrets.

[Official runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md)
and [GitHub runner documentation](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
were reviewed on 2026-10-20. Inventory establishes availability, not actual passed checks
or a frozen image. Device UUIDs are discovered and logged per run. Local Markdown checks
validate file existence, not remote URL reachability, all anchor semantics, or guide accuracy;
manual review remains necessary. Branch check binding identifies GitHub Actions, not a
cryptographic guarantee against a maintainer deliberately changing the workflow itself.

## Local bootstrap evidence

- Xcode 26.3 / Swift 6.2.4 preflight and all expected SDK version checks passed on the
  owner's macOS 15.8.1 x86_64 machine. This is not hosted arm64 evidence.
- Source integrity passed, including three helper regression tests rejecting missing/
  unavailable runtimes/devices and empty/failed/skipped/incomplete test summaries.
- Actual public symbol extraction and DocC conversion passed with warnings as errors.
- A local watchOS simulator product build passed. It is a build, not watch runtime tests.
- The previous 64 product test functions have local macOS evidence from I05. Hosted
  xcresult counts may include parameterized cases; use actual per-run summaries.

## Required activation evidence

1. All seven checks pass on the bootstrap PR's final source revision.
2. Merge bootstrap through the existing PR rule, then obtain a successful main run.
3. Bind the exact `quality-gate` context to the verified GitHub Actions integration in
   main's required-status-check rule, without bypass actors, retaining existing rules.
4. Use a separate verification PR to demonstrate a deliberate failure produces a failed
   quality-gate and blocked merge state; remove the control and obtain all passing checks.
5. Record the commit/run links, actual environments/results, and rule read-back in
   repository documentation and #47 before marking complete.

Minimum iOS/iPadOS 17, macOS 14, watchOS 10, and tvOS 17 runtimes remain unverified.
Deployment targets and 26.2 simulator tests do not replace I21/I22 minimum-OS and physical
device release evidence. No release is published by this work.

## Bootstrap compatibility finding

The first complete platform attempt exposed the same URL-host test failure on iOS and
watchOS while macOS passed. URL validation now uses Foundation URLComponents.encodedHost
for its ASCII IDNA representation and handles IPv6 brackets explicitly, rather than
assuming URL.host returns identical representations on every OS. The existing origin
regression is parameterized to identify the failing host case directly. All 64 local
product tests passed after the fix; hosted confirmation remains required.

The watchOS package scheme did execute all 64 product test functions on its simulator;
the failed host assertion was not replaced with a build-only check. Companion logging
now reports the actual existing compatible pairing rather than an unused candidate.
