# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M01 Execution and compilation model |
| Active design task | none (T0010 closed; T0011 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0010 Observable behavior and determinism |
| Decisions | D0001–D0054 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010, OQ-011, OQ-012 (OQ-004 decided) |
| Research notes | R0001–R0008 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution, §1.2.5 observable behavior and determinism, §1.2.6 resource exhaustion and implementation limits), notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed (property 7 added in T0010); observable behavior stated in prose in dynamic.md; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

Run **T0011 (M01): the runtime and the program lifecycle.** Decide the runtime's responsibilities (hooks for M07's
memory management and M10's scheduler, D0012's growable stacks, native functions); the forms of `main` and the exit
status (including Windows' wider range under Tier 3, D0046); the panic report's form, presenting D0050's kind,
message, and location, and its stream; the exhaustion report of D0053; output delivery on every exit path, which
D0048's choice 4 requires; and the guaranteed minimum depth and default stack cap
([OQ-012](open-questions.md#oq-012-what-is-the-guaranteed-minimum-depth-of-nested-calls)). Read
[roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model), D0012, D0014, D0042–D0044, D0046, D0048–D0053, and
spec §1.2.4–§1.2.6. Leave constant evaluation to T0012 and source-location naming to T0013.

## Handoff

- **Decided in T0010:**
  - Observable behavior is a trace of events (what the run sends and receives) plus one outcome: return with exit
    status, panic, resource exhaustion, or divergence; event order across streams is observable; `dbg`, timing,
    memory use, and backtraces are not (D0048).
  - Panics are precise; no engine, profile, or optimization changes observable behavior; no build setting removes a
    check (D0049).
  - A panic's kind, message, and source location are observable; backtraces are not; the location's form waits for
    T0013 and M02 (D0050).
  - The sequential language has no implementation-defined or unspecified behavior except resource exhaustion;
    platform differences arrive only as inputs; M10 owns concurrency's variation (D0051).
  - Floats are bit-identical everywhere: IEEE basic operations without contraction or flush-to-zero, canonical NaN
    observations, specified text conversion and math functions; the method is OQ-011, for M05 (D0052).
  - Resource exhaustion may happen at different points above a guaranteed minimum depth (OQ-012, for T0011); the
    trace is a prefix of the unlimited run's; exhaustion while compiling is reported, not a rejection (D0053). This
    adds claimed property 7 ("exhaustion truncates the trace") to D0023's list.
  - Structural implementation limits are exact rejection rules, set per chapter; sizes are unlimited (D0054).
- **Spec:** §1.2.5 and §1.2.6 added; the chapter's opening line and §1.2.4's note updated. Formal: dynamic.md gains an
  "Observable behavior" section; metatheory.md restates property 5 over traces and adds property 7. Glossary: 19 new
  terms. Vision: a new "What every run can rely on" table. Roadmap: "From T0010" notes in M01, M05, M07, M10, M14.
- **Research:** R0008 (C11, CompCert, Java, WebAssembly, Rust, Go, Python, GHC, CORE-MATH, Lean `Float`; a float pilot
  showing arm64 and x86-64 NaN bits differ, and identical libm results across Rust, OCaml, Zig, and C on macOS).
- **Constraints for T0011:** the panic report must present exactly D0050's observable parts, with any backtrace
  after it marked non-observable; every exit path delivers pending output before the outcome (D0048); the
  exhaustion report names the resource without a location and needs a reserve (D0053); OQ-012's value must be
  reachable by the tree-walker, which nests host calls, on all Tier 1–2 platforms.
- **Repairs made in T0010:** the T0009 task-log row's commit was filled in (9473358).
- No uncommitted design work is pending once T0010 is committed.

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
| T0010 | 2026-11-17 | M01 | Observable behavior and determinism: trace and outcome, precise panics, panic contents, determinism, floats, resource exhaustion, implementation limits | D0048–D0054 | OQ-011, OQ-012 (opened) | (pending) |
