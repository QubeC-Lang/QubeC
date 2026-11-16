# D0003: Target users: tool builders first, then application developers and systems programmers

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

Which groups do we design *for*? A designed-for group is a reference user: if a feature confuses them, that counts
as a defect. The answer sets the learning-curve budget, how much the compiler infers versus what users annotate
(M05), and the diagnostics (M15). It builds on [D0002](D0002-purpose-and-domain.md) (tooling-first).

## Options considered (multi-select)

Each group writes the same program: a tiny arithmetic evaluator that must report division by zero. All code is
provisional syntax.

### A. Tool builders

Compiler, interpreter, DSL, and developer-tool authors. They need ADTs, exhaustive matching, error values, and
persistent maps for scoped symbol tables. Prior art (recalled): OCaml, F#, Rust, and Haskell, whose abstraction
sometimes overshoots.

```
fn eval(e: Expr) -> Result[Int, EvalError] =
  match e {
    Num(n)    -> Ok(n),
    Add(l, r) -> Ok(eval(l)? + eval(r)?),
    Div(l, r) -> {
      let d = eval(r)?
      if d == 0 then Err(DivByZero) else Ok(eval(l)? / d)
    },
  }
```

### B. Systems programmers

From C, C++, Rust, and Zig. They need visible integer widths and overflow behavior, control over boxing and
allocation, and predictable costs. Designing the *default* for them pulls toward Rust-level explicitness.

```
fn eval(e: &Expr) -> Result[i64, EvalError] =
  match e {
    Num(n)    -> Ok(*n),
    Add(l, r) -> eval(l)?.checked_add(eval(r)?).ok_or(Overflow),
    Div(l, r) -> { let d = eval(r)?; if d == 0 { Err(DivByZero) } else { Ok(eval(l)? / d) } },
  }
```

### C. Application developers

From Python, Kotlin, and Go. They need inference, little ceremony, and friendly errors, which makes inference
quality and diagnostics first-order concerns. Prior art (recalled): Gleam; Kotlin; Elm, loved for its errors but
too restrictive as programs grew.

```
fn eval(e) = match e {            // parameter and result types inferred
  Num(n)    -> n,
  Add(l, r) -> eval(l) + eval(r),
  Div(l, r) -> eval(l) / eval(r), // panics on zero: simplest, least explicit
}
```

### D. Learners and teachers

They need a small, explicit core and a textbook-quality spec. Prior art (recalled): Pascal and Racket's teaching
languages, which are rarely adopted beyond teaching. Designing for learners tends to cap expressiveness.

**How the groups interact:**
- A and C fit together naturally: ML-style inference with ADTs.
- Adding B creates a tension between explicitness and inference. Layering can resolve it: a light default, plus an
  opt-in explicit layer for widths and borrowed data. That layer must be *safe*, which commits M07 to some form of
  borrow checking, the hardest formalization item.

Recommendation at the time: **A + C, with A primary**, serving B through an opt-in layer rather than designing the
default for B. We noted it was close, and that including B is reasonable if we accept the M07 cost knowingly.

## Choice

- **Tool builders (A): primary.**
- **Application developers (C).**
- **Systems programmers (B).**
- Learners and teachers (D) are not a design target.

## Rationale

We want QubeC to be easy to start for application developers and to reach real systems work, not only FFI. We
accept the cost that comes with B: the explicit layer has to be safe, so M07 must provide checked borrowed
references. The tension between B and C is resolved by the layered value ranking in
[D0004](D0004-ranked-design-values.md).

## Consequences

- Inference and diagnostics quality are first-order concerns for M05 and M15 (group C).
- M05 decides how the explicit layer is marked and how `Int` relates to sized integers
  ([OQ-003](../open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones)).
- M07 must provide safe borrowed references for the explicit layer (group B).
- Rejecting a feature because it would only help learners is legitimate (D is not a target).

## Affected artifacts

- Spec: none yet
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md)
