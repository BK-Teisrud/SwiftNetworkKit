# Contributing and workflow

The project is in its planning stage. Do not begin implementation until F0 is approved and implementation is separately and explicitly authorized. Teisrud Development AS is the designated rights holder. The project is proprietary; see [LICENSE](LICENSE).

Bug reports and suggestions are welcome. External contributions that change repository content are accepted only after a written contribution agreement with Teisrud Development AS has been agreed. A pull request or sign-off does not automatically transfer rights. Do not submit external code contributions before this is resolved. GitHub's applicable terms continue to govern public activity on the service.

1. Find or create an issue with requirement references, scope, and acceptance criteria.
2. Move eligible work to Ready; specify an owner, milestone, priority, and dependencies.
3. Use a short-lived branch from main: docs/<issue>-<short-name>, chore/<issue>-<short-name>, and, later, feat/, fix/, test/, or refactor/.
4. Open a draft PR early. Keep one purpose per PR. Use Closes #number only when the entire issue is being completed.
5. Update relevant documentation, ADRs, requirements traceability, and the changelog. Record concrete verification and risks.
6. Resolve every review thread. Squash-merge with a descriptive title, such as docs: document platform decisions. Delete the branch after merging.

No direct pushes to main after bootstrap. No develop branch; create a release branch only for a documented maintenance need. There is no daily-activity requirement or automatic closure of old issues.

## Definition of Ready

The problem, scope and exclusions, requirement IDs, testable criteria, dependencies, and estimate are understood. No blocking architecture decision remains open. Security and platform implications have been assessed. Implementation also requires the separate authorization recorded in START-00 / #41.

## Definition of Done

Acceptance criteria are met, relevant checks are documented, the PR is merged, documentation/risks/ADRs are updated, and the issue is closed. Product work must also satisfy QUALITY.md. Planned tests never count as passed tests.

Do not include tokens, cookies, real customer data, private URLs, raw request/response dumps, or personal information in public issues or fixtures. Use synthetic examples.

## Language

Use English for all GitHub documentation, issues, PRs, comments, and project content. Owner–assistant conversations remain in Norwegian. See [LANGUAGE_POLICY.md](docs/governance/LANGUAGE_POLICY.md).
