# D0028: The mechanization starts in M03, as a Lean package in docs/spec/formal/lean/

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

When is the first Lean file of the mechanization ([D0024](D0024-mechanize-the-core.md), [D0025](D0025-lean-4.md))
written, and where does it live? The start also fixes when the **binder representation** is chosen: how the core
represents variables internally, for example by **de Bruijn indices** (a variable is the number of binders between
it and its own binder) or **locally nameless** terms (names for free variables, indices for bound ones). The choice is
invisible to users: scoping rules such as shadowing are surface rules, resolved by the paper elaboration
([D0022](D0022-typed-elaboration-into-core.md)) before the core sees any variable.

## Options considered

The location was the same in every option: `docs/spec/formal/lean/`, a Lake package (Lean's build tool) beside the
Markdown rules it governs ([D0026](D0026-lean-governs-core-rules.md)). The scenario is what exists at the end of each
early milestone:

```
            M03 Expressions        M04 Names           M05 Types
Option A:   (Lean since M00) ───── extended ────────── extended
Option B:   Lean starts: machine ─ extended ────────── typing, soundness
            determinism, tailcall
Option C:   paper only ─────────── paper only ──────── Lean starts; port M03–M04
```

### A. Now, seeded from the pilot

- **Easy:** conventions (layout, naming, the name check, style rules) are tested early.
- **Hard:** nothing normative exists to mechanize; the pilot's calculus would be largely rewritten in M03–M05.

### B. In M03, with the first formal rules

M03 decides expressions, evaluation order, control flow, and blocks, and writes the core's abstract-machine dynamics.
Determinism and the tail-call space bound ([D0023](D0023-claimed-meta-properties.md)) are untyped properties, so they
can be proved before M05 adds types. M04 adds environments and binder lemmas; M05 adds typing and soundness.

- **Easy:** each property is proved in the milestone that creates it; nothing is ported.
- **Hard:** M03's exit criteria include Lean work, which slows the first design milestones slightly.

### C. In M05, with the core typing rules

- **Easy:** the first Lean file already holds the typed core; soundness is stateable at once.
- **Hard:** M03's and M04's rules are ported later; the tail-call bound and the binder lemmas, where paper proofs most
  often go wrong, go unchecked for two milestones.

Recommendation at the time: **B**, which starts the mechanization exactly when the first core rules exist.

## Choice

**B.**
1. The mechanization is a Lake package at `docs/spec/formal/lean/`, with its Lean version pinned in a
   `lean-toolchain` file ([D0025](D0025-lean-4.md)).
2. It is created by M03's first task that writes formal rules. That task mechanizes the core's syntax and machine
   dynamics so far, states determinism and the tail-call space bound, and chooses the binder representation
   ([OQ-007](../open-questions.md#oq-007-how-does-the-mechanized-core-represent-binders)).
3. The name-correspondence check of [D0026](D0026-lean-governs-core-rules.md) is proposed as tooling in the same
   task.
4. Until then, `formal/*.md` stays paper-only, and no aspect can be promoted.

## Rationale

The binder representation is internal to the core, because names are resolved by elaboration, so it need not wait for
M04's scoping design. Starting with M03's dynamics means the properties that need no types are machine-checked in the
milestone that decides them, and nothing is written twice.

## Consequences

- **M03:** an exit criterion gains "the mechanization exists and covers M03's core rules; determinism and the
  tail-call bound are proved, or their gaps are recorded as open questions".
- **M04, M05:** extend the package (binder lemmas; typing, soundness, purity).
- **Repository layout** ([D0001](D0001-repository-layout.md)): `docs/spec/formal/lean/` is added under `formal/`.
- **OQ-007** (binder representation) is opened, with target M03.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md) (files and location)
- Examples / tour: none
