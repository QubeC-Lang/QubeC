# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M01 Execution and compilation model |
| Active design task | none (T0007 closed; T0009 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0007 Confirm the milestone plan; M00 exit review (M00 closed) |
| Decisions | D0001–D0041 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (OQ-004 decided) |
| Research notes | R0001–R0006 |
| Spec status | §1 Introduction written (Draft): scope, conformance, notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

Run **T0009 (M01): execution model and artifacts.** Decide interpreter, bytecode VM, and native code (which, and
when); what `qubec run` and `qubec build` produce ([D0013](decisions/D0013-easy-start.md)); whether bytecode is an
artifact users see, and its stability (the M01 part of
[OQ-009](open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)); the
first targets and platforms; and confirm or revisit D0030's bytecode VM (its revisit trigger). Read
[roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model) for the five-task plan, and D0029–D0035 for the
host constraints. Leave determinism and observable behavior to T0010.

## Handoff

- **Decided in T0007** (M00 is closed; its exit review is in [roadmap.md, M00](roadmap.md#m00-vision-and-principles)):
  - Implementation is a trailing track: it starts once M01 and M02 have closed, implements only closed design
    milestones, and design never waits for code (D0036).
  - Implementation milestones `I1`, `I2`, … with tasks in the shared T series; one Active task per track; the single
    next action is design's (D0037). How implementation tasks are run is decided by I1's opening task.
  - M16 is dropped, merged into I1–I3, each opening with its own design tasks; the post-v1.0 plan moves to M17;
    OQ-008 and OQ-009's format part now target I2 (D0038).
  - Four stages: I1 front end and core interpreter (M01–M05), I2 host complete with compiler and VM (M06–M09, M14),
    I3 `qubecc` and the fixpoint, I4 M10–M12 in both; common exit criteria P1–P6 (D0039).
  - Design milestones kept; M14 depends on M06–M09; M05 does not wait for M07; M08 is errors and effect mechanics;
    M15 depends on M09 and M14 (D0040).
  - Spec v1.0 only after I4; drafts may be tagged 0.x (D0041).
  - M01's tasks: T0009–T0013 (roadmap). Research: R0006.
- **M00 exit:** every criterion met except "examples are added", waived because M00 decided no syntax.
- **Constraints for T0009:** D0030 presumes a bytecode VM (revisit trigger); D0013 needs a one-step run mode; D0012
  needs growable stacks and constant-stack tail calls; D0006/OQ-001 need a runtime that allows lightweight tasks
  (M10); NG-3 rules out a no-runtime default.
- **Repairs made in T0007:** the T0006 task-log row's commit was filled in (7dd443e).
- No uncommitted design work is pending once T0007 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | 1014639 |
| T0003 | 2026-11-16 | M00 | Vision II: functional style (purity, bindings, collections, local mutation, recursion), must-haves | D0008–D0013 | OQ-004 (decided), OQ-005 (opened) | 762ce8a |
| T0008 | 2026-11-16 | M00 | Revisit: the spelling of explicit tail calls | D0014 | OQ-005 (`become` item decided) | 17dc68c |
| T0004 | 2026-11-16 | M00 | Spec audience, authority, rule style, diagnosis and rule IDs, scope, extensions, spelling | D0015–D0020 | OQ-006 (opened) | 2792d7e |
| T0005 | 2026-11-16 | M00 | Formalization: target, typed elaboration, claimed properties, mechanization, Lean 4, authority, executable reference, start | D0021–D0028 | OQ-007, OQ-008 (opened) | debf11e |
| T0006 | 2026-11-16 | M00 | Host implementation: role, parts, languages (Rust, OCaml, Zig), code style, toolchains and libraries | D0029–D0035 | OQ-009 (opened) | 7dd443e |
| T0007 | 2026-11-16 | M00 | Confirm the milestone plan: implementation track, I1–I4, M16 merged, Spec v1.0 gate; M01 tasks; M00 exit review | D0036–D0041 | OQ-008, OQ-009 (retargeted) | (pending) |
