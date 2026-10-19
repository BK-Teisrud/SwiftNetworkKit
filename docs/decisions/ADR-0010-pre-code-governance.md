# ADR-0010: Preparation and GitHub hardening before implementation

Status: Accepted within the owner's request to complete preparations. Date: 2026-10-19.

## Decision

One project status field replaces status labels. Numbered subtasks have acceptance criteria and native dependencies. A separate START-00 gate preserves the need for explicit implementation authorization. Done does not automatically close an issue. The completed view filters on completed; rejected work uses Not Planned.

Main has no bypass. A separate creation rule restricts v* tags to admins; update/deletion have a rule without bypass. Published releases are immutable. Mandatory web commit sign-off is disabled because no DCO agreement was selected. The owner specifically answered, in translation, “Yes, carry out both changes,” regarding sign-off and the limited tag exception. This does not authorize tag creation or release publication.

## Rationale and limitations

Duplicate status tracking risked conflicting queues. Tasks with contracts and required test evidence provide an actionable sequence. No CI checks are required yet because no product exists; I06 introduces real checks after positive and negative verification. Do not require review from a nonexistent second maintainer or signed commits before signing is configured.

The owner confirms 2FA and current devices of every type, but no contact address. No address or minimum-OS test evidence is invented. Minimum-OS evidence is a release requirement; establish contact before offering external licensing/contribution processes. Add no purchases, upgrades, access grants, or paid services. Admins can still change rules; protection against the account owner cannot be guaranteed.

## Verification

See SETUP_STATUS.md, PROJECT_MANAGEMENT.md, WORK_QUEUE.md, TEST_ENVIRONMENTS.md, and PRE_CODE_READINESS.md. This decision introduces no code or workflows. ADR-0009's separate implementation-authorization requirement remains in force.
