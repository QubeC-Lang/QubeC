# D0064: Every constant is evaluated exactly once, used or not, in an order that is not observable

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

Compile-time evaluation is a phase between checking and the run ([D0063](D0063-program-phases.md)). Which constants
does it evaluate, and how often? The answer decides whether acceptance can depend on what a program uses.

## Options considered

The scenario for every option, with failing constants that nothing uses (provisional syntax):

```
const MAX_TOKEN: Int = 256;
const KEYWORDS: ImmutableList[Str] = ["func", "proc", "let", "const"];
const SPARE: Int = MAX_TOKEN / 0;                 // panics if evaluated; nothing uses it

func is_keyword(s: Str) -> Bool = KEYWORDS.contains(s);
func unused_helper() -> Int = {
  const LIMIT: Int = [1, 2, 3][7];                // a local constant in a function nobody calls
  LIMIT
};
proc main() { println(is_keyword("proc").to_str()); }
```

### A. Every constant, exactly once

Every constant declared in the program is evaluated, whether or not anything uses it, including local constants in
callables that are never called. `SPARE` and `LIMIT` both fail.

- **Easy:** acceptance never depends on use; a library's author finds its broken constants without writing a user;
  the rule is trivially the same everywhere.
- **Hard:** an unused, expensive table still costs compile time.
- **Locks in:** "the program compiled" implies "every constant has a value".

### B. Only reachable constants, once each

A constant is evaluated only if it can be reached from `main` through the bodies of reachable callables and
constants. `SPARE` and `LIMIT` are never evaluated, and the program runs.

- **Easy:** no time spent on unused constants.
- **Hard:** adding a call far away can make the build fail; a library has no `main`; "reachable" must be defined
  identically through closures, function values, and later M06's trait dispatch.

Evaluating a constant at each use was also considered. Its initializer is pure, so repeating it gives the same value;
the only differences would be compile time and repeated `dbg` output, so it is not a separate option. A fresh copy
per use is a question about values ([D0067](D0067-constant-values-without-mutable-state.md)).

- **Prior art:** Rust evaluates and rejects an unused failing constant (error E0080), and Go rejects an unused
  `1 / Z` constant (both verified by running them, [R0010](../research/R0010-compile-time-evaluation-prior-art-and-pilots.md));
  C++ requires every `constexpr` initializer to be a constant expression (recalled); Zig analyzes only referenced
  declarations, and its users report broken code that compiled until it was used (recalled).

Recommendation at the time: **A**, the rule users can predict and the one later tasks can build on.

## Choice

**A.**
1. In the compile-time evaluation phase, every constant declared in the program is evaluated, whether or not
   anything refers to it, including local constants in callables that are never called.
2. Each constant is evaluated exactly once, and every use refers to that one value.
3. The order in which an implementation evaluates constants is not observable: the values, acceptance, and step
   counts ([D0070](D0070-compile-time-step-floor-and-cap.md)) are the same in every order. Only which of several
   rejections is reported first may differ, as [spec §1.2.2](../../spec/01-introduction.md#122-reporting) allows.

## Rationale

Acceptance should never depend on which constants a program happens to use, a library's author should find its
broken constants, and the rule must be identical across the host implementation, `qubecc`, and the reference. Every
constant once is the simplest rule with all three properties, and it is what makes "the program compiled" mean that
every constant has a value.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 4.
- **T0013:** a unit's constants are evaluated when it is compiled; an artifact may store their values so that
  dependent units do not evaluate them again.
- **M04:** local constants are scoped like other local declarations, but they are evaluated in this phase, not when
  their block runs.
- **D0013's REPL:** a constant entered in the REPL is evaluated when it is entered.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 4
- Grammar rules: none
- Formal rules: none yet ([dynamic.md](../../spec/formal/dynamic.md) note)
- Examples / tour: [vision.md](../vision.md)
