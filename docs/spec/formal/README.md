# Formal Rules: Notation

Status: skeleton. The notation below is the default until T0005 decides how far we formalize and whether rules are
mechanized; any change is recorded as a decision.

## Files

| File | Holds |
| --- | --- |
| [`static.md`](static.md) | Static semantics: well-formedness and typing judgments, as named inference rules. |
| [`dynamic.md`](dynamic.md) | Dynamic semantics: operational rules (small-step or big-step, decided later). |
| [`metatheory.md`](metatheory.md) | The meta-properties we claim (such as type soundness), with proof sketches. |

A memory or concurrency model gets its own file if we need one.

## Conventions

1. Rules are written in Markdown with LaTeX math (`$…$` inline, `$$…$$` for display).
2. Every file begins with two tables: its **judgment forms** (each with its reading in words) and its
   **metavariables** (each with what it ranges over).
3. Every rule has a name, in small capitals style, prefixed by its judgment family, for example
   $\textsc{T-Var}$ for a typing rule or $\textsc{E-App}$ for an evaluation rule.
4. Every rule is followed by a prose explanation of each premise and of the conclusion.
5. Every rule cites the decisions it formalizes: `[Dnnnn]`.
6. A rule whose decision is provisional is marked *Provisional (OQ-nnn)*.
7. Every premise or side condition whose failure rejects a program is tagged with the rule ID it enforces, for
   example $[\text{R-func-calls-proc}]$ ([D0018](../../design/decisions/D0018-diagnosis-and-rule-ids.md)).
8. Rules in `dynamic.md` correspond to the numbered steps of the chapter they formalize
   ([D0017](../../design/decisions/D0017-rule-style.md)).

## Authority

Formal rules govern an aspect (static or dynamic) of a chapter only when that chapter's status line marks the aspect
*complete*; elsewhere the chapter's prose governs, and these rules are a model that must agree with it. An aspect is
promoted to *complete* only by a recorded decision, which requires: every normative rule of the aspect has formal
rules here; every way to fail them is tagged with a rule ID; and the meta-properties covering the aspect have at
least a proof sketch in [`metatheory.md`](metatheory.md) (a mechanized proof if we choose mechanization)
([D0016](../../design/decisions/D0016-authority-per-section.md), spec
[§1.3.3](../01-introduction.md#133-formal-status-and-authority)).

A rule is laid out like this:

$$
\frac{\text{premise}_1 \qquad \cdots \qquad \text{premise}_n}{\text{conclusion}}\ \textsc{Name}
$$
