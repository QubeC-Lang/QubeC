# D0023: Claimed meta-properties: soundness, purity with a frame property, tail-call space, determinism, decidable checking

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

A **meta-property** is a theorem about the language rather than in it, such as "well-typed programs do not get
stuck". Which meta-properties do we claim? Every claimed property needs a proof sketch, or a mechanized proof
([D0024](D0024-mechanize-the-core.md)), before a chapter it covers can be promoted
([D0016](D0016-authority-per-section.md)). Some follow from the formal target
([D0021](D0021-formal-target-sequential-language.md)) and typed elaboration
([D0022](D0022-typed-elaboration-into-core.md)); the question is which further properties we add.

## Options considered

**Baseline, implied by D0021 and D0022:**
1. **Core type soundness:** progress and preservation.
2. **Elaboration soundness:** elaborated core is well typed at the elaborated type.
3. **Purity soundness:** a `func` call performs no IO (debug output excepted, [D0008](D0008-purity.md)) and changes
   no value that existed before the call (a **frame property**, which states
   [D0011](D0011-local-mutation-in-functions.md) as a theorem).

The candidates beyond the baseline, all shown on one scenario (provisional syntax beyond the decided forms):

```
func squares(n: Int) -> List[Int] = {
  let mut acc = List.new();
  for i in 0..n { acc.push(i * i); }
  acc
}
func count_down(n: Int) -> Int =
  if n == 0 { 0 } else { tailcall count_down(n - 1) }
proc main() {
  let a = squares(3);
  let b = squares(3);
  print(count_down(1_000_000));
}
```

### 1. Referential transparency

Two calls of a `func` with equal arguments give interchangeable results: `squares(3)` could be replaced by its
value, or `b` by `a`, without any program noticing.

- **Proof technique:** a relational argument (a **logical relation**, a type-indexed family of relations saying when
  two values behave the same), as in the proof of `runST` encapsulation, which was built in a separation logic
  (verified, [R0004](../research/R0004-formalization-prior-art-and-pilots.md)).
- **Easy:** justifies optimizations such as merging or hoisting calls.
- **Hard:** depends on whether value identity is observable, which M07 decides; the heaviest proof of the four.

### 2. Tail-call space bound

A chain of calls marked `tailcall` runs in bounded stack: `count_down(1_000_000)` uses the stack depth of
`count_down(1)` ([D0012](D0012-tail-calls-and-stacks.md), [D0014](D0014-tailcall-keyword.md)).

- **Proof technique:** big-step rules have no stack, so the property cannot even be stated there. It needs an
  **abstract machine** for the core: a small-step semantics whose states include an explicit stack (a
  continuation), such as a CEK machine (control, environment, continuation). The lemma is that a marked call never
  grows the continuation.
- **Easy:** D0012's guarantee becomes checkable; the dynamic rules take the step-by-step shape that
  [D0017](D0017-rule-style.md) uses anyway.
- **Hard:** a machine semantics is more verbose than big-step rules.
- **Prior art:** Clinger defines proper tail recursion for Scheme through a space model (verified, R0004).

### 3. Determinism

Every sequential program has at most one outcome: one output, then one result, panic, or divergence.

- **Proof technique:** induction on evaluation, once evaluation order is fixed.
- **Easy:** a conformance test's expected outcome is unique by theorem.
- **Hard:** rules out unspecified evaluation order, which NG-9 and D0017 already exclude.

### 4. Decidable checking

An algorithm (the type-and-purity inference M05 and M06 design) is **sound** (whatever it accepts has a derivation
in the declarative rules) and **complete** (whatever has a derivation, it accepts), and names a rule ID when it
rejects.

- **Proof technique:** a second, syntax-directed set of rules or a function, related to the declarative rules; it
  needs principal types or deliberately restricted inference.
- **Easy:** [D0018](D0018-diagnosis-and-rule-ids.md)'s "every violation is diagnosed by a checkable rule" becomes a
  theorem; implementations know exactly which programs to accept.
- **Hard:** constrains M05/M06: features with undecidable or non-principal inference need annotations.
- **Prior art:** CakeML's type inferencer is verified sound and complete against its declarative type system
  (verified, R0004).

| Property | Cost | Constrains | Payoff |
| --- | --- | --- | --- |
| 1 Referential transparency | very high | M07 (identity) | optimizations; strongest "pure" |
| 2 Tail-call space | medium | core dynamics are a machine | D0012 proved |
| 3 Determinism | low | evaluation order fixed | unique test outcomes |
| 4 Decidable checking | medium–high | M05/M06 inference | D0018 proved |

Recommendation at the time: **2, 3, and 4**, each of which turns an earlier decision into a theorem at moderate
cost; 1 depends on M07's identity rules and is research-grade.

## Choice

**The baseline plus 2, 3, and 4.** We claim, for the formal target of D0021:
1. **Core type soundness** (progress and preservation): a well-typed core program finishes with a value, panics in
   a defined way, or runs forever; it never gets stuck.
2. **Elaboration soundness:** if `Γ ⊢ e : τ ⇝ c`, then `c` is a well-typed core term of the elaborated type.
3. **Purity soundness:** evaluating a call of a `func` performs no observable effect, and every value that existed
   before the call is unchanged after it (the frame property).
4. **Tail-call space bound:** a call marked `tailcall` does not grow the stack. To state this, the core's dynamic
   semantics is an abstract machine with an explicit stack.
5. **Determinism:** every sequential program has at most one outcome.
6. **Decidable checking:** the inference algorithm is sound and complete with respect to the elaboration rules, and
   on rejection it names a rule ID of a violated rule.

Referential transparency is not claimed; M07 or M13 may add it by a new decision.

## Rationale

Each claimed property turns a commitment we have already made into a theorem: Safety
([D0004](D0004-ranked-design-values.md)) into soundness, [D0008](D0008-purity.md) and
[D0011](D0011-local-mutation-in-functions.md) into purity with a frame property,
[D0012](D0012-tail-calls-and-stacks.md) into the space bound, unique test outcomes into determinism, and
[D0018](D0018-diagnosis-and-rule-ids.md) into decidable checking. Referential transparency would cost the most and
depends on a decision M07 has not made.

## Consequences

- **M03:** the core's dynamics are an abstract machine with an explicit stack; small-step machine rules are the
  style of `formal/dynamic.md`.
- **M05/M06:** inference must remain decidable with principal results, or require annotations where it would not.
- **M07:** must define value identity and the frame property's notion of "existed before the call"; may add
  referential transparency.
- **M13:** finishes any remaining proofs of these six properties.

## Affected artifacts

- Spec: none directly; promotion requirements in
  [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority)
- Grammar rules: none
- Formal rules: [metatheory.md](../../spec/formal/metatheory.md) (the claimed properties);
  [dynamic.md](../../spec/formal/dynamic.md) (machine style)
- Examples / tour: none
