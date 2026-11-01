# Opt-in foreground download feasibility experiment

Non-shipping I28 / #146 research only. Not part of Package.swift, the public library or ordinary CI. Requires explicit owner feasibility permission (recorded 2026-11-01), existing Xcode/Swift, Python standard library and local OpenSSL. No new package dependencies.

Run from the repository root:

```sh
python3 Tools/DownloadFeasibility/run.py --output /private/tmp/snk-i28-result.json
```

The runner compiles the probe with unchanged SDK sources, binds only loopback servers, creates a temporary untrusted one-day TLS fixture, checks 28 native observations/server counters, and removes transient artifacts. Compile/execution have time bounds. A successful report includes source hashes, host and explicit evidence limits. Do not use private endpoints or credentials. Bounded fixture reads via Data are inspection oracles only.

See [the evidence report](../../docs/planning/I28_DOWNLOAD_FEASIBILITY_2026-11-01.md). This experiment is not a production transport, cleanup framework, APIClient integration, full-platform proof or permission for I29–I32. Generated private keys/raw logs/result paths stay outside git. Re-run only when investigation changes justify it.

## Operation-scoped ownership experiment

Run without network or TLS fixtures:

```sh
python3 Tools/DownloadFeasibility/run.py --handoff-only --output /private/tmp/snk-i28-handoff.json
```

This compiles HandoffProbe.swift beside unchanged SDK sources, with warnings as errors, and executes seven bounded ownership observations using existing NetworkOperation arbitration. [The report](../../docs/planning/I28_FILE_HANDOFF_2026-11-01.md) explains the negative ownership control, explicit cancellation gate, injected failure limitations and why no generic operation refactor is justified. This is a serialized single-operation protocol experiment, not a shipping concurrent file manager.
