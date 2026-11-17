# D0066: A constant does not depend on an enclosing generic parameter

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

A local constant inside a generic callable could mention the callable's type parameter, or a purity parameter
([D0008](D0008-purity.md)). Its value would then differ per instantiation, which collides with evaluating every
constant exactly once ([D0064](D0064-every-constant-once.md)). Generics are M06's, but this part of their interaction
with constants is decided now.

## Options considered

The scenario for every option (provisional syntax; `size_of` is invented for illustration):

```
func capacity_for[T]() -> Int = {
  const PAGE: Int = 4096;                        // no T: one value
  const PER_ITEM: Int = PAGE / size_of[T]();     // mentions T
  PER_ITEM
};
proc main() { println(capacity_for[Int]().to_str()); }
```

### A. No: rejected

`PAGE` is accepted; `PER_ITEM` is rejected. A value that varies per type is an ordinary expression evaluated at run
time, or later a per-type value that M06 provides.

- **Easy:** "every constant, exactly once" has no exceptions; no **post-monomorphization errors** (failures that
  appear only when a particular instantiation is compiled); M06 stays free to implement generics by
  monomorphization or by dictionary passing.
- **Hard:** per-type constants need another mechanism.

### B. Yes, evaluated once per instantiation

- **Easy:** natural for per-type buffer sizes.
- **Hard:** which instantiations exist depends on use, so `capacity_for[Unit]()` would fail only when someone calls it,
  breaking D0064; it pushes M06 toward monomorphization.
- **Prior art:** Rust rejects `S::<()>::SZ` with `10 / size_of::<T>()` only when that instantiation is used, a
  post-monomorphization error (verified by running it, [R0010](../research/R0010-compile-time-evaluation-prior-art-and-pilots.md));
  C++ template instantiation errors are similar (recalled).

### C. Defer to M06, rejected meanwhile

As A today, marked Provisional with an open question.

Recommendation at the time: **A**, which keeps D0064 a rule without exceptions; M06 can supersede it by a new
decision if it finds a real need.

## Choice

**A.** **[R-const-generic]** The type and the initializer of a constant must not mention a type parameter or a purity
parameter of an enclosing declaration.

## Rationale

It is what keeps "every constant, exactly once" well defined. It rules out errors that depend on which instantiations
a program happens to use, and it does not force M06's choice of how generics are implemented.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 6; the rule
  moves to the chapter on constants when M04 writes it.
- **M06:** per-type values, if wanted, are provided by a mechanism other than `const`, such as values associated with
  a trait; M06 remains free to choose monomorphization or dictionary passing.
- **Formal:** the static rule for a constant declaration excludes enclosing generic parameters from its context.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 6
- Grammar rules: none
- Formal rules: none yet
- Examples / tour: none
