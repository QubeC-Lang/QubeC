# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M01 Execution and compilation model |
| Active design task | none (T0012 closed; T0013 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0012 The compile-time/run-time boundary |
| Decisions | D0001–D0071 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010, OQ-011, OQ-013, OQ-014, OQ-015 (OQ-004 and OQ-012 decided) |
| Research notes | R0001–R0010 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution, §1.2.5 observable behavior and determinism, §1.2.6 resource exhaustion and implementation limits, §1.2.7 program start and termination, §1.2.8 program phases and compile-time evaluation), notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed (property 7 added in T0010, extended to termination in T0011); observable behavior and compile-time evaluation stated in prose in dynamic.md; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

Run **T0013 (M01): units, separate compilation, and reproducibility.** Decide what a compiled unit is (one file or
several, and whether units form an acyclic graph); what identifies a build and what its inputs are, leaving room for
embedded files ([D0068](decisions/D0068-only-pure-code-at-compile-time.md)); whether build output is reproducible and
how strictly (byte-identical artifacts or the same observable behavior); whether and how an artifact stores evaluated
constant values, including function values that refer to code in other units
([D0064](decisions/D0064-every-constant-once.md), [D0067](decisions/D0067-constant-values-without-mutable-state.md));
and how source locations are named in panics and diagnostics (OQ-014's location part). Read
[roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model), D0013, D0044, D0045, D0050, D0051, D0059,
D0063–D0068, D0070, and spec §1.2.4–§1.2.8. Leave module syntax, imports, visibility, and packages to M09, and
embedded files themselves to M11. Then run M01's exit review in the same task.

## Handoff

- **Decided in T0012:**
  - Three phases: checking, compile-time evaluation, the run; types do not mention constant values, with a guarded
    door for integer constants in types (M05, M06, M12) (D0063).
  - Every constant is evaluated exactly once, used or not, in an unobservable order (D0064); a read of a constant in
    progress is `R-const-cycle` (D0065); constants must not mention enclosing generic parameters, `R-const-generic`
    (D0066); a constant's value contains no mutable state, `R-const-mutable`, its check defined by M05 and M07 (D0067).
  - Only pure code, pure natives included, runs at compile time; a constant depends on the source alone, with a
    guarded door for embedded files as build inputs (M11) (D0068).
  - A panic in a constant is `R-const-panic` (D0069).
  - A step is one call or one loop iteration, counted per constant on the program as written; every implementation
    completes 10,000,000 steps per constant, or the constant's raise (syntax OQ-015); the host's cap is
    1,000,000,000, raisable by a build input; stopping is exhaustion, reported, not a rejection (D0070).
  - `dbg` output from compile-time evaluation should be shown during the build and is never replayed (D0071).
- **Spec:** new §1.2.8 (program phases and compile-time evaluation, rules 1–16); §1.2.6 rule 4 covers running out of
  steps; the chapter's summary line. Formal: notes in static.md and dynamic.md. Glossary: 12 new terms, 2 updated.
  Vision: a new "What happens before a run" table. Roadmap: "From T0012" notes in M01, M03–M07, M10–M12, M14, M15, I1,
  I3. Later notes in D0008, D0009, D0027, D0053. OQ-015 opened.
- **Research:** R0010 (Rust and Go constant behavior run on rustc 1.99.1 and Go 1.27.2; Rust's, Clang's, GCC's, and
  Zig's step limits; a Rust tree-walker at about 30 million calls per second in release and 7 million in debug).
- **Constraints for T0013:** an artifact may store evaluated constant values (D0064, D0067), so stored values must
  not change meaning; a build's inputs must leave room for embedded files (D0068); a constant's value depends on the
  source alone (D0068); determinism across implementations and platforms (D0051) and `run` as build-then-execute
  (D0045); a panic's location is observable (D0050, D0059), so the naming of source files is part of the trace.
- **Repairs made in T0012:** the T0011 task-log row's commit was filled in (561bc88).
- No uncommitted design work is pending once T0012 is committed.

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
| T0007 | 2026-11-16 | M00 | Confirm the milestone plan: implementation track, I1–I4, M16 merged, Spec v1.0 gate; M01 tasks; M00 exit review | D0036–D0041 | OQ-008, OQ-009 (retargeted) | cb50dd2 |
| T0009 | 2026-11-17 | M01 | Execution model and artifacts: engines, native code timing, build artifacts, `run`, platforms and tiers, platform parity | D0042–D0047 | OQ-009 (M01 part decided), OQ-010 (opened) | 9473358 |
| T0010 | 2026-11-17 | M01 | Observable behavior and determinism: trace and outcome, precise panics, panic contents, determinism, floats, resource exhaustion, implementation limits | D0048–D0054 | OQ-011, OQ-012 (opened) | 003628f |
| T0011 | 2026-11-17 | M01 | The runtime and the program lifecycle: runtime contract and runtimes, natives, forms of `main`, exit statuses, the report line, termination by the environment, failed standard output, guaranteed depth and stack cap | D0055–D0062 | OQ-012 (decided), OQ-013, OQ-014 (opened) | 561bc88 |
| T0012 | 2026-11-17 | M01 | The compile-time/run-time boundary: phases, every constant once, cycles, generic parameters, constant values, what runs at compile time, compile-time panics, guaranteed steps and cap, `dbg` | D0063–D0071 | OQ-015 (opened) | (pending) |
