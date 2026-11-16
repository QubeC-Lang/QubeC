# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0002 closed; T0003 is next) |
| Last closed task | T0002 Vision I |
| Decisions | D0001–D0007 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-004 |
| Research notes | R0001 |
| Spec status | Not started: conventions only ([spec README](../spec/README.md)) |
| Grammar status | Empty, provisional W3C-style EBNF |

## Next action

Run **T0003 (M00): Vision II.** Frame what "functional in style" commits QubeC to
([OQ-004](open-questions.md#oq-004-what-does-functional-in-style-commit-qubec-to)): a pure `func` / effectful `proc`
split (assumed by the dream snippet), effect tracking in types, or immutability and first-class functions without
tracked purity; immutability by default; and ask the designer for any further must-haves. Decide only the vision
level here; the mechanisms stay with M04 and M08.

## Handoff

- **Decided in T0002:**
  - domain: tooling-first, with the self-hosting yardstick as a tie-breaker only (D0002);
  - users: tool builders (primary), application developers, systems programmers (D0003);
  - values: layered (D0004). Default layer: Safety > Simplicity > Ergonomics > Predictability > Performance.
    Explicit layer: Safety > Performance > Predictability. Rigor is deliberately not ranked;
  - non-goals NG-1 to NG-11 (D0005);
  - inspirations: ML, Rust, Kotlin/Scala 3, and Go's concurrency, plus four anti-inspirations (D0006);
  - naming: intuitive names, where widely recognized short forms are fine and coinages are spelled out (D0007).
- **Dream snippet:** in [vision.md](vision.md), with a table of what each construct implies.
- **The designer's leanings,** visible in the snippet: `func`/`proc`, `;` terminators, braced `if`, `${…}` templates,
  Go-style `<-` channel operators, and the keyword `channel` (not `chan`).
- **Not done:**
  - No spec chapter yet: the introduction's scope section waits for T0004 (spec audience).
  - No `examples/` file yet: no syntax is decided.
- No uncommitted design work is pending once T0002 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | (pending) |
