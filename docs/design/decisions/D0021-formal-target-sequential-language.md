# D0021: The formal target is the whole sequential language

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

Which parts of QubeC get formal static and dynamic rules and are covered by our theorems? Under
[D0016](D0016-authority-per-section.md), an aspect outside this **formal target** can reach the formal status
*partial* but never *complete*, so its prose governs permanently. The answer is therefore also a ceiling on formal
authority. How the rules are written ([D0022](D0022-typed-elaboration-into-core.md)), what is claimed
([D0023](D0023-claimed-meta-properties.md)), and whether the proofs are machine-checked
([D0024](D0024-mechanize-the-core.md)) are separate decisions.

## Options considered

The scenario for every option touches each area (provisional syntax beyond `func`, `proc`, `let`, and `let mut`):

```
func squares(n: Int) -> List[Int] = {      // D0011: mutates a list it created
  let mut acc = List.new();
  for i in 0..n { acc.push(i * i); }
  acc                                      // handed over finished: still pure
}
func total(xs: &[i64]) -> i64 = { … }      // explicit layer: borrowed slice (D0004)
proc main() {
  let xs = squares(10);
  spawn log("started");                    // concurrency (OQ-001)
  print(total(&xs.as_i64()));
}
```

### A. A featherweight subset

A deliberately small sub-language (functions, `let`, algebraic data types and `match`, integers, `func`/`proc`
purity) gets formal rules; everything else is prose only.

- **In the scenario:** the calls and purity of `main` are formal; the loop, the list mutation, `&[i64]`, and `spawn`
  are not.
- **Easy:** small proofs, quick to write.
- **Hard:** the theorem is about a language nobody writes; chapters on generics, traits, errors, and modules can
  never be complete.
- **Locks in / rules out:** formal authority stays marginal; later milestones are unconstrained.
- **Prior art (recalled):** Featherweight Java (2001) and Featherweight Go (2020), research subsets that did not
  govern their languages' specifications.

### B. The whole sequential language

Every sequential construct of both layers gets formal rules: algebraic data types, generics, traits, errors, modules,
the local-mutation analysis of [D0011](D0011-local-mutation-in-functions.md), sized integers, and the explicit
layer's borrow rules as typing rules. Concurrency (`spawn`, channels, race freedom) and any low-level memory model
stay prose-governed, with an informal argument.

- **In the scenario:** everything except `spawn` is formal.
- **Easy:** "well-typed sequential QubeC cannot reach undefined behavior, and a `func` does nothing observable"
  becomes a theorem about the code users write; every sequential chapter can be promoted.
- **Hard:** a large but bounded amount of rule writing, spread over M03–M09. Two items are expensive. Proving that a
  function's private mutation is unobservable is the encapsulation problem of Haskell's `runST`, whose relational
  proof needed a logical relation built in a separation logic (verified,
  [R0004](../research/R0004-formalization-prior-art-and-pilots.md)); a syntactic ownership or uniqueness discipline
  keeps the proof syntactic and much cheaper. Safe borrows are cheap to prove if references are second-class (they
  cannot be stored or returned), and need separation-logic machinery if they are first-class with lifetimes.
- **Locks in / rules out:** M07 is steered toward provable designs, through a revisit trigger rather than a ban.
- **Prior art (recalled):** the Definition of Standard ML (whole language, on paper); CakeML (whole sequential ML,
  mechanized); WebAssembly (whole language).

### C. Everything, including concurrency and the memory model

Option B, plus formal rules for tasks and channels, a race-freedom theorem, and a memory model.

- **Easy:** the strongest claim, including that `spawn log(…)` cannot race on `xs`.
- **Hard:** concurrent semantics with race freedom is research-grade work; it would force M10 to choose a mechanism
  we already know how to prove.
- **Prior art (recalled):** the Java memory model was formalized and found flawed; WebAssembly's threads proposal
  has a formal memory model by its research team; Go has no formal concurrency semantics.

### D. The whole sequential default layer; the explicit layer in prose

Option B minus the explicit layer's borrowed references and casts, which stay prose-governed.

- **Easy:** the hardest proof item leaves the target; M07 may choose any borrow design.
- **Hard:** the safety of the explicit layer, which systems programmers rely on
  ([D0003](D0003-target-users.md)), rests on prose; the boundary between the layers must be drawn formally.
- **Locks in / rules out:** explicit-layer chapters can never be formally complete.

| | A Subset | B Sequential | C Everything | D Default layer |
| --- | --- | --- | --- | --- |
| Theorem about the code users write | no | yes (sequential) | yes | yes (default layer) |
| Chapters that can be promoted | few | all but concurrency | all | all but explicit and concurrency |
| Rule-writing cost | low | high, spread out | very high | medium–high |
| Pressure on M07 / M10 | none | M07, through a revisit trigger | both | M07 mutation only |

Recommendation at the time: **B with a revisit trigger**, because it is the only option where Safety, ranked first
in both layers ([D0004](D0004-ranked-design-values.md)), becomes a theorem about the language people write; D was
named as the fallback if M07 should stay entirely unconstrained.

## Choice

**B.**
1. The formal target is the **whole sequential language**, in both layers: every sequential construct has formal
   static and dynamic rules, including the local-mutation analysis ([D0011](D0011-local-mutation-in-functions.md))
   and the explicit layer's borrow rules, stated as typing rules.
2. Outside the target: concurrency (tasks, channels, `select`, race freedom) and any low-level memory model. Their
   chapters stay prose-governed: their formal status may be *partial* or *none*, never *complete*. Their safety
   guarantees are argued informally in the prose.
3. **Revisit trigger.** If the design M07 proposes for local mutation or for borrowed references cannot be proved
   sound by syntactic methods (typing rules with progress and preservation), the affected chapter's formal status is
   capped at *partial*, and this decision is revisited, instead of M07 being forced to change its design.

## Rationale

Safety ranks first, and a theorem about a core that users never write claims less than it seems to. The line
"sequential" is principled, and it falls where the cost jumps from large to research-grade. The revisit trigger
keeps Rigor from vetoing features ([D0004](D0004-ranked-design-values.md) deliberately left Rigor unranked): an
unprovable design costs a chapter its formal authority, not its place in the language.

## Consequences

- **M03–M09** write formal rules for every sequential construct they decide.
- **M07** should prefer a mutation and borrow discipline that is provable syntactically (an ownership or uniqueness
  discipline for [D0011](D0011-local-mutation-in-functions.md); second-class references for borrows). Anything else
  triggers a revisit of this decision.
- **M10** may choose any concurrency mechanism; its chapter can never be formally complete.
- **M13** consolidates the formal rules and proofs of the sequential language.

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority) (the formal target)
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md) (scope);
  [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: none
