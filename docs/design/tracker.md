# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M02 Lexical structure (tasks to be planned; M01 closed in T0013) |
| Active design task | none (T0013 closed; planning M02 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0013 Units, separate compilation, and reproducibility (with M01's exit review) |
| Decisions | D0001–D0077 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010, OQ-011, OQ-013, OQ-014 (location part decided), OQ-015, OQ-016 (OQ-004 and OQ-012 decided) |
| Research notes | R0001–R0011 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution, §1.2.5 observable behavior and determinism, §1.2.6 resource exhaustion and implementation limits, §1.2.7 program start and termination, §1.2.8 program phases and compile-time evaluation, §1.2.9 units, builds, and source names), notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed (property 7 added in T0010, extended to termination in T0011); observable behavior, compile-time evaluation, and locations stated in prose in dynamic.md; units noted in static.md; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

**Plan M02 (Lexical structure).** M01 is closed. Propose M02's tasks to the designer (sub-topics, their order, and
any exit criteria M02 adds to the common ones), let the designer confirm or change them, record the plan in
[roadmap.md, M02](roadmap.md#m02-lexical-structure) as a decision if it changes the plan, and then run the first
M02 task (T0014). M02's scope: encoding, identifiers, keywords, literals, comments, whitespace, and the EBNF dialect;
also what a column counts, how tabs count, and what ends a line, for locations
([D0077](decisions/D0077-location-text.md), OQ-014), and the keyword spellings of OQ-005. Read
[roadmap.md, M02 and I1](roadmap.md#m02-lexical-structure), D0015–D0020 (spec conventions), D0013, D0014, D0050,
D0054, D0076, D0077, spec §1.3.6 (grammar notation), the grammar file, and OQ-005, OQ-006, OQ-014. Closing M01 and
M02 starts I1 ([D0036](decisions/D0036-trailing-implementation-track.md)).

## Handoff

- **Decided in T0013:**
  - A program's meaning comes from source alone; compiled forms of units, stored constant values included, are caches
    that must give what compiling from source gives; no binary-only libraries (D0072).
  - A unit is one or more files that refer to each other freely; units form an acyclic graph, `R-unit-cycle`; the
    program is the root unit (it declares `main`) and every unit it depends on, the standard library's included
    (D0073). How units are written and named is provisional (OQ-016, M09).
  - A build is identified by its build inputs' contents, the implementation and release, the target, and the build
    settings; the host implementation and `qubecc` give byte-identical artifacts on any host, cross equal to native and
    incremental equal to clean; a requirement on our implementations, with only a note in the spec (D0074).
  - Every executable embeds a record of its build identity, readable by tools, never by programs (D0075).
  - Source names are `<unit>/<path in unit>` with `/`; used in observable behavior and stored locations; diagnostics
    may use the user's paths; until M09, a single file's unit is named after its stem and the standard library's unit
    is `std` (D0076).
  - Locations are `<source name>:<line>:<column>`, 1-based; what a column counts is M02's (D0077).
- **M01 exit review:** every criterion met, except "examples added", waived because M01 decided no syntax (see
  [roadmap.md, M01](roadmap.md#m01-execution-and-compilation-model)). M01 closed on 2026-11-17.
- **Spec:** new §1.2.9 (units, builds, and source names, rules 1–10, two notes, an example); §1.2.5 rule 4 and §1.2.7
  rule 5 point to it; the chapter's summary line. Formal: notes in static.md (units) and dynamic.md (locations).
  Glossary: 9 new terms, 1 updated. Vision: a new "How a program is built" table. Roadmap: M01 Done with its exit
  review, M02 Active, "From T0013" notes in M01, M02, M04, M09, M11, M14, M15, I1, I2, I3. OQ-016 opened; OQ-014's
  location part decided.
- **Research:** R0011 (Go builds in two directories differ unless `-trimpath`; Rust, Swift, Zig, and Go location
  forms; Go's reproducible toolchains and the end of binary-only packages, verified from go.dev; Swift SE-0274).
- **Risk to watch in I2:** byte-identical executables from every host, including the `macos-arm64` ad-hoc signature
  written by our own bundler (D0074).
- **Repairs made in T0013:** the T0012 task-log row's commit was filled in (21274eb).
- No uncommitted design work is pending once T0013 is committed.

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
| T0012 | 2026-11-17 | M01 | The compile-time/run-time boundary: phases, every constant once, cycles, generic parameters, constant values, what runs at compile time, compile-time panics, guaranteed steps and cap, `dbg` | D0063–D0071 | OQ-015 (opened) | 21274eb |
| T0013 | 2026-11-17 | M01 | Units, separate compilation, and reproducibility: source-only meaning, units and their graph, build identity and byte-identical artifacts, the build record, source names, location text; M01 exit review | D0072–D0077 | OQ-014 (location part decided), OQ-016 (opened) | (pending) |
