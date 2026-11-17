# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0006 closed; T0007 is next) |
| Last closed task | T0006 Host language for the bootstrap implementation |
| Decisions | D0001–D0035 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (OQ-004 decided) |
| Research notes | R0001–R0005 |
| Spec status | §1 Introduction written (Draft): scope, conformance, notation and conventions (§1.3.3 now states the formal target, elaboration and core rules, and Lean authority) |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed; no rules yet; Lean package starts in M03 |

## Next action

Run **T0007 (M00): confirm or reorder the milestone plan, and review M00's exit criteria.** Revisit the milestone
order, dependencies, and scopes in [roadmap.md](roadmap.md) in light of D0002–D0035 (see the roadmap's "Notes for
T0007"), decide when implementation work starts relative to the design milestones, record any change as a decision,
plan M01's tasks, and report each M00 exit criterion as met or not met before closing M00.

## Handoff

- **Decided in T0006** (M00's exit criterion "the host language is decided, with samples shown and cheap pilots run"
  is met):
  - The host implementation is permanent and leads every feature; after self-hosting, every release needs both it and
    the self-hosted compiler (`qubecc`, a working name) to pass the conformance suite (D0029).
  - Three parts connected through the typed core (D0030): host interpreter in Rust (front end, tree-walking core
    interpreter, REPL, driver; every rejection; D0031), host compiler in OCaml (typed core → bytecode; D0032), host VM
    in Zig (VM, GC, stacks, natives, C ABI; D0033). D0030 presumes a bytecode VM: M01 revisits it if it decides
    otherwise.
  - Idiomatic code per part, nothing shared; `qubecc` designed fresh; conformance is the shared contract (D0034).
  - Pinned toolchains (Rust, OCaml, Zig, Lean); third-party libraries allowed when recorded and locked (D0035).
  - OQ-008 is now needed before the host compiler is built; OQ-009 (bytecode format, M01/M16) opened.
  - Research and pilots: R0005 (six languages on one checker/elaborator/evaluator spec; run in a scratch directory,
    not kept).
- **Constraints for T0007:**
  - The load is high: three permanent host codebases, later `qubecc`, and the Lean mechanization, with four pinned
    toolchains. Weigh when implementation starts (for example, after M01–M03, or interleaved with design), and
    whether M16's scope should move earlier.
  - M01 must account for D0030's bytecode VM; OQ-008 moves earlier than M16.
  - Earlier notes for T0007 in the roadmap (T0003's vision-level decisions, OQ-001's runtime constraints, D0018's
    checkable disciplines, D0028's M03 Lean start) still apply.
- **Repairs made in T0006:** the T0005 task-log row's commit was filled in (debf11e).
- No uncommitted design work is pending once T0006 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | 1014639 |
| T0003 | 2026-11-16 | M00 | Vision II: functional style (purity, bindings, collections, local mutation, recursion), must-haves | D0008–D0013 | OQ-004 (decided), OQ-005 (opened) | 762ce8a |
| T0008 | 2026-11-16 | M00 | Revisit: the spelling of explicit tail calls | D0014 | OQ-005 (`become` item decided) | 17dc68c |
| T0004 | 2026-11-16 | M00 | Spec audience, authority, rule style, diagnosis and rule IDs, scope, extensions, spelling | D0015–D0020 | OQ-006 (opened) | 2792d7e |
| T0005 | 2026-11-16 | M00 | Formalization: target, typed elaboration, claimed properties, mechanization, Lean 4, authority, executable reference, start | D0021–D0028 | OQ-007, OQ-008 (opened) | debf11e |
| T0006 | 2026-11-16 | M00 | Host implementation: role, parts, languages (Rust, OCaml, Zig), code style, toolchains and libraries | D0029–D0035 | OQ-009 (opened) | (pending) |
