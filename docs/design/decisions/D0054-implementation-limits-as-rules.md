# D0054: Structural implementation limits are exact rejection rules; sizes are limited only by resources

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0053](D0053-resource-exhaustion.md) covers limits while a program runs. What about limits on the program itself,
which a checker must accept: how deeply constructs may nest, how many parameters a function may have, how long an
identifier or a file may be? These are **implementation limits**. Every violation of a rule is diagnosed
([D0018](D0018-diagnosis-and-rule-ids.md)), checking is claimed decidable
([D0023](D0023-claimed-meta-properties.md)), and the language is deterministic
([D0051](D0051-deterministic-sequential-language.md)), so ideally every implementation accepts the same programs. Yet
a recursive-descent parser in any of our implementation languages can overflow its own stack on extreme nesting.

## Options considered

The scenario for every option: a tool in the tooling domain ([D0002](D0002-purpose-and-domain.md)) generates a large
function (provisional syntax).

```
// generated.qbc, written by a tool
func f(p1: Int, p2: Int, /* … */ p300: Int) -> Int =     // 300 parameters
  ((((((((/* … nested 5,000 levels deep … */ p1 /* … */))))))));
// is this program accepted by every implementation?
```

### A. Guaranteed minimums; beyond them, an implementation may refuse

The specification lists minimum limits every implementation supports. Beyond them, an implementation may refuse the
program with a limit report, which is not a rejection.

```
minimums: 255 parameters, 1,000 nesting levels (illustrative)
300 parameters:  host accepts; qubecc says "limit exceeded: parameters"       (both conform)
```

- **Easy:** implementations choose their own data structures.
- **Hard:** whether a program builds depends on the implementation; generated code that works with one may fail with
  another; boundary tests differ per implementation.
- **Prior art:** C11 §5.2.4.1 lists, among others, 127 parameters in one function definition, 63 nesting levels of
  parenthesized expressions, and 127 nesting levels of blocks, and requires only that an implementation translate
  and execute at least one program containing every limit (verified,
  [R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)).

### B. No limits; only resource exhaustion

Every conforming program is accepted, subject only to available memory and time; running out while checking is the
compile-time exhaustion of D0053.

- **Easy:** the simplest specification; generated code never hits an arbitrary wall.
- **Hard:** every phase of every implementation must handle unbounded nesting without overflowing its own stack.
- **Prior art (recalled):** the Go specification states no such limits, while its compiler has internal ones.

### C. Exact limits as rejection rules

A few structural limits are ordinary rejection rules with rule IDs and generous values, chosen with the construct
they limit. Sizes, such as the length of a file or the number of declarations, are not limited, apart from
resource exhaustion.

```
nesting ≤ 256      [R-nesting-too-deep]    (illustrative name and value)
parameters ≤ 255   [R-params-too-many]     (illustrative name and value)
300 parameters and 5,000 levels: rejected by every implementation, with the same rule IDs
```

- **Easy:** every implementation accepts the same programs; the conformance suite tests the boundary exactly; the
  tool generating code learns of the limit the same way from every implementation.
- **Hard:** the values must be chosen well, since values that are too low break generated code; each limit is a rule.
- **For implementers:** recursion in the parser, checker, and back ends is bounded by the specification.
- **Prior art (recalled):** the Java class-file format fixes a method's parameter count and code size; Python's
  parser rejects nesting beyond a fixed depth.

| | A Minimums | B None | C Exact rules |
| --- | --- | --- | --- |
| Same programs accepted everywhere | no | yes, memory aside | yes, memory aside |
| Recursion inside implementations | bounded by their own limits | must be unbounded | bounded by the specification |
| Specification text | a table of minimums | none | a few rules |

Recommendation at the time: **C**, with generous values: it keeps "every implementation accepts the same programs"
without requiring every phase of every implementation to survive unlimited nesting, and extends D0051's determinism
to checking.

## Choice

**C.**
1. A structural limit (such as a depth of nesting, or a number of parameters, fields, or type arguments) is stated
   as a rejection rule with a rule ID, in the chapter that defines the construct it limits. Its value is fixed there.
2. Values are generous: chosen so that programs written by people never meet them and generated programs rarely do.
3. Nothing else limits the programs an implementation accepts. In particular, the length of a source file, the number
   of declarations, and the length of a literal are limited only by resource exhaustion (D0053).
4. A conforming implementation accepts every conforming program, unless it exhausts a resource while checking it.

## Rationale

Exact limits make acceptance deterministic, like everything else in the sequential language: the same program is
accepted or rejected, with the same rule IDs, by every implementation. They also give each implementation a known
bound on its own recursion, which matters because the self-hosted compiler checks itself. Keeping sizes unlimited
avoids arbitrary walls where no implementation needs one.

## Consequences

- **M02:** decides whether identifiers or literals need a limit (the default is none).
- **M03:** a limit on the nesting of expressions, blocks, and patterns.
- **M05 and M06:** limits on parameters, fields, variants, and type arguments, if any.
- **Every later chapter:** states its limits as rejection rules, or none.
- **Implementations:** may recurse on nesting up to the specified limits; above them they reject.

## Affected artifacts

- Spec: [§1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) (new)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
