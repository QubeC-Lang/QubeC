# D0019: Extensions only with an opt-in in the source file

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

May an implementation accept programs the specification rejects? An **extension** is an implementation-specific
feature, such as new syntax, a relaxed rule, or an extra built-in. Under [D0018](D0018-diagnosis-and-rule-ids.md),
every violation is rejected and reported, so an extension is by definition accepting something the specification
rejects. Implementations want extensions anyway, including our own, to try an unfinished feature before it is
decided.

## Options considered

The scenario for every option: an experimental, undecided pipe operator `|>` (hypothetical).

```
func total(xs: List[Int]) -> Int = xs |> sum;    // not in the specification
```

### A. No extensions

A conforming implementation rejects every program the specification rejects, in every mode. An experimental
feature makes the compiler non-conforming while enabled, and the specification says nothing about it.

- **Easy:** the strictest meaning of "conforming"; no dialects.
- **Hard:** experiments live entirely outside the specification, with no defined way to mark them.
- **Prior art (recalled):** strict modes such as `gcc -pedantic-errors`.

### B. Opt-in in the source file

A program uses an extension only by naming it in its source (provisional syntax):

```
use feature pipe_operator;
func total(xs: List[Int]) -> Int = xs |> sum;
```

Without the marker, the implementation conforms exactly. With it, the file is explicitly non-portable, and an
implementation that does not know the feature rejects the marker itself with a rule ID.

- **Easy:** a file's meaning is visible in the file (NG-11, [D0005](D0005-non-goals.md)); a clean path for preview
  features.
- **Hard:** one more mechanism, which needs grammar; extensions may become de facto standards.
- **Prior art (recalled):** Rust's `#![feature(…)]`, allowed on nightly builds only; GHC's `{-# LANGUAGE … #-}`
  pragmas, through which "GHC Haskell" drifted far from Haskell 2010.

### C. Opt-in by compiler flag

As B, but enabled by a flag (`qubec run --enable pipe_operator main.qbc`).

- **Easy:** no syntax; source files stay clean.
- **Hard:** the same file means different things depending on how it is built.
- **Prior art (recalled):** Java's `--enable-preview`, needed at both compile and run time.

### D. Accept after a diagnostic

An implementation may accept a rejected program after reporting the violation, even as a warning.

- **Easy:** maximum flexibility.
- **Hard:** "compiled with warnings" can mean "not QubeC"; D0018's guarantee weakens.
- **Prior art:** C++, whose implementations may compile and execute ill-formed programs that use extensions once
  they have diagnosed them (verified, [R0003](../research/R0003-spec-conventions-prior-art.md)).

| | A None | B Source opt-in | C Flag opt-in | D Diagnose and accept |
| --- | --- | --- | --- | --- |
| "Compiled" means valid QubeC | yes | yes, unless the marker is present | depends on flags | no |
| Meaning visible in the source | yes | yes | no | partly |
| Room for preview features | none in the specification | yes | yes | yes |

Recommendation at the time: **B**, which keeps D0018's guarantee for every unmarked program, keeps meaning in the
source, and gives implementations a legitimate way to preview features.

## Choice

**B.**
1. A conforming implementation MAY provide **extensions**. An extension takes effect only in a source file that
   names it with an **extension opt-in** (marker syntax open,
   [OQ-006](../open-questions.md#oq-006-how-is-an-extension-opt-in-written-and-where-may-it-appear)).
2. In a file with no extension opt-in, the implementation conforms exactly: everything in D0018 applies unchanged.
3. An extension MUST NOT change the meaning of a program that does not opt into it.
4. An opt-in that names an extension the implementation does not provide is itself a rejection, with a rule ID.
5. A program that opts into an extension is not a conforming program; the specification gives it no meaning beyond
   the opt-in rule itself.

## Rationale

The meaning of a QubeC file should be visible in the file (NG-11), so a flag-only switch is out. Accepting after a
diagnostic would erode what D0018 guarantees. Forbidding extensions outright would leave our own preview work with
no defined status. A source opt-in keeps the guarantee for every ordinary program and makes every departure
explicit.

## Consequences

- **Spec §1.2.3** states the rule.
- **OQ-006 (new):** the marker's syntax, its placement (per file or per unit), and how extension names are spelled.
  It is settled in M09 (units and the build model) or M11 (attributes), whichever comes first.
- **Our implementation:** may preview candidate syntax for open questions as named extensions.
- **The fragmentation risk** is accepted: an extension that proves itself is folded into the specification through a
  decision, and the opt-in is then retired.

## Affected artifacts

- Spec: [§1.2.3](../../spec/01-introduction.md#123-extensions)
- Grammar rules: none yet (OQ-006)
- Formal rules: none
- Examples / tour: none
