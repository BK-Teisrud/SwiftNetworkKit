# Releases, versioning, and maintenance

Publish no release, tag, or package during setup. The repository is not installable yet.

After implementation authorization, use SemVer: 0.x for explicitly unstable prereleases; 1.0.0 only after the approved core scope and release gate are satisfied. From 1.0, patch means compatible fixes, minor means compatible additions, and major means breaking changes. Tag format: vMAJOR.MINOR.PATCH; prerelease example: v0.1.0-alpha.1.

## Release procedure

1. Open a dedicated release PR recording scope, verified commit, changelog, API/platform changes, known issues, and migration guidance.
2. Confirm actual passing CI, requirements traceability, rights compliance, and security review. Never dismiss findings merely to ship.
3. Merge to main. The maintainer creates a verifiable annotated/signed tag on the approved commit. Never move tags.
4. Prepare a release draft with explicit notes and SHA. Upload and verify any assets before publication. Mark prereleases accordingly. Immutable releases are enabled: publication locks the release tag and associated assets. Obtain separate actual release authorization before publication; no automatic publication now.
5. Verify that the future SPM product resolves/builds from the tag and documentation points to the correct version.

Correct faulty releases with a new patch/tag. Clearly identify affected releases; do not rewrite published history. Handle vulnerabilities under SECURITY.md and an advisory where appropriate.

## Compatibility

From 1.0, higher minimum OS versions, incompatible public API/Sendable/error changes, or removal of documented behavior are breaking. Document deprecations with replacements; planned removal occurs no earlier than the next major, except documented security measures. The latest stable minor of the current major receives ordinary fixes. Older majors require explicit support decisions; do not promise unlimited backports.
