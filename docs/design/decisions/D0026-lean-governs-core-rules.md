# D0026: For core rules, the Lean definition governs; the Markdown rule mirrors it

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

With the core mechanized ([D0024](D0024-mechanize-the-core.md)) in Lean 4 ([D0025](D0025-lean-4.md)), every core
rule exists twice: as an inference rule in `formal/static.md` or `formal/dynamic.md`, and as a Lean definition. Where
an aspect is formally complete, formal rules govern ([D0016](D0016-authority-per-section.md)); which of the two
formal texts is that rule when they disagree?

## Options considered

The scenario: a later milestone adds a third effect and updates the application rule in Lean, but not in Markdown.

```
formal/static.md (stale):    Γ ⊢ f(x) : b ! φ₁ ⊔ φ₂ ⊔ φ
Lean (updated):              | app : … → HasType Γ (.app f x) b (φ₁ ⊔ φ₂ ⊔ φ ⊔ panicOf f)
```

### A. Lean governs; the Markdown is a checked mirror

Each Markdown core rule names its Lean counterpart; a tool checks that every rule name exists on both sides, and the
content is checked by review. Elaboration rules exist only in Markdown, which governs them.

- **Easy:** the proved object is the definition, so the theorems are about QubeC.
- **Hard:** readers of a stale Markdown rule are misled until it is fixed; the name check does not catch wrong
  content.
- **Prior art (recalled):** CakeML, whose semantics is its HOL4 definition.

### B. The Markdown governs; Lean is a model

- **Easy:** one readable source of truth.
- **Hard:** a proof counts only if someone checks by hand that the model is faithful, which reopens the gap
  mechanization was meant to close.
- **Prior art (recalled):** Standard ML's paper Definition and its later mechanized model of an internal language.

### C. Lean governs; the formal pages are generated from it

The core rules are rendered from the Lean source, for example with Verso, the documentation system used for Lean's
reference manual (verified, [R0004](../research/R0004-formalization-prior-art-and-pilots.md)), or with a tool of our
own.

- **Easy:** no drift, by construction.
- **Hard:** the pages show Lean syntax unless we maintain a pretty-printer to inference-rule notation; a second
  documentation toolchain enters a Markdown specification.
- **Prior art:** WebAssembly's SpecTec generates its specification's formal rules, prose, and an interpreter from one
  source (verified, R0004).

Recommendation at the time: **A**, since only it keeps the proved object and the definition the same without a new
toolchain; C may be revisited once the core is large enough to make the mirror costly.

## Choice

**A.**
1. For a **core rule**, the Lean definition is the formal rule. Its rendering in `formal/*.md` names its Lean
   counterpart, as in *T-App [Lean: `Qubec.Core.HasType.app`]*, and must match it. A mismatch is a defect in the
   Markdown.
2. For an **elaboration rule**, the Markdown rule is the formal rule; it has no Lean counterpart
   ([D0024](D0024-mechanize-the-core.md)).
3. A check that every core rule name exists on both sides is proposed as repository tooling, to be added when the
   mechanization starts.
4. Combined with D0016: in a formally complete aspect, Lean governs its core rules, the Markdown governs its
   elaboration rules, and the specification's prose explains both.

## Rationale

The reason to mechanize is that the proved rules are the rules of QubeC. Letting the Markdown govern would make the
proofs about a model again. A stale mirror is a documentation defect, not a soundness gap, and the name check catches
the commonest drift: a rule added or renamed on one side only.

## Consequences

- **formal/static.md and dynamic.md** state, for each core rule, its Lean name.
- **Fixes** to a governing Lean rule are mirrored in the Markdown in the same change.
- **Repository tooling:** a name-correspondence check, added when [D0028](D0028-mechanization-starts-in-m03.md)'s
  first task creates the Lean package.

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority)
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md) (conventions and authority)
- Examples / tour: none
