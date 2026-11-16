# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0003 closed; T0004 is next) |
| Last closed task | T0003 Vision II |
| Decisions | D0001–D0013 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005 (OQ-004 decided) |
| Research notes | R0001, R0002 |
| Spec status | Not started: conventions only ([spec README](../spec/README.md)) |
| Grammar status | Empty, provisional W3C-style EBNF |

## Next action

Run **T0004 (M00): spec audience, authority, and formality level.** Decide:
- who the specification is written for (programmers, implementers, or both);
- whether prose or formal rules govern when they disagree, and per section or globally;
- the style of rules;
- how violations are reported (for example, whether every rejection rule has a stable ID).

Then write the introduction's scope section (§1), which is waiting on this.

## Handoff

- **Decided in T0003 (vision level):**
  - Purity is tracked (D0008). A `func` (expression body) is pure; a `proc` (block body) may have effects.
    `dbg` is exempt, and purity parameters are inferred with an elision rule.
  - Bindings are immutable by default (D0009): `let`, a local `let mut`, top-level `const` only, and no global
    variables.
  - The default `List`, `Map`, and `Set` are **mutable** (D0010); immutable collections are in the library, named
    provisionally `ImmutableMap`, etc. This went against the agent's recommendation, which was persistent by
    default.
  - A `func` may mutate values it created if no mutation is observable (D0011); M07 provides the check.
  - Tail calls are marked and checked, and stacks are growable (D0012).
  - Easy start is a must-have (D0013): `qubec run file.qbc` and a REPL. The designer declined to make diagnostics,
    compile speed, or early C interop obligations.
- **OQ-004** is decided. **OQ-005** (new) asks whether the placeholder spellings `mut`, `become`, and `dbg` pass
  D0007. The designer had to ask what `become` means, so treat its spelling as genuinely open.
- **Settled now, refined later:** several T0003 decisions are normally owned by later milestones (M01, M03, M04,
  M08). Those milestones now refine them rather than decide them. The roadmap notes this for T0007.
- **Dream snippet:** in [vision.md](vision.md). It now uses `ImmutableMap`, and a combined word-count sample was
  added.
- No uncommitted design work is pending once T0003 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | 1014639 |
| T0003 | 2026-11-16 | M00 | Vision II: functional style (purity, bindings, collections, local mutation, recursion), must-haves | D0008–D0013 | OQ-004 (decided), OQ-005 (opened) | (pending) |
