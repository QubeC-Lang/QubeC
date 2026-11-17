# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M01 Execution and compilation model |
| Active design task | none (T0009 closed; T0010 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0009 Execution model and artifacts |
| Decisions | D0001–D0047 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010 (OQ-004 decided) |
| Research notes | R0001–R0007 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution), notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

Run **T0010 (M01): observable behavior and determinism.** Decide what is observable (output, exit status, panics and
their reports); what may differ between implementations, engines, and platforms (for example floats, iteration
order, resource limits); implementation limits; and the conformance additions to spec §1.2, next to §1.2.4. The
definition must be precise enough to test [D0045](decisions/D0045-run-is-a-shortcut.md)'s equivalence of `run` and
build-then-execute, across engines ([D0042](decisions/D0042-tree-walker-and-bytecode-vm.md)) and across the Tier 1
and Tier 2 platforms ([D0046](decisions/D0046-first-platforms-and-tiers.md)). Read
[roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model), D0042–D0047, D0023 (determinism is a claimed
theorem), and spec §1.2. Leave the runtime's responsibilities, `main`, and the panic report's form to T0011.

## Handoff

- **Decided in T0009:**
  - Engines: a tree-walking interpreter and a bytecode VM; no JIT. D0030's revisit trigger does not fire (D0042).
  - Native code after Spec v1.0, planned in M17; the native-compatible rule binds every milestone now: no feature may
    need a VM at run time. The route (C via `zig cc` preferred) is OQ-010 (D0043).
  - A build produces a self-contained executable (VM + embedded bytecode); bytecode can be emitted, loads only in the
    release that wrote it, and stabilizing it needs a new decision. Artifacts and commands are not language; names
    and flags wait for M15. OQ-009's M01 part is decided; its format stays with I2 (D0044).
  - `run` has the same observable behavior as build-then-execute; the engine is each implementation's choice (D0045).
  - Platforms in three tiers: Tier 1 `linux-x86_64`, `macos-arm64`; Tier 2 `linux-arm64`, `linux-riscv64` (suite
    under QEMU); Windows Tier 3 until a decision promotes it (D0046).
  - Platforms fall under D0029's host-leads rule (cross-building counts); back ends do not (D0047).
- **Spec:** §1.2.4 "Means of execution" added. Glossary: 13 new terms; "Bytecode" updated.
- **Research:** R0007 (Rust tiers, OCaml RISC-V, HiPE, Zig cross-compiling, the macOS code-signing check).
- **Constraints for T0010:** D0045 rests on T0010's definition of "observable"; D0023 claims determinism of the core
  dynamics; D0046 puts two OSes and three architectures in Tiers 1–2 (case-insensitive APFS on macOS); D0012 leaves the
  stack cap and guaranteed depth to M01 (T0010 or T0011).
- **Repairs made in T0009:** the T0007 task-log row's commit was filled in (cb50dd2).
- No uncommitted design work is pending once T0009 is committed.

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
| T0009 | 2026-11-17 | M01 | Execution model and artifacts: engines, native code timing, build artifacts, `run`, platforms and tiers, platform parity | D0042–D0047 | OQ-009 (M01 part decided), OQ-010 (opened) | (pending) |
