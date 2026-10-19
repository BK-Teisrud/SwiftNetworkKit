# Governance

Rights holder: Teisrud Development AS, as selected by the project owner in ADR-0002. GitHub account owner and maintainer: @BK-Teisrud. Third-party use is governed by LICENSE and any separate written permission from the company. The owner decides scope, priorities, rights, platform support, and releases. Contributors propose changes through issues and pull requests.

## Decisions

Record lasting decisions in ADRs with status Proposed, Accepted, Superseded, or Rejected. Architecture, public APIs, storage, authentication, new modules, tool dependencies, and security exceptions require a documented decision. Roadmap changes require updated milestones, backlog, risks, and rationale.

## Access and review

Apply least privilege. This setup adds no collaborators, deploy keys, apps, webhooks, or secrets. The owner should use 2FA/passkeys and recovery codes. The owner has confirmed that 2FA is enabled; this is an attestation, not an independent account audit.

Solo profile: every change after bootstrap goes through a PR. No external approval is required because authors cannot approve their own PRs. CODEOWNERS identifies responsibility but does not itself enforce review. Security-relevant changes require an explicit risk assessment and documented self-review.

Enable the team profile only when another qualified person has write access: require at least one approval, Code Owner review, dismissal of stale approvals, and approval of the latest push by someone other than its author. No undocumented bypasses.

For urgent incidents, open a private security report, contain the impact, and document actions. Main has no configured bypass. Any emergency rule changes must be justified, narrowly scoped, and reviewed by the next business day; ordinary fixes follow the PR process. The account or organization owner can still change the rules themselves; repository configuration cannot remove that authority.

## Language

English is the language of repository documentation and GitHub content; Norwegian remains the language of owner–assistant conversations. The [language policy](docs/governance/LANGUAGE_POLICY.md) governs future updates.
