# Project management

GitHub Issues define tasks and acceptance criteria. Milestones are delivery gates. Projects tracks work status; the roadmap and ADRs explain decisions. Maintainer @BK-Teisrud prioritizes work. [SwiftNetworkKit Roadmap](https://github.com/users/BK-Teisrud/projects/6) is private; repository issues are public.

## One work status

The project Status field is authoritative: Backlog → Ready → In Progress → In Review → Done. Blocked identifies a concrete obstacle; Not Planned denotes rejected/duplicate work. Old status labels were removed to prevent duplicate tracking. Issue open/closed state and closure reason record actual completion. Done requires completed and met acceptance criteria; dragging a card to Done does not close the issue.

Ready requires explicit implementation authorization where relevant, resolved blockers, a clear contract/test plan, and symbol checks for actual selected APIs. Dependencies guide planning; they do not enforce merges. Reopened issues return to Backlog for triage. After not-planned closure, manually select Not Planned because Item closed sets Done regardless of reason. Completed filters on reason:completed and excludes rejected work independently of project status.

Limit WIP to one active implementation task per developer and two review PRs. Pull only Ready work. P0 means incident/gate; P1 necessary core work; P2 later extensions; P3 research. Priority does not authorize code.

## Fields and views

Work views show Status, Priority (P0–P3), Scope (CORE/EXTENSION/RESEARCH/GOVERNANCE), Order, and built-in Title/Assignees/Milestone/Parent issue fields. Labels describe type/scope/priority; align Priority/Scope with labels during triage. There is no automatic synchronization. Do not invent dates.

| View | Purpose |
| --- | --- |
| Backlog | All open work, including epics and later scope |
| Work Board | Status columns including Done; Not Planned hidden |
| Roadmap | Phase overview without invented dated delivery bars |
| Phase 0 | Open F0 setup tasks |
| Decisions | Decision issues |
| Extensions and Research | Deferred scope |
| Work Queue | Open concrete tasks without epics/extensions/research; flat table sorted by ascending Order |
| Completed | Closed issues with reason:completed |

[WORK_QUEUE.md](WORK_QUEUE.md) defines the numbered order. Order 0 is the start gate; I01–I23 are 1–23; the release gate is 24. No product work is Ready before implementation authorization. Epics provide traceability, not oversized individual tasks.

## Built-in workflows

These are Projects features, not GitHub Actions workflows.

| Workflow | State / rationale |
| --- | --- |
| Auto-add to project | On; SwiftNetworkKit only, filter is:issue; imports new/updated root issues |
| Auto-add sub-issues | On; keeps subtasks in the project |
| Item added | On → Backlog; triage Priority/Scope/Order |
| Item closed | On → Done; correct Not Planned manually as described above |
| Item reopened | On → Backlog |
| Pull request merged | On → Done for the PR item; issues close only when actually completed |
| Auto-close issue | Off; moving status must not close work |
| Pull request linked to issue | Off; links must not bypass the start gate or start work |
| Auto-archive / review approved / changes requested | Off; retain history and avoid misleading solo-review transitions |

Issue #40 functionally verifies import, Done without closure, completed, and reopening. Results/limitations are in [setup status](../governance/SETUP_STATUS.md). PR/subissue rules are configured and read back; do not claim separate end-to-end tests without evidence.

## Maintenance

Weekly triage checks new issues, missing fields, blockers, WIP, and next Ready work. Verify actual evidence before phase transitions. Review bugs/risks after releases. No invented sprint dates or SLA. Track blocked work, lead time, and oldest WIP; commit counts do not measure quality. All GitHub content is English; conversations with the owner remain Norwegian under LANGUAGE_POLICY.md.
