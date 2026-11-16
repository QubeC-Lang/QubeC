# Formal Rules: Notation

Status: skeleton. No rules are written yet; the first come in M03. The scope, structure, and conventions below are
decided ([D0021](../../design/decisions/D0021-formal-target-sequential-language.md)–[D0028](../../design/decisions/D0028-mechanization-starts-in-m03.md)).

## Scope

The formal rules cover the **whole sequential language**, in both the default and the explicit layer. Concurrency
(tasks, channels, race freedom) and any low-level memory model are outside the formal target, and their chapters
stay prose-governed ([D0021](../../design/decisions/D0021-formal-target-sequential-language.md)). If M07's design for
local mutation or borrowed references cannot be proved sound by syntactic methods, the affected chapter is capped at
*partial*, and D0021 is revisited.

## Structure: elaboration and core

The formal semantics has two layers ([D0022](../../design/decisions/D0022-typed-elaboration-into-core.md)):

```
surface program ──elaboration rules (static semantics, rule IDs)──▶ core term ──core rules──▶ behavior
                   Γ ⊢ e : τ ⇝ c                                    explicitly typed   typing + abstract machine
```

- **Elaboration rules** are written over the surface language. Each rule states a legality condition and produces a
  term of the **core**, an explicitly typed internal language. Every binder, type instantiation, and purity
  instantiation is written in the core, so core typing needs no inference.
- **Core rules** define core typing and the dynamic semantics. The dynamics are an **abstract machine**, a small-step
  semantics whose states carry an explicit stack, so that the tail-call space bound can be stated
  ([D0023](../../design/decisions/D0023-claimed-meta-properties.md)).

## Files

| File | Holds |
| --- | --- |
| [`static.md`](static.md) | Elaboration rules (surface → core, with rule IDs), and core typing rules. |
| [`dynamic.md`](dynamic.md) | Core dynamics: the abstract machine's states and step rules. |
| [`metatheory.md`](metatheory.md) | The claimed meta-properties, their proofs or proof sketches, and links to the mechanized proofs. |
| `lean/` | The Lean 4 mechanization of the core, a Lake package: core syntax, typing, machine, proofs, and the reference evaluator and checker. Created in M03 ([D0028](../../design/decisions/D0028-mechanization-starts-in-m03.md)). |

## Mechanization and authority

1. **What is mechanized** ([D0024](../../design/decisions/D0024-mechanize-the-core.md)): the core's syntax, typing,
   and machine dynamics, and the proofs of core type soundness, purity soundness with the frame property,
   determinism, and the tail-call space bound. The elaboration rules, and the proofs of elaboration soundness and
   decidable checking, are on paper in this directory.
2. **Proof assistant** ([D0025](../../design/decisions/D0025-lean-4.md)): Lean 4, with the version pinned in
   `lean/lean-toolchain` and changed only deliberately, with the proofs re-checked in the same change.
3. **Which text governs** ([D0026](../../design/decisions/D0026-lean-governs-core-rules.md)): for a core rule, the
   Lean definition governs. Its rendering here names the Lean definition and must match it. A mismatch is a defect in
   the rendering. For an elaboration rule, the rule here governs.
4. **Executable reference** ([D0027](../../design/decisions/D0027-executable-reference.md)): the Lean package contains
   a fuel-indexed reference evaluator, proved sound against the machine rules, and a reference checker, proved sound
   and complete against the core typing rules, which reports rule IDs. *Out of fuel* means inconclusive. The core
   interchange format implementations emit is open
   ([OQ-008](../../design/open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)).
5. **Upkeep:** each milestone that adds or changes core rules updates the mechanization and repairs its proofs
   before it exits, or records each remaining gap as an open question.

## Conventions

1. Rules are written in Markdown with LaTeX math (`$…$` inline, `$$…$$` for display).
2. Every file begins with two tables: its **judgment forms** (each with its reading in words) and its
   **metavariables** (each with what it ranges over).
3. Every rule has a name, in small capitals style, prefixed by its judgment family. Examples: $\textsc{T-Var}$ for a
   core typing rule, $\textsc{El-Try}$ for an elaboration rule, $\textsc{M-App}$ for a machine step.
4. Every core rule names its Lean definition after its name, as in *T-App [Lean: `Qubec.Core.HasType.app`]*
   ([D0026](../../design/decisions/D0026-lean-governs-core-rules.md)).
5. Every rule is followed by a prose explanation of each premise and of the conclusion.
6. Every rule cites the decisions it formalizes: `[Dnnnn]`.
7. A rule whose decision is provisional is marked *Provisional (OQ-nnn)*.
8. Every premise or side condition whose failure rejects a program is tagged with the rule ID it enforces, for
   example $[\text{R-func-calls-proc}]$ ([D0018](../../design/decisions/D0018-diagnosis-and-rule-ids.md)).
9. Rules in `dynamic.md` correspond, through elaboration, to the numbered steps of the chapter they formalize
   ([D0017](../../design/decisions/D0017-rule-style.md), [D0022](../../design/decisions/D0022-typed-elaboration-into-core.md)).
10. In Lean sources, syntax functions with more than one argument are applied explicitly (`Expr.subst j s e`), not
    with method-call notation (`e.subst j s`), which can silently supply the wrong argument
    ([D0025](../../design/decisions/D0025-lean-4.md)).

## Authority and promotion

Formal rules govern an aspect (static or dynamic) of a chapter only when that chapter's status line marks the aspect
*complete*. Elsewhere the chapter's prose governs, and these rules are a model that must agree with it. An aspect is
promoted to *complete* only by a recorded decision, and only within the formal target. Promotion requires:
- every normative rule of the aspect has formal rules here;
- every way to fail them is tagged with a rule ID;
- the meta-properties covering its core rules are proved in the mechanization, and those covering its elaboration
  rules have a proof sketch in [`metatheory.md`](metatheory.md);
- the reference evaluator and checker cover its core rules.

The sources are [D0016](../../design/decisions/D0016-authority-per-section.md),
[D0024](../../design/decisions/D0024-mechanize-the-core.md),
[D0027](../../design/decisions/D0027-executable-reference.md), and spec
[§1.3.3](../01-introduction.md#133-formal-status-and-authority).

A rule is laid out like this:

$$
\frac{\text{premise}_1 \qquad \cdots \qquad \text{premise}_n}{\text{conclusion}}\ \textsc{Name}
$$
