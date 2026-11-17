# D0027: An executable reference: a verified core evaluator and a verified core checker

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

Should the mechanized core ([D0024](D0024-mechanize-the-core.md), [D0025](D0025-lean-4.md)) also run, as a
reference against which conformance tests and implementations are checked? The mechanized rules are inductive
relations, which can be reasoned about but not run. A **definitional interpreter** is an ordinary function plus a
theorem that it agrees with the relation; once that is proved, running the function is running the specification.
Comparing its answers with an implementation's is **differential testing**.

Two earlier choices make this cheap. The core is explicitly typed ([D0022](D0022-typed-elaboration-into-core.md)),
so checking it is syntax-directed. Its dynamics are an abstract machine
([D0023](D0023-claimed-meta-properties.md)), whose step is naturally a function. Lean functions must terminate while
QubeC programs may diverge, so an evaluator takes **fuel**, a step budget; running out of fuel is inconclusive,
never wrong.

## Options considered

The scenario for every option (provisional syntax and commands):

```
// expect: output "6"
func sum3(a: Int, b: Int, c: Int) -> Int = a + b + c
proc main() { print(sum3(1, 2, 3)); }

func spin(n: Int) -> Int = tailcall spin(n)      // diverges in constant stack
func f() -> Int = (|| read_count())();           // expect: reject R-func-calls-proc
```

### A. Proofs only

Relations and theorems; nothing runs; conformance tests run only against implementations.

- **Easy:** the least work.
- **Hard:** nothing checks that a test's expected outcome agrees with the formal rules.
- **Prior art (recalled):** most mechanized research calculi.

### B. A verified core evaluator

A fuel-indexed runner of the machine, proved to agree with the machine relation.

```
$ qubec-ref run sum.core   → 6
$ qubec-ref run spin.core  → out of fuel (stack depth stayed 1)
```

- **Easy:** run-time expectations of tests are checked against the definition; stack depth is observable, so the
  tail-call bound can be tested too.
- **Hard:** implementations must be able to emit core in an agreed interchange format.
- **Prior art:** Watt's Isabelle mechanization of WebAssembly includes a verified executable interpreter; SpecTec
  generates an interpreter that passes the applicable official tests (both verified,
  [R0004](../research/R0004-formalization-prior-art-and-pilots.md)).

### C. A verified core evaluator and a verified core checker

Option B, plus a core type-and-purity checker, proved sound and complete with respect to the core typing relation,
which answers *ok* or *reject* with a rule ID.

```
$ qubec-ref check f.core
reject R-func-calls-proc: body has effect eff, expected pure
```

- **Easy:** static expectations, half of the conformance suite under
  [D0018](D0018-diagnosis-and-rule-ids.md), are checked too; any implementation's elaborator is checked, because
  ill-typed core output is caught; the self-hosted compiler gains a core lint.
- **Hard:** a checker case with its soundness and completeness lemmas for every core construct; rule IDs are
  threaded through the checker; rejections made by elaboration are still checked only by implementations.
- **Prior art:** Watt's mechanization includes a verified type checker (verified, R0004); GHC re-checks its typed
  Core (recalled).

Recommendation at the time: **C**, since an explicitly typed core makes the checker cheap and static rejection is
central to the conformance suite.

## Choice

**C.**
1. The Lean package contains a fuel-indexed **reference evaluator** for the core's machine, proved sound with
   respect to the machine relation, and a **reference checker** for core typing and purity, proved sound and complete
   with respect to the core typing relation.
2. The reference runs as a command-line tool. It answers *ok*; *reject* with a rule ID; a result with its output; or
   *out of fuel*. Its name and commands are provisional
   ([OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)).
3. *Out of fuel* never decides a conformance test.
4. Implementations are expected to be able to emit the core of a program in an interchange format, so that the
   reference can check and run it. The format and the interface are open
   ([OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)).

## Rationale

Rejection rules are named and must be reported, so static behavior is half of what conformance tests check; a
verified checker lets the tests and every front end be checked against the definition itself. With an explicitly
typed core and machine dynamics, both functions are nearly direct transcriptions of the rules.

## Consequences

- **M03–M09:** each new core construct adds an evaluator step and a checker case, with their lemmas.
- **Promotion** ([D0016](D0016-authority-per-section.md)) of an aspect also requires that the reference covers the
  core constructs it uses.
- **M11:** the reference evaluator is a candidate model for compile-time evaluation.
- **M15/M16:** the conformance harness runs the reference beside implementations; M16 settles OQ-008.

> **Later note (T0012).** The reference evaluates each constant with fuel of at least its guaranteed number of steps
> ([D0070](D0070-compile-time-step-floor-and-cap.md)); running out of fuel stays inconclusive.

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority) (promotion requirement)
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md); [dynamic.md](../../spec/formal/dynamic.md)
- Examples / tour: none
