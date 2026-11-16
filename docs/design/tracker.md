# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0005 closed; T0006 is next) |
| Last closed task | T0005 Formalization depth and proof assistant |
| Decisions | D0001–D0028 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008 (OQ-004 decided) |
| Research notes | R0001–R0004 |
| Spec status | §1 Introduction written (Draft): scope, conformance, notation and conventions (§1.3.3 now states the formal target, elaboration and core rules, and Lean authority) |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed; no rules yet; Lean package starts in M03 |

## Next action

Run **T0006 (M00): host language for the bootstrap implementation.** Decide which language (or languages) the first
QubeC implementation is written in, with a small AST and evaluator per candidate and cheap pilots where a toolchain
is installed. Weigh the self-hosting path (what the host implementation becomes once QubeC self-hosts), the REPL and
`qubec run` obligations of D0013, and how the host relates to the Lean reference evaluator and checker (D0027).

## Handoff

- **Decided in T0005** (M00's exit criterion "formalization depth and proof assistant decided, with samples shown"
  is met):
  - Formal target: the whole sequential language, both layers, including D0011's mutation analysis and the borrow
    rules. Concurrency and any memory model stay prose-governed. If M07's design is not syntactically provable, its
    chapter is capped at *partial* and D0021 is revisited (D0021).
  - Static semantics = elaboration rules over the surface (`Γ ⊢ e : τ ⇝ c`, carrying rule IDs) into an explicitly
    typed core; dynamics over the core only (D0022).
  - Claimed: core type soundness, elaboration soundness, purity with the frame property, tail-call space bound (so
    core dynamics are an abstract machine with an explicit stack), determinism, decidable checking. Referential
    transparency is not claimed (D0023).
  - Mechanized: the core and properties 1, 3, 4, 5. On paper: elaboration and properties 2, 6 (D0024).
  - Lean 4, pinned in `lean-toolchain` (D0025). Lean governs core rules; Markdown names the Lean counterpart, with a
    name check proposed as tooling (D0026). A verified fuel-indexed reference evaluator and a sound-and-complete
    reference checker that reports rule IDs (D0027). Lake package at `docs/spec/formal/lean/`, created by M03's
    first formal task (D0028).
  - New open questions: OQ-007 (binder representation, M03), OQ-008 (core interchange format, M16).
  - Research and pilot: R0004. The pilot (Lean 4.36.0 and Rocq 9.3.0, effect soundness with de Bruijn
    substitution, about 180 lines each) ran in a scratch directory outside the repository; it is not kept.
- **Constraints for T0006:**
  - D0025's consequences invite weighing Lean as a host candidate, since it is also a programming language and the
    reference evaluator is written in it. The host must still serve D0013 (direct `qubec run`, an early REPL) and
    the self-hosting yardstick (D0002).
  - D0022: any implementation elaborates surface into an explicitly typed core, and D0027 expects it to be able to
    emit that core (format open, OQ-008). The host's front end should be built around a typed core IR.
  - D0018: rejections report rule IDs; the host's diagnostics carry them from the start.
  - Show samples (a small AST and evaluator per candidate) and run cheap pilots for installed toolchains; record
    the findings as a research note.
- **Repairs made in T0005:** the T0004 task-log row's commit was filled in (2792d7e).
- No uncommitted design work is pending once T0005 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | 1014639 |
| T0003 | 2026-11-16 | M00 | Vision II: functional style (purity, bindings, collections, local mutation, recursion), must-haves | D0008–D0013 | OQ-004 (decided), OQ-005 (opened) | 762ce8a |
| T0008 | 2026-11-16 | M00 | Revisit: the spelling of explicit tail calls | D0014 | OQ-005 (`become` item decided) | 17dc68c |
| T0004 | 2026-11-16 | M00 | Spec audience, authority, rule style, diagnosis and rule IDs, scope, extensions, spelling | D0015–D0020 | OQ-006 (opened) | 2792d7e |
| T0005 | 2026-11-16 | M00 | Formalization: target, typed elaboration, claimed properties, mechanization, Lean 4, authority, executable reference, start | D0021–D0028 | OQ-007, OQ-008 (opened) | (pending) |
