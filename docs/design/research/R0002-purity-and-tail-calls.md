# R0002: Prior art for purity, local mutation, and tail calls

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0003 |
| Used by | D0008, D0011, D0012 |

## Question

What do the languages cited for purity of functions, mutation of locally created values, and explicit tail calls
actually specify?

## Sources

1. The D Language Specification, "Functions", section "Pure Functions",
   https://dlang.org/spec/function.html#pure-functions (fetched 2026-11-16).
2. Rust standard library documentation, keyword `become`, https://doc.rust-lang.org/std/keyword.become.html.
3. Rust RFC 3407, "Explicit Tail Calls", https://github.com/rust-lang/rfcs/pull/3407; the unstable book entry
   `explicit_tail_calls`, https://doc.rust-lang.org/unstable-book/language-features/explicit-tail-calls.html.
4. Rust RFC 601, "Replace `be` with `become`", https://rust-lang.github.io/rfcs/0601-replace-be-with-become.html.

## Findings

- **Verified [1]:** pure functions may "modify the local state of the function" and may not directly access global
  or static mutable state; they may call only pure functions.
- **Verified [1]:** a *weakly* pure function has parameters with mutable indirections and may modify program state
  through them; a *strongly* pure function "cannot modify any program state external to the function". A strongly
  pure function may return newly allocated memory ("pure factory functions"). D0008 forbids weak purity; D0011
  corresponds to strong purity with local allocation.
- **Verified [2, 4]:** `become` is a reserved keyword in Rust, reserved for guaranteed tail calls; it replaced the
  earlier reserved `be`.
- **Verified [3]:** explicit tail calls are proposed in RFC 3407 and exist only as the unstable, incomplete
  `explicit_tail_calls` feature.
- **Recalled:** Nim's `func` is a procedure without side effects but may still mutate through parameters.
- **Recalled:** Haskell's `runST` uses a rank-2 type to keep local mutable state from escaping.
- **Recalled:** Koka has a local state effect discharged at its boundary.
- **Recalled:** Clang provides `[[clang::musttail]]`; Scala's `@tailrec` and Kotlin's `tailrec` check
  self-recursion only.

## Conclusions

D0008's observable-effect purity and D0011's local mutation match D's strong purity. Explicit, checked tail calls
(D0012) have a direct precedent in Rust's reserved `become`, which is not yet stable there.
