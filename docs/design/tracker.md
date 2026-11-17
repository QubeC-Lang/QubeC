# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone (design) | M02 Lexical structure (tasks T0014–T0019 planned in T0014) |
| Active design task | none (T0014 closed; T0015 is next) |
| Active milestone (implementation) | none (I1 starts once M01 and M02 have closed, D0036) |
| Active implementation task | none |
| Last closed task | T0014 Grammar machinery (with M02's task plan) |
| Decisions | D0001–D0082 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006, OQ-007, OQ-008, OQ-009 (M01 part decided), OQ-010, OQ-011, OQ-013, OQ-014 (location part decided), OQ-015, OQ-016 (OQ-004 and OQ-012 decided) |
| Research notes | R0001–R0012 |
| Spec status | §1 Introduction written (Draft): scope, conformance (including §1.2.4 means of execution, §1.2.5 observable behavior and determinism, §1.2.6 resource exhaustion and implementation limits, §1.2.7 program start and termination, §1.2.8 program phases and compile-time evaluation, §1.2.9 units, builds, and source names), notation and conventions (including §1.3.6 grammar notation, no longer provisional, and §1.3.8 rejection by the grammar, `R-token-invalid` and `R-syntax`) |
| Grammar status | Notation and layers decided (W3C EBNF, D0078, D0079); no productions yet; checker specified in `tools/grammar/README.md` (D0080, D0081), stage 1 not built yet (due before T0015 closes) |
| Formal status | Skeleton: scope, structure, conventions, and claimed properties fixed (property 7 added in T0010, extended to termination in T0011); observable behavior, compile-time evaluation, and locations stated in prose in dynamic.md; units and grammar rejection noted in static.md; no rules yet; Lean package starts in M03 |

The tracker names at most one Active task per track (design and implementation,
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)). The next action below names the next design step.

## Next action

**Run T0015 (Source text and layout)** of [M02](roadmap.md#m02-lexical-structure): encoding (UTF-8, a byte order
mark), line endings, forbidden code points, whitespace and tabs, a `#!` first line for scripts
([D0013](decisions/D0013-easy-start.md)), what a column counts and how tabs count, for locations
([D0077](decisions/D0077-location-text.md), OQ-014), and how statements end (semicolons, newline rules, or both,
within the token/trivia model of [D0079](decisions/D0079-two-grammar-layers.md); M03 makes the exact rules
conflict-free). Write the first lexical productions (`TOKEN`, `TRIVIA`, whitespace, line ends) in the notation of
[D0078](decisions/D0078-w3c-ebnf-notation.md), each named lexical failure as a rule of the new lexical chapter §2 with
reject tests in `tests/conformance/` ([D0082](decisions/D0082-grammar-rejection-rules.md)), and check the grammar with
the checker's stage 1 once it exists ([D0080](decisions/D0080-staged-grammar-checker.md)). Read
[roadmap.md, M02](roadmap.md#m02-lexical-structure), D0005 (NG-1), D0013, D0051, D0054, D0076–D0082, spec §1.2.9 and
§1.3.6–§1.3.8, the grammar file, [tools/grammar/README.md](../../tools/grammar/README.md), and OQ-014.

## Handoff

- **Planned in T0014:** M02's tasks T0014–T0019 and two added exit criteria (the lexical grammar complete and checked
  by stages 1 and 2; the notation decided), recorded in [roadmap.md, M02](roadmap.md#m02-lexical-structure). No D
  record, since the milestone plan itself did not change.
- **Decided in T0014:**
  - The grammar is written in W3C EBNF (XML 1.0, Fifth Edition, §6), not provisional; no `wfc`/`vc` annotations;
    `A - B` parenthesized inside a sequence; `-` only in lexical productions, with a finite right operand; lexical
    recursion allowed; a decision comment on every production (D0078).
  - Two layers: `UPPER_SNAKE` lexical productions over characters, `UpperCamel` syntactic productions over tokens with
    trivia between any two; `TOKEN` and `TRIVIA` list the kinds; other lexical productions are helpers, never used by
    syntactic ones; a quoted string in a syntactic production is exactly one token; the start symbol is `SourceFile`
    (D0079).
  - A staged checker: stage 1 structure (defined now, built before T0015 closes), stage 2 a reference lexer through
    T0015–T0019 (longest match provisionally), stage 3 conflicts in M03 (D0080).
  - The checker is OCaml in `tools/grammar/`, standard distribution only, run as `ocaml tools/grammar/check.ml`;
    Menhir for stage 3 is M03's call; no code shared with either implementation; Unicode data from pinned UCD files
    (D0081).
  - Named lexical rules in §2, the fallback `R-token-invalid`, and `R-syntax`, with specific rules taking
    precedence; both general rules in spec §1.3.8 (D0082).
- **Spec:** §1.3.6 rewritten as numbered rules (provisional note removed); new §1.3.8 with `R-token-invalid` and
  `R-syntax`, a note, and an example; conventions item 7 updated. Grammar file: new header and two empty sections.
  Formal: a note in static.md. Glossary: 11 new terms. Vision: one row. Roadmap: M02 plan, exit criteria, and "From
  T0014" notes in M02, M03, I1, I3. Layout: `tools/` added to workflow.md §2 (D0001 planned it); `tools/README.md` and
  `tools/grammar/README.md` written. No new OQs.
- **Research:** R0012 (W3C, Go, ABNF, ISO 14977 via Wheeler, and Rust Reference notations; Menhir's features; a 78-line
  OCaml pilot of a W3C EBNF parser and matcher; Unicode table versions in Python 3.13.14 (15.1.0) and Rust 1.99.1
  (17)).
- **Not yet built:** stage 1 of the grammar checker (`tools/grammar/check.ml`); it is due before T0015 closes, and
  T0015 can start before it exists.
- **Repairs made in T0014:** the T0013 task-log row's commit was filled in (b8bd131).
- No uncommitted design work is pending once T0014 is committed.

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
| T0013 | 2026-11-17 | M01 | Units, separate compilation, and reproducibility: source-only meaning, units and their graph, build identity and byte-identical artifacts, the build record, source names, location text; M01 exit review | D0072–D0077 | OQ-014 (location part decided), OQ-016 (opened) | b8bd131 |
| T0014 | 2026-11-17 | M02 | Grammar machinery: M02's task plan; the notation; the two layers, tokens, trivia, and the start symbol; the staged checker; the checker's language and place; rule IDs for lexical and parse failures | D0078–D0082 | — | (pending) |
