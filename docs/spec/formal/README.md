# Formal Rules: Notation

Status: skeleton. The notation below is the default until M00 decides how far we formalize and whether rules are
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

A rule is laid out like this:

$$
\frac{\text{premise}_1 \qquad \cdots \qquad \text{premise}_n}{\text{conclusion}}\ \textsc{Name}
$$
