# ADR-0011: English repository content and Norwegian collaboration

Date: 2026-10-19. Status: Accepted by explicit owner request.

## Context and decision

The owner asked to translate all documentation and GitHub configuration into English while retaining Norwegian for conversations with the assistant.

Use clear, consistent English for repository documentation, templates, configuration descriptions, issues, PR titles and descriptions, project fields/options/views, milestones, labels, and future GitHub comments. Owner–assistant conversations remain in Norwegian. This supersedes ADR-0001's original documentation-language choice.

## Preservation and scope

Preserve technical identifiers, legal entity names, URLs, issue/PR numbers, decisions, dependencies, acceptance states, and security settings. Identify translated owner statements as translations; the original approvals remain in conversation and Git history. Existing commit messages and historical Git objects are not rewritten. Original source-document filenames remain provenance identifiers rather than English display text.

This is a language change, not a scope, rights, implementation, release, access, or cost authorization. START-00 / #41 remains open; no code or workflows are created.

## Verification

Review every current document and configuration file, translate all editable repository issue/PR content and project settings, and read the changes back. Check JSON/YAML, links, configuration references, and the absence of product code. Record practical boundaries in [LANGUAGE_POLICY.md](../governance/LANGUAGE_POLICY.md).
