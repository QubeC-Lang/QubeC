# D0024: The core is mechanized; the elaboration and inference proofs are on paper

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

Are the proofs of the claimed meta-properties ([D0023](D0023-claimed-meta-properties.md)) machine-checked, and how
much of the formal target? To **mechanize** is to write the syntax, the rules, and the proofs in a **proof
assistant**, a type checker for proofs: rules become inductive definitions, and a theorem is accepted only when
every case is really handled. The cost is upkeep: a changed rule breaks proofs, which must then be repaired. D0016
already requires a mechanized proof for promotion if we mechanize.

## Options considered

The scenario for every option is the defect used in [D0016](D0016-authority-per-section.md): the application rule
forgets the called function's own effect, so a function calling a procedure through a closure types as pure.

```
proc read_count() -> Int { … }
func f() -> Int = (|| read_count())();
// buggy T-App:  Γ ⊢ f : a →φ b ! φ₁   Γ ⊢ x : a ! φ₂   ⟹   Γ ⊢ f(x) : b ! φ₁ ⊔ φ₂
// correct:                                             ⟹   Γ ⊢ f(x) : b ! φ₁ ⊔ φ₂ ⊔ φ
```

A pilot ([R0004](../research/R0004-formalization-prior-art-and-pilots.md)) proved effect soundness for a small
calculus of this kind, with de Bruijn binders and subsumption, in Lean 4 and in Rocq; with the buggy rule, both
rejected the proof.

### A. Paper only

Proof sketches written by hand in `metatheory.md`.

- **Easy:** cheapest; readable by everyone; no toolchain.
- **Hard:** the defect survives unless a reviewer checks the application case carefully; six claimed properties over
  many milestones are too much to trust to sketches.
- **Prior art (recalled):** the Definition of Standard ML; Featherweight Go; most research papers.

### B. Mechanize the core; elaboration and the algorithm on paper

Mechanized: the explicitly typed core (syntax, typing, abstract-machine dynamics) and the core properties (type
soundness, purity with the frame property, determinism, the tail-call space bound). On paper: the elaboration rules,
elaboration soundness, and the soundness and completeness of the inference algorithm.

- **Easy:** the proved part is where features interact (generics, purity, mutation, borrows), and it is small and
  stable; surface conveniences touch no mechanized proof.
- **Hard:** steady upkeep each milestone and learning the tool; binders are the classic time sink; two surface
  theorems stay paper-strength, with conformance tests catching most elaboration bugs.
- **Prior art (recalled):** RustBelt mechanizes a core calculus, not surface Rust; many research languages mechanize
  their core only.

### C. Mechanize everything in the target

Option B, plus the elaboration rules, elaboration soundness, and the inference algorithm's soundness and
completeness.

- **Easy:** every claim is machine-checked; the mechanized inference can serve as a verified surface type checker.
- **Hard:** roughly twice B's upkeep, since every change to surface syntax touches proofs.
- **Prior art:** CakeML's type inferencer, verified sound and complete in HOL4 (verified, R0004), part of a
  multi-year effort.

### D. Decide later

Paper now; the question is reopened at M13.

- **Easy:** no cost now.
- **Hard:** a large port of rules not written with mechanization in mind; nothing can be promoted before M13.
- **Prior art (recalled):** Standard ML's Definition came first, and a partial mechanization years later.

| | A Paper | B Core | C All | D Later |
| --- | --- | --- | --- | --- |
| Catches the defect | if reviewed | yes, at once | yes, at once | if reviewed |
| Machine-checked claims | none | 4 of 6 | 6 of 6 | none until M13 |
| Upkeep per milestone | low | medium | high | low, then a large port |
| Surface changes touch proofs | — | no | yes | — |

Recommendation at the time: **B**, because the machine catches exactly the class of defect we fear, on the part of
the semantics that stays stable.

## Choice

**B.**
1. **Mechanized:** the core's syntax, its typing rules, its abstract-machine dynamics, and proofs of D0023's
   properties 1 (core type soundness), 3 (purity with the frame property), 4 (tail-call space bound), and 5
   (determinism).
2. **On paper:** the elaboration rules ([D0022](D0022-typed-elaboration-into-core.md)), with proof sketches in
   `metatheory.md` of D0023's properties 2 (elaboration soundness) and 6 (decidable checking).
3. **Continuous upkeep:** each milestone that adds or changes core rules updates the mechanization and repairs its
   proofs before it exits, or records each remaining gap as an open question.
4. **Promotion** ([D0016](D0016-authority-per-section.md), item 4) of an aspect requires, for the core properties
   that cover it, the mechanized proofs, and for its elaboration rules, the paper sketches.

## Rationale

Feature interactions meet in the core, and that is where a wrong rule silently becomes a soundness hole; the pilot
showed the proof assistant rejecting exactly such a rule. The elaboration is larger and changes with every syntax
decision, its defects are mostly syntactic, and conformance tests and the reference checker
([D0027](D0027-executable-reference.md)) catch many of them, so mechanizing it would roughly double the upkeep for
less benefit.

## Consequences

- **M03–M09:** each milestone's exit includes updating the mechanization for its core rules.
- **M13** finishes the remaining proofs rather than starting mechanization.
- **The two surface theorems** remain paper-strength; this is the main gap in the guarantee, and a later decision may
  close it.
- The proof assistant is chosen in [D0025](D0025-lean-4.md), authority between the two forms in
  [D0026](D0026-lean-governs-core-rules.md), and the start in [D0028](D0028-mechanization-starts-in-m03.md).

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority) (promotion requirements)
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md); [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: none
