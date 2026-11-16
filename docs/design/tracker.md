# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0001 closed; T0002 is next) |
| Last closed task | T0001 Repository setup and design workflow |
| Decisions | D0001 |
| Open questions | none |
| Spec status | Not started: conventions only ([spec README](../spec/README.md)) |
| Grammar status | Empty, provisional W3C-style EBNF |

## Next action

Run **T0002 (M00): Vision I.** Cover purpose and problem domain, target users, ranked design values (the designer
ranks or multi-selects 3 to 5), non-goals, inspirations and anti-inspirations, and a 10 to 30 line "dream snippet"
the designer writes. Record each as a D record and write `docs/design/vision.md`. Plan the rest of M00 in the
roadmap.

## Handoff

- T0001 created the repository layout ([D0001](decisions/D0001-repository-layout.md)), the workflow
  ([workflow.md](../agent/workflow.md)), the prompts, templates, this tracker, and the roadmap. Everything else is a
  skeleton.
- Nothing about the language itself is decided yet, beyond the project facts in workflow.md section 1 (name,
  `.qbc`, the initial idea).
- No uncommitted design work is pending.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | (pending) |
