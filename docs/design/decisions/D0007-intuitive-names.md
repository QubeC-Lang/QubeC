# D0007: Names are intuitive: widely recognized short forms, otherwise whole words

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

How are the names QubeC provides spelled: keywords, built-in and standard-library types, functions, and
constructors? This question arose while writing the dream snippet ([vision.md](../vision.md)), when Go's `chan`
appeared as a keyword. Short forms borrowed from the inspirations ([D0006](D0006-inspirations.md)) range from
universally understood (`Int`) to one language's coinage (`chan`, `eprintln`).

## Options considered

The scenario is the same for all: the dream snippet's types, the evaluator, and `main`, which sends results over a
channel and prints them (provisional syntax; excerpts).

### A. Short forms as the inspirations spell them

```
const MAX_FILES: Int = 64;
type Expr = Num(value: Int, at: Span) | Bin(op: Op, lhs: Expr, rhs: Expr, at: Span);
func eval(expr: Expr, env: Map[Str, Int]) -> Result[Int, CompileError] = …;
proc main() {
  let done = chan (Path, Result[Int, CompileError]);
  … eprintln("${f}: ${e}") …
}
```

- **Easy:** compact and familiar to people who know the source languages.
- **Hard:** readers must decode each language's coinages (`chan`, `eprintln`, `ok_or`, `fs`).

### B. Every name a whole word, with familiar acronyms allowed

```
constant MAXIMUM_FILES: Integer = 64;
type Expression = Number(value: Integer, at: Span)
                | Binary(operator: Operator, left: Expression, right: Expression, at: Span);
function evaluate(expression: Expression, environment: Map[String, Integer]) -> Result[Integer, CompileError] = …;
procedure main() {
  let results = channel (Path, Result[Integer, CompileError]);
  … print_error_line("${file}: ${error}") …
}
```

- **Easy:** nothing to decode.
- **Hard:** the most frequent words (`function`, `Integer`) become long, and widely known short forms gain nothing
  by being spelled out.
- **Prior art (recalled):** Ada (`procedure`, `function`, `constant`, `Integer`). COBOL is the cautionary tale, where
  full words grew into wordy phrasing (`ADD A TO B GIVING C`).

### C. Every name a whole word, with no exceptions

As B, but acronyms are spelled out too: `InputOutputError`, `ResourceLocator`.

- **Hard:** some names become less intuitive, not more.

### D. Intuitive names: widely recognized short forms are kept; coinages and cryptic truncations are spelled out

A short form is allowed when most programmers would read it correctly without context: it is shared by several
mainstream languages or by general CS vocabulary. A single language's coinage, or a truncation the reader has to
decode, is spelled out.

```
const MAX_FILES: Int = 64;
type Expr = Num(value: Int, at: Span) | Binary(op: Op, lhs: Expr, rhs: Expr, at: Span);
func eval(expr: Expr, env: Map[Str, Int]) -> Result[Int, CompileError] = …;
proc main() {
  let results = channel (Path, Result[Int, CompileError]);
  … stderr.println("${file}: ${err}") …
}
```

- **Easy:** familiar short forms stay short, and every name is still readable without context.
- **Hard:** "widely recognized" is a judgment call, argued case by case in M02 (keywords) and M14 (the standard
  library).
- **Prior art (verified, [R0001](../research/R0001-vision-prior-art.md)):** Swift's API Design Guidelines put clarity
  before brevity, and ask that an abbreviation's meaning be easily found by a web search.

Recommendation at the time: we first recommended B with familiar acronyms allowed, then refined it into D once we
agreed that widely recognized short forms such as `func`, `proc`, `const`, `Str`, and `Int` are intuitive. D was the
recommendation for the final question.

## Choice

**D.** Names that QubeC provides (keywords, built-in and standard-library names, constructors, and the compiler's
own suggestions) are **intuitive**:
- **Allowed:** a short form that is widely recognized, meaning shared by several mainstream languages or by general
  CS vocabulary, and familiar acronyms.
- **Spelled out:** a single language's coinage, or a truncation the reader must decode.

Classification from the dream snippet, recorded as precedent:

| Kept short (widely recognized) | Spelled out |
| --- | --- |
| `func`, `proc`, `const`, `Int`, `Str`, `Expr`, `Op`, `Num`, `Var`, `Add`/`Sub`/`Mul`/`Div`, `lhs`/`rhs`, `env`, `src`, `msg`, `MAX`, `args`, `println`, `stderr`, `IO`/`Io`, `URL`, `UTF8`, `ID` | `chan` → `channel` · `Bin` → `Binary` · `Err` → `Error` · `ok_or` → `or_error` · `map_err` → `map_error` · `eprintln` → `stderr.println` · `fs` → `file_system` · `col` → `column` |

User code is not governed by the language. M15's style guide may recommend the same test.

## Rationale

We want names a reader understands without having learned a particular source language. Length is not the goal:
a widely recognized short form is as intuitive as its expansion. What we exclude is the decoding step that coinages
and cryptic truncations impose.

## Consequences

- **M02:** every keyword passes the test. Likely candidates for spelling out are `mut` (as `mutable`) and `impl` (as
  `implement`); `fn` is borderline.
- **M14:** every standard-library name passes the test, which can produce mixed pairs (for example `Ok` with
  `Error`).
- We keep the inspirations' features but not necessarily their spelling.
- The spelling of `func` and `proc` is settled; whether the language has that pure/effectful split is not
  ([OQ-004](../open-questions.md#oq-004-what-does-functional-in-style-commit-qubec-to)).

> **Later note (T0003).** The pure/effectful split itself is now decided by [D0008](D0008-purity.md), which
> also resolves OQ-004. The spellings `mut`, `become`, and `dbg` are tested against this record in
> [OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg).

## Affected artifacts

- Spec: none yet (the keyword list in M02)
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md) (dream snippet)
