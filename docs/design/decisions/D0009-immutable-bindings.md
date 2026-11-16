# D0009: Bindings are immutable by default; mutable variables are local; no global variables

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

A **binding** is a name for a value. Can a name be reassigned, how visible is it when it can, and may variables
exist at top level? This is separate from purity: a `func` may already use local mutable variables
([D0008](D0008-purity.md)), because nobody outside can observe them.

## Options considered

The scenario is the same for all: sum the squares of the even numbers in a list, and keep a global call counter
(the tricky case). Provisional syntax.

### A. Immutable by default; opt-in mutable locals; constants only at top level

`let x = e` binds once; `let mut x = e` may be reassigned. Mutable variables are local only. At top level there are
only constants, `const NAME: T = expr`, evaluated at compile time.

```
const LIMIT: Int = 1000;

func sum_even_squares(xs: List[Int]) -> Int = {
  let mut total = 0;                       // visible opt-in; local, so the func stays pure
  for x in xs { if x % 2 == 0 { total = total + x * x; } }
  total
};

let mut CALLS = 0;                         // error: no global variables
```

- **Easy:** a plain `let` never changes; no initialization order for globals; the explicit layer keeps its loops.
- **Hard:** a program-wide counter or cache needs a dedicated, safe mechanism (M07 or M10).
- **For implementers:** mutable locals are a store confined to the frame.
- **Prior art (recalled):** Rust (`let` / `let mut`; `static mut` needs `unsafe`); Swift (`let` / `var`).

### B. Two equal keywords, no preferred default

As in Kotlin and Scala: `val` and `var`, equally short, both allowed at top level.

```
val LIMIT = 1000
var calls = 0                              // a global variable: allowed
func sum_even_squares(xs: List[Int]) -> Int = { var total = 0; …; total }
```

- **Easy:** familiar; globals available.
- **Hard:** nothing nudges toward immutability; globals bring initialization order and data races (OQ-001).
- **Prior art (recalled):** Kotlin and Scala style guides recommend `val`; linters enforce it.

### C. No mutable variables at all

As in Elm: every name is bound once; accumulation uses folds or recursion.

```
func sum_even_squares(xs: List[Int]) -> Int =
  xs.filter(|x| x % 2 == 0).map(|x| x * x).fold(0, |acc, s| acc + s);
```

- **Easy:** the simplest rules.
- **Hard:** the explicit layer loses ordinary loops, against [D0003](D0003-target-users.md) and
  [D0004](D0004-ranked-design-values.md); worklist algorithms get awkward.
- **Prior art (recalled):** Elm; Haskell needs `ST` or `IORef` to mutate.

Recommendation at the time: **A**. It is functional in style without crippling the explicit layer, and having no
globals helps race freedom (OQ-001) and the module design (M09).

## Choice

**A.**

| Form | Meaning |
| --- | --- |
| `let x = e`, `let x: T = e` | An immutable local binding. |
| `let mut x = e` | A mutable local variable, allowed in `func` and `proc` bodies (local mutation is not an effect, D0008). |
| `const NAME: T = expr` | A constant. The type is required. It is evaluated at compile time, and `expr` may call only `func`s. Allowed at top level and locally. |

- There are no top-level `let` or `let mut` declarations: a program has global constants but no global variables.
- Any future global mutable state needs an explicit, safe mechanism from M07 or M10.
- The spelling of `mut` is open
  ([OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)).

## Rationale

We chose A for the reasons in the recommendation: immutability is the default and mutation is a visible, local
opt-in, which matches Predictability and keeps shared mutable state out of the language until a safe mechanism
exists.

## Consequences

- **M02:** `let`, `const`, and the mutable-variable keyword are reserved.
- **M04:** scoping of `let`, `let mut`, and local `const`; shadowing is still open.
- **M09:** no global initialization order to specify.
- **M10:** no global variables to race on.
- **M11:** compile-time evaluation of constants, which call only `func`s.

## Affected artifacts

- Spec: none yet (declarations in M04)
- Grammar rules: none yet (a provisional sketch: `LetStmt ::= 'let' 'mut'? Pattern (':' Type)? '=' Expr`,
  `ConstDecl ::= 'const' Ident ':' Type '=' Expr`)
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md)
