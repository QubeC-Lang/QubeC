# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M01 Execution and compilation model |
| Active design task | none (T0011 closed; T0012 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0011 The runtime and the program lifecycle |
| Decisions | D0001–D0062 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010, OQ-011, OQ-013, OQ-014 (OQ-004 and OQ-012 decided) |
| Research notes | R0001–R0009 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution, §1.2.5 observable behavior and determinism, §1.2.6 resource exhaustion and implementation limits, §1.2.7 program start and termination), notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed (property 7 added in T0010, extended to termination in T0011); observable behavior stated in prose in dynamic.md; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

Run **T0012 (M01): the compile-time/run-time boundary.** Decide the program's phases (checking, compile-time
evaluation, running); which constants are evaluated, when, and how often; what may run at compile time and how `func`
purity ([D0008](decisions/D0008-purity.md)) relates to it, including whether any native may run there
([D0056](decisions/D0056-thin-natives.md)); what a panic during compile-time evaluation means (a rejection, a
report, or something else), next to D0053's rule that exhaustion while compiling is reported, not a rejection; how
compile-time evaluation is bounded; and what `dbg` does at compile time. Read
[roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model), D0008, D0011, D0013, D0027, D0043, D0045,
D0048–D0055, D0059, and spec §1.2.4–§1.2.7. Leave macros and reflection to M11, and units, separate compilation, and
source-location naming to T0013.

## Handoff

- **Decided in T0011:**
  - One written runtime contract (memory, stacks with reserves, natives, the outcome and its report, output delivery,
    later the scheduler and FFI); two independent host runtimes, Rust and Zig; post-v1.0 native code links a runtime
    written in QubeC, which binds M07 and M12 (D0055).
  - Natives are thin (the OS boundary and runtime internals) and declared in the standard library's source; the
    library's QubeC source is normative; only the standard library declares natives (D0056).
  - `main` is `proc main()` or `proc main() -> Result[Unit, E]` (the second provisional, OQ-013); arguments come from
    library procedures (D0057).
  - Exit statuses: 0, 1 (an error returned from `main`), `exit(n)` for 0–255 everywhere, 101 a panic, 102 resource
    exhaustion; pending output is delivered first (D0058).
  - One specified report line on standard error, then an optional backtrace after a delimiter, not observable; the
    exact text is OQ-014 (D0059).
  - A fifth outcome, terminated by the environment, abrupt by default, extending D0048 (D0060); a closed reader of
    standard output or error ends the run that way, and other failed writes to them panic (D0061).
  - The guaranteed depth is 100,000 nested calls of frames holding at most 256 values; a raisable stack cap, 1 GiB
    in the host (D0062), settling OQ-012.
- **Spec:** §1.2.5's outcome list gains termination by the environment; §1.2.6 rule 1 states the depth; new §1.2.7
  (program start and termination). Formal: dynamic.md and metatheory.md property 7 cover termination. Glossary: 11 new
  terms, 4 updated. Vision: a new "How a run starts and ends" table, and the combined sample uses `main`'s result
  form. Roadmap: "From T0011" notes in M01, M03–M10, M12, M14, M15, M17, I1, I2. Later notes in D0012, D0048, D0053.
- **Research:** R0009 (exit statuses of Rust, Go, OCaml, Zig; broken-pipe behavior of Rust, Go, OCaml, Python; a
  Rust tree-walker's stack use per call, 768 bytes in release and 7,584 in debug; Go's 1 GB goroutine stack cap).
- **Constraints for T0012:** compile-time evaluation runs inside the compiler and is not bound by the native-compatible
  rule (D0043); it must give the same results as running (D0049, D0051); exhaustion while compiling is reported, not
  a rejection (D0053); `dbg` output is never observable (D0008); thin natives are almost all procedures, so pure
  constants need few or none (D0056).
- **Repairs made in T0011:** the T0010 task-log row's commit was filled in (003628f).
- No uncommitted design work is pending once T0011 is committed.

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
| T0011 | 2026-11-17 | M01 | The runtime and the program lifecycle: runtime contract and runtimes, natives, forms of `main`, exit statuses, the report line, termination by the environment, failed standard output, guaranteed depth and stack cap | D0055–D0062 | OQ-012 (decided), OQ-013, OQ-014 (opened) | (pending) |
