# D0049: Panics are precise, and no engine, profile, or optimization changes observable behavior

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

With observable behavior defined as a trace and an outcome ([D0048](D0048-trace-and-outcome.md)), a panic is an
outcome. Which panic does a run end with, and where in its trace? And may a **build profile** (a named set of build
settings, such as "debug" or "release") change which checks are made? Panics are defined behavior, not rejections
([§1.2.1](../../spec/01-introduction.md#121-diagnosis-of-violations)), and
[D0004](D0004-ranked-design-values.md) illustrates overflow as checked by default and wrapping only where written.

## Options considered

The scenario for every option (provisional syntax; `Int` overflow belongs to M05, `print` to M14):

```
func scale(x: Int) -> Int = x * 1_000_000_000_000      // overflows for large x
func both(a: Int, b: Int) -> Int = scale(a) + scale(b)

proc main() {
  print("start");
  let unused = scale(huge);          // pure, never used, overflows
  let v = both(huge, huge);          // both calls overflow
  print("v = " + v.to_string());
}
```

### A. Precise panics, one meaning in every profile

A run panics at the first failing operation that the defined evaluation order reaches; its trace holds exactly the
events before that point. A profile or an optimizer may change only what is not observable (speed, size, debug
information, whether `dbg` prints). No build setting removes or weakens a check; wrapping or unchecked operations
are written in the program.

```
every engine, every profile:   out "start"; panic (overflow) at unused's `*`
an optimizer may drop `unused` only if it proves the call cannot panic or diverge
```

- **Easy:** differential testing compares traces exactly, panics included; no bug appears only in release builds.
- **Hard:** checks stay in every build; the optimizer cannot freely hoist, merge, or drop pure code that might panic.
- **For implementers:** every back end keeps every check, in order; the semantics is one deterministic function.
- **Prior art:** WebAssembly traps are deterministic across engines; its list of nondeterminism does not include them
  (verified, [R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)). Java's exceptions are precise
  in both its interpreter and its JIT (recalled).

### B. Imprecise panics in pure code

Runs that do not panic are identical everywhere. When a pure expression could fail at several places, an
implementation may report any one of them, and it may drop unused pure work together with its panic.

```
engine 1:  out "start"; panic at unused
engine 2:  out "start"; panic in both(), at either call       (both conform)
```

- **Easy:** the optimizer may reorder and eliminate pure code freely.
- **Hard:** panic locations depend on the engine; tests can check only that a run panicked; D0023's determinism
  weakens to "one outcome up to the choice of panic".
- **Prior art:** GHC's imprecise exceptions, where an exceptional value contains a set of exceptions and the choice
  among them is made in `IO` (verified, Peyton Jones et al., PLDI 1999, R0008).

### C. Profiles may change a listed set of checks

A release profile may replace listed checks, such as overflow, with defined fallbacks such as two's-complement
wrapping. Behavior is never undefined, but it depends on the profile.

```
debug:    out "start"; panic at unused
release:  out "start"; out "v = <a wrapped number>"; return, status 0
```

- **Easy:** arithmetic in release builds runs at full speed.
- **Hard:** one program gives different answers per profile, a silent wrong result in release builds (NG-10); every
  engine implements both behaviors; tests need an expected result per profile.
- **Prior art:** the Rust Reference requires overflow checks that panic when debug assertions are enabled, and lets
  other builds panic or wrap "at the implementation's discretion" (verified, R0008).

| | A Precise | B Imprecise | C Profile-dependent |
| --- | --- | --- | --- |
| Same trace across engines and profiles | always | only without panics | per profile |
| D0023's determinism | as claimed | weakened | parameterized by profile |
| Optimizer freedom | least | most | medium |
| Release-only bugs | none | panic site only | wrong results |

Recommendation at the time: **A**, the only option under which D0023's determinism and D0045's equivalence hold as
stated, in line with D0004's ranking of Safety and Predictability above Performance.

## Choice

**A.**
1. **Precise panics.** A run panics at the first failing operation that the defined evaluation order reaches. Its
   trace consists of exactly the events before that point.
2. **One meaning.** No engine, implementation, build profile, or optimization changes a program's observable
   behavior ([D0048](D0048-trace-and-outcome.md)). Only what is not observable may change: speed, size, debug
   information, and `dbg` output.
3. **Checks are never configured away.** No build setting removes or weakens a check. An operation that wraps, or
   that skips a check, is written as such in the program.

## Rationale

Precise panics keep D0023's determinism a theorem without qualification and make D0045's equivalence testable for
failing runs too, where users look hardest. Predictability ranks above Performance in the default layer (D0004),
and the explicit layer can still offer fast operations, visibly, where they are written.

## Consequences

- **M03:** fixes the evaluation order that "first failing operation" refers to.
- **M05:** overflow is checked; wrapping and unchecked arithmetic are separately named operations.
- **M07:** an unchecked escape hatch, if any, is written in the program, never selected by a build setting.
- **M08:** panics are defined as precise.
- **I2 and later back ends:** keep every check and its order; an optimization that drops pure code must first prove
  that the code cannot panic or diverge.
- **M15:** build profiles may exist, but they differ only in what is not observable.

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (new)
- Grammar rules: none
- Formal rules: none yet (M03)
- Examples / tour: none
