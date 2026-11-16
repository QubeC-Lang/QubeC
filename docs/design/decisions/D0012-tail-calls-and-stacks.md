# D0012: Explicit, checked tail calls; growable stacks

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

Functional code iterates by recursion. What does QubeC promise about it? Two issues: whether calls in **tail
position** (the last thing a function does) are guaranteed to run in constant stack, and whether deep non-tail
recursion (for example over a deeply nested AST) is safe. The mechanism (syntax, limits, reports) belongs to M01 and
M03; this record decides the commitment.

## Options considered

The scenario is the same for all: a two-state lexer written as mutually recursive functions over a long input.
Provisional syntax.

### A. Explicit, checked tail calls; growable stacks

A tail call is marked at the call site (placeholder `become f(x)`: "this function becomes that call", replacing its
own frame instead of waiting for the callee's answer). The compiler checks the mark is in tail position; the call
then runs in constant stack, for any callee. Unmarked calls carry no guarantee, but stacks grow, so ordinary deep
recursion is safe up to a large cap.

```
func in_word(cs: List[Char], i: Int, words: Int) -> Int =
  if i == cs.len() then words + 1
  else if cs[i] == ' ' then become in_space(cs, i + 1, words + 1)   // constant stack
  else become in_word(cs, i + 1, words);

func bad(n: Int) -> Int = 1 + become bad(n - 1);   // error: not in tail position
```

- **Easy:** visible intent; a misplaced mark is a compile error; back ends pay only at marked sites.
- **Hard:** one more keyword; forgetting it means no guarantee.
- **Prior art:** Rust reserves `become` for explicit tail calls, proposed in RFC 3407 and available only as an
  incomplete unstable feature (verified, [R0002](../research/R0002-purity-and-tail-calls.md)). Clang's
  `[[clang::musttail]]`; Scala's `@tailrec` and Kotlin's `tailrec` check self-recursion only (recalled).

### B. Every tail call guaranteed, implicitly

Any call in tail position reuses the frame, without a mark.

```
else if cs[i] == ' ' then in_space(cs, i + 1, words + 1)     // guaranteed, invisibly
```

- **Easy:** the most natural for functional code.
- **Hard:** whether a call is a tail call is invisible, and a small edit silently loses the guarantee; every back end
  must support general tail calls (trampolines or `musttail` in C, the Wasm tail-call extension).
- **Prior art (recalled):** Scheme (required), Lua, Erlang; OCaml in practice.

### C. No guarantee; loops are the iteration tool

```
func count_words(cs: List[Char]) -> Int = { let mut words = 0; …; for c in cs { … }; words };
```

- **Easy:** the simplest to implement; complete stack traces.
- **Hard:** state machines must become loops; deep recursion risks overflow.
- **Prior art (recalled):** Python, Java, Go, stable Rust.

Recommendation at the time: **A**, for Predictability, local back-end cost, and because the growable stacks that
lightweight tasks need (OQ-001) make the second half nearly free.

## Choice

**A.**
- A call marked as a tail call MUST be in tail position, or the program is rejected. A marked call runs in constant
  stack space, whatever the callee (direct, mutual, or through a function value).
- Unmarked calls carry no constant-stack guarantee.
- Stacks are growable, so deep recursion is limited by a large cap rather than a small fixed stack. The cap, the
  guaranteed minimum depth, and what happens when it is exceeded are decided in M01.
- The marker's spelling is open; `become` is a placeholder
  ([OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)).

## Rationale

Recursion stays a first-class way to iterate, without invisible rules: the guarantee is exactly where it is written,
and the compiler checks it.

## Consequences

- **M01:** growable stacks and their cap; marked tail calls in every back end.
- **M03:** the marker's syntax and the definition of tail position.
- **M10:** lightweight tasks share the growable-stack machinery.
- **M13:** the dynamic semantics states the constant-space property for marked calls.

## Affected artifacts

- Spec: none yet (M01, M03)
- Grammar rules: none
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md) (combined sample, `skip_spaces`)
