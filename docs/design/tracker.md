# Design Tracker

This is the only authority on design progress. A fresh session reads this file first (after `CLAUDE.md`) and
follows the next action. Agent-oriented: "the designer" makes every decision; "the agent" proposes and records.

## Status

| Field | Value |
| --- | --- |
| Active milestone | M00 Vision and principles |
| Active task | none (T0004 closed; T0005 is next) |
| Last closed task | T0004 Spec audience, authority, and formality level |
| Decisions | D0001–D0020 |
| Open questions | OQ-001, OQ-002, OQ-003, OQ-005, OQ-006 (OQ-004 decided) |
| Research notes | R0001–R0003 |
| Spec status | §1 Introduction written (Draft): scope, conformance, notation and conventions |
| Grammar status | Empty, provisional W3C-style EBNF |

## Next action

Run **T0005 (M00): formalization depth and proof assistant.** Decide:
- how far the formal models go (core calculus only, the whole sequential language, concurrency and memory too);
- whether to mechanize, and in which proof assistant (such as Rocq, Lean 4, Agda, or Isabelle), with a sample per
  candidate: one small typing rule and one lemma about it;
- what the formal rules are written over (the surface language, or an elaborated core), and how the depth chosen
  bounds which spec aspects can be promoted under D0016.

## Handoff

- **Decided in T0004** (the spec conventions; M00's exit criterion "spec conventions fixed" is met):
  - One spec for programmers and implementers. It covers the language plus the **core library**, meaning the items
    a language rule depends on; M14 draws that list (D0015). The rest of the stdlib and the `qubec` tool are
    outside the spec.
  - Authority is per chapter. Each status line carries `Formal: static …, dynamic …` (complete, partial, or none).
    Formal rules govern only where an aspect is complete, and promotion is a recorded decision with a checklist:
    every rule formalized, failing premises tagged with rule IDs, and a proof sketch or mechanized proof (D0016).
  - Static rules are declarative; dynamic behavior is numbered steps where order is observable (D0017).
  - Every violation is diagnosed, with no "no diagnostic required". Every rejection rule has a stable ID
    (`R-` plus kebab words, subject first, one flat namespace), and a rejecting implementation reports at least one
    (D0018). Reject tests use `expect: reject <id>`.
  - Extensions apply only with an in-source opt-in, whose syntax is **OQ-006** (new; M09 or M11) (D0019).
    `R-extension-unknown` is the first published rule ID.
  - US English everywhere (D0020). The repo was swept: behavior, labeled, color(ing), uncolored, license.
- **Constraints for T0005:**
  - D0016 doesn't force any depth; T0005's depth only bounds what can ever be promoted.
  - If T0005 mechanizes, promotion needs the mechanized proof (D0016, item 4).
  - D0018 means every rule must be decidable, which suits a formal checker.
  - The designer asked for memory-level detail on runtime topics (T0008). For proof assistants, show real snippets
    and run cheap pilots if a toolchain is available.
- **Repairs made in T0004:** the decision and research indexes had been truncated by earlier commits (rows
  D0001–D0013 and R0001 were missing). Both were restored. T0008's commit is 17dc68c.
- No uncommitted design work is pending once T0004 is committed.

## Task log

| ID | Date | Milestone | Sub-topic | Decisions | OQs | Commit |
| --- | --- | --- | --- | --- | --- | --- |
| T0001 | 2026-11-15 | M00 | Repository setup and design workflow | D0001 | — | 76b0a8f |
| T0002 | 2026-11-16 | M00 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | D0002–D0007 | OQ-001–OQ-004 (opened) | 1014639 |
| T0003 | 2026-11-16 | M00 | Vision II: functional style (purity, bindings, collections, local mutation, recursion), must-haves | D0008–D0013 | OQ-004 (decided), OQ-005 (opened) | 762ce8a |
| T0008 | 2026-11-16 | M00 | Revisit: the spelling of explicit tail calls | D0014 | OQ-005 (`become` item decided) | 17dc68c |
| T0004 | 2026-11-16 | M00 | Spec audience, authority, rule style, diagnosis and rule IDs, scope, extensions, spelling | D0015–D0020 | OQ-006 (opened) | (pending) |
