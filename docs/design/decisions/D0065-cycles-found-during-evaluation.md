# D0065: A cycle between constants is found during evaluation and is a rejection

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

A **cycle** is when evaluating a constant needs its own value, directly or through other constants and the functions
they call. Some apparent cycles pass through code that evaluation never runs. How are cycles found, and which count?
Every constant is evaluated once ([D0064](D0064-every-constant-once.md)).

## Options considered

The scenario for every option (provisional syntax):

```
const A: Int = helper(0);
const B: Int = A + 1;
func helper(n: Int) -> Int = if n > 100 { B } else { n * 2 };   // mentions B, but helper(0) never reaches it

const C: Int = D + 1;
const D: Int = C + 1;                                            // a real cycle
```

### A. Static: a dependency graph built from names

X depends on Y if X's initializer mentions Y, or mentions a callable whose body mentions Y, transitively. Any cycle is
rejected before evaluation: A → `helper` → B → A (a false positive) and C ↔ D.

- **Easy:** the diagnostic can show the whole cycle before anything is evaluated.
- **Hard:** false positives; the graph must be defined through function values, closures, and M06's trait methods,
  identically in every implementation, and extended by every later milestone.
- **Prior art (recalled):** Go's initialization-cycle rule for package variables follows references through function
  bodies.

### B. Dynamic: detected during evaluation

Each constant is *unevaluated*, *in progress*, or *evaluated*. Reading a constant that is in progress is a cycle. A
mention in code that never runs is not. A = 0 and B = 1 are accepted; C and D are rejected.

- **Easy:** precise; one state per constant; unaffected by function values, traits, or anything later; deterministic
  because evaluation is ([D0051](D0051-deterministic-sequential-language.md)).
- **Hard:** whether a cycle exists depends on values, so changing a value can reveal one; the diagnostic shows the
  chain that was followed.
- **Prior art (recalled):** Rust's compiler reports a cycle when evaluation re-enters a query that is still running.

### C. Declaration order

A constant may mention only constants declared above it, as in C or OCaml.

- **Hard:** it decides M04's question of whether top-level declarations depend on their order, and functions, which
  may mention constants declared anywhere, still need A or B.

Recommendation at the time: **B**: A's graph would have to be re-specified by later milestones, and C pre-empts M04
while still needing B.

## Choice

**B.**
1. During compile-time evaluation, each constant is unevaluated, in progress, or evaluated.
2. **[R-const-cycle]** If evaluating a constant reads a constant whose evaluation is in progress, the program is
   rejected.
3. A mention of a constant in code that its evaluation never runs is not a cycle.

## Rationale

The dynamic rule is exact: it rejects exactly the programs whose constants cannot all have values, and it costs one
state per constant. It needs no definition of "depends on" that M04, M06, and M11 would each have to extend, and its
dependence on values is harmless because evaluation is deterministic.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 5.
- **Formal:** constant evaluation is a relation over a store of constant states, with cycle detection as one premise
  ([dynamic.md](../../spec/formal/dynamic.md), from M03).
- **M15:** the diagnostic shows the chain of constants and calls that closed the cycle.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 5
- Grammar rules: none
- Formal rules: none yet ([dynamic.md](../../spec/formal/dynamic.md) note)
- Examples / tour: none
