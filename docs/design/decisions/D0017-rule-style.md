# D0017: Static rules are declarative; dynamic behavior is written as numbered steps where order is observable

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

In what style are the specification's rules written? A **declarative** rule states a property ("X MUST hold"). An
**algorithmic** rule gives numbered steps ("To do X: 1. … 2. …"). Declarative rules are short but can leave order
implicit, and order is what becomes observable once effects, panics, and concurrency exist. Steps never leave order
implicit, but they are long, and they over-specify questions that have no order, such as legality. This builds on
[D0015](D0015-spec-audience-and-scope.md) (one readable specification) and
[D0016](D0016-authority-per-section.md) (the prose governs where an aspect is not formally complete).

## Options considered

The scenario for every option: the static rule "a `func` must not call a `proc`" ([D0008](D0008-purity.md)), and
the dynamic behavior of `add(a(), b())`, where `a` and `b` are procedures that print. Whether QubeC fixes that order
is M03's decision; this question is only about how rules are written.

### A. Declarative throughout

```
(static)  The body of a `func` MUST NOT call a `proc`. [D0008]
(dynamic) In a call f(a1, …, an), the callee and the arguments are
          evaluated left to right, each exactly once, before the
          body of f is entered.
```

- **Easy:** short and readable.
- **Hard:** ordering facts are easy to forget or leave vague; interactions (what if `a1` panics?) are spread across
  sentences.
- **Prior art:** Go and the JLS. Go leaves some orders unspecified: with `f` incrementing `a`, `x := []int{a, f()}`
  "may be [1, 2] or [2, 2]" (verified, [R0003](../research/R0003-spec-conventions-prior-art.md)).

### B. Algorithmic throughout

```
(static)  To check a `func` declaration d:
            1. Let b be the body of d.
            2. For each call c in b, outside nested lambdas: if the
               callee of c is a proc, reject d.
(dynamic) To evaluate f(a1, …, an):
            1. Evaluate f to a callable g.
            2. For i = 1..n, evaluate ai to vi.
            3. Invoke g with v1, …, vn.
```

- **Easy:** nothing is ambiguous; maps directly to an implementation.
- **Hard:** long and hard to read; static checks read as one particular algorithm, which pins implementations to it
  and hides the property checked.
- **Prior art (recalled):** ECMAScript, precise and hard to read.

### C. Mixed

Static rules are declarative. Dynamic behavior is written as numbered steps wherever order is observable.

```
(static)  The body of a `func` MUST NOT call a `proc`. [D0008]
(dynamic) To evaluate f(a1, …, an):
            1. Evaluate f to a callable g.
            2. Evaluate a1, …, an in order to v1, …, vn. If one of them
               panics, the call panics and no later argument is evaluated.
            3. Invoke g with v1, …, vn.
```

- **Easy:** legality questions get short answers; run-time behavior has no ordering gaps. The steps match an
  operational semantics and a tree-walking evaluator closely. Facts such as "cleanup runs before the jump" for
  `tailcall` ([D0014](D0014-tailcall-keyword.md)) are naturally steps.
- **Hard:** two styles, and the writer judges when order is observable.
- **Prior art (recalled):** WebAssembly writes validation declaratively and execution as numbered steps.

| | A Declarative | B Algorithmic | C Mixed |
| --- | --- | --- | --- |
| Readability | high | low | high (static), medium (dynamic) |
| Order gaps | possible | none | none where it matters |
| Maps to an evaluator | indirectly | directly | directly |
| Length | short | long | medium |

Recommendation at the time: **C**, which uses the better style for each kind of question.

## Choice

**C.**
1. **Static rules** (lexical and syntactic well-formedness, name resolution, typing, purity, and other legality
   conditions) are stated declaratively, as properties a program must have.
2. **Dynamic behavior** is stated as numbered steps wherever order is observable: effects, panics, evaluation order,
   cleanup, and, later, concurrency. Where order is not observable (for example, the value of a pure arithmetic
   expression that cannot panic), a declarative statement is allowed.
3. In a dynamically complete aspect ([D0016](D0016-authority-per-section.md)), the steps correspond to the rules in
   `formal/dynamic.md`.

## Rationale

Programmers mostly ask static questions, and declarative rules answer them readably. Observable order is where
declarative prose has left gaps in other specifications. Numbered steps close those gaps, and they are the shape
that the formal dynamic rules and the evaluator need anyway.

## Consequences

- **Spec §1.3.4** states the style. Every later chapter follows it.
- **M03, M08, M10:** evaluation order, panics, and concurrency are written as steps.
- **The reference evaluator** and the self-hosted compiler's interpreter get a direct template.

## Affected artifacts

- Spec: [§1.3.4](../../spec/01-introduction.md#134-rule-style); [conventions](../../spec/README.md)
- Grammar rules: none
- Formal rules: none (correspondence stated in [formal/README.md](../../spec/formal/README.md))
- Examples / tour: none
