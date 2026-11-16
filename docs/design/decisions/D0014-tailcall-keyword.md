# D0014: Explicit tail calls are written `tailcall f(x)`

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — (refines [D0012](D0012-tail-calls-and-stacks.md), which left the spelling open) |
| Milestone / task | M00 / T0008 |

## Question

[D0012](D0012-tail-calls-and-stacks.md) decided that tail calls are marked at the call site, checked to be in tail
position, and run in constant stack for any callee, with `become` as a placeholder spelling. How is the mark
spelled? The spelling must pass [D0007](D0007-intuitive-names.md): a reader understands it without knowing a
particular source language. This settles the `become` item of
[OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg).

## Options considered

The scenario is the same for all: a two-state lexer written as mutually recursive functions, and a misplaced mark.
Provisional syntax.

### A. `tailcall f(x)`, a call-site keyword named after the concept

```
func in_word(cs: List[Char], i: Int, w: Int) -> Int =
  if i == cs.len() then w + 1
  else if cs[i] == ' ' then tailcall in_space(cs, i + 1, w + 1)
  else tailcall in_word(cs, i + 1, w);
func bad(n: Int) -> Int = 1 + tailcall bad(n - 1);    // error: not in tail position
```

- **Easy:** "tail call" is standard CS vocabulary, and the keyword names it directly; it is unlikely to collide with
  user identifiers; it works in expression-bodied functions.
- **Hard:** a longish keyword, acceptable for a construct that is rare by design.
- **Prior art:** Tcl 8.6's `tailcall` command (recalled); Scala's `TailCalls` library uses `tailcall(…)` for the same
  idea, implemented by trampolining (verified, [R0002](../research/R0002-purity-and-tail-calls.md)).

### B. `become f(x)`, the placeholder

"This function becomes that call."

- **Easy:** short; precedent in Rust, which reserves `become` for this (verified, R0002).
- **Hard:** the word does not explain itself; a reader has to be told what it means, which fails D0007's test.

### C. `tail f(x)`

```
  else if cs[i] == ' ' then tail in_space(cs, i + 1, w + 1)
let (head, tail) = xs.split_first();                 // clash: `tail` is reserved
```

- **Easy:** the shortest.
- **Hard:** `tail` is one of the most common identifiers in functional code; reserving it breaks those names, and a
  contextual keyword complicates lexing and parsing (M02, M03).

### D. `return tail f(x)`, a modifier on `return`

```
proc in_word(cs: List[Char], i: Int, w: Int) -> Int {
  if i == cs.len() { return w + 1; }
  if cs[i] == ' ' { return tail in_space(cs, i + 1, w + 1); }
  return tail in_word(cs, i + 1, w);
}
```

- **Easy:** explains itself; familiar from Clang's `[[clang::musttail]] return f(x);` (recalled).
- **Hard:** depends on whether M03 has a `return`, and on its role in expression-bodied functions.

### E. A function-level marker (Scala's `@tailrec`, Kotlin's `tailrec`)

The function is marked, and the compiler verifies that it can be compiled into a loop, reporting an error otherwise
(verified for Scala, R0002).

```scala
@tailrec def skipSpaces(cs: Array[Char], i: Int): Int =
  if (i < cs.length && cs(i) == ' ') skipSpaces(cs, i + 1) else i
```

- **Easy:** one mark per function; a cheap local loop rewrite.
- **Hard:** it covers self-recursion only, not mutual recursion or calls through function values, so on its own it
  would weaken D0012's guarantee; alongside a call-site mark it is redundant.

**How each works in memory**, for a loop of *n* iterations written as recursion:

| | Stack per iteration | Heap per iteration | Callees covered | Requires |
| --- | --- | --- | --- | --- |
| Ordinary call | one frame (the stack grows) | none | — | growable stacks for depth |
| Call-site mark (A–D) as a jump | none (the frame is freed or reused before the jump) | none | any | a jump-capable calling convention; cleanup before the jump; no live references into the frame |
| Function-level mark (E) as a loop | none | none | self only | a local rewrite |
| Trampoline | none | one small object | any | heap allocation and collection; wrapped return types |

Recommendation at the time: **A**. It passes D0007 without argument, works whatever M03 decides about `return`, and
does not reserve a common name. A function-level marker adds nothing a call-site mark does not already guarantee.

## Choice

**A.** An explicit tail call is written `tailcall f(args)`. No function-level tail-recursion marker is added.

- `tailcall` is a reserved keyword.
- D0012's guarantee is unchanged: a `tailcall` MUST be in tail position, and it runs in constant stack space for any
  callee.
- The guarantee is semantic; the mechanism is the implementation's. An implementation MAY realize a `tailcall` as a
  jump, as a loop for self-calls, or by trampolining on a back end that cannot jump between functions, provided the
  constant-space property holds.

## Rationale

The keyword names the concept it marks, so it explains itself, and it covers every callee at no heap cost on a
back end that can jump. A per-function marker would only restate, per function, what each `tailcall` already
guarantees.

## Consequences

- **M02:** `tailcall` is reserved.
- **M03:** defines tail position, and how `tailcall` interacts with blocks and conditionals.
- **M07:** a `tailcall` is rejected while any reference into the current frame is live (for example an
  explicit-layer borrow of a local passed to the callee), because the frame is released before the jump.
- **M01, M07:** cleanup that would run after the call (reference-count decrements, destructors) runs before the jump;
  otherwise the call is not in tail position.
- **M01:** every back end supports constant-space `tailcall`, by jump, loop rewrite, or trampoline.

## Affected artifacts

- Spec: none yet (M01, M03)
- Grammar rules: none yet (a provisional sketch: `TailCall ::= 'tailcall' CallExpr`)
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md) (combined sample, `skip_spaces`)
