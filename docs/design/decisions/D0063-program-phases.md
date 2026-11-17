# D0063: A program is checked, then its constants are evaluated, then it runs; types do not mention constant values

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

Constants are evaluated at compile time ([D0009](D0009-immutable-bindings.md)), and any `func` may run there
([D0008](D0008-purity.md)). Where does that evaluation sit relative to type checking, and may a type mention a
constant's value, as a fixed-size array `[Byte; MAX]` would? The answer shapes the typing judgment, D0027's reference
checker, and what M05, M06, and M12 may later offer. A **phase** is a stage that processing goes through in a fixed
order.

## Options considered

The scenario for every option is a lexer's tables (provisional syntax):

```
const MAX_TOKEN: Int = 256;
const KEYWORDS: ImmutableList[Str] = ["func", "proc", "let", "const"];

func is_keyword(s: Str) -> Bool = KEYWORDS.contains(s);
type TokenBuf = [Byte; MAX_TOKEN];        // a type that mentions a constant's value

proc main() { println(is_keyword("proc").to_str()); }
```

### A. Three strict phases; types never depend on constant values

The whole program is checked; then every constant is evaluated; then `main` runs. Checking never evaluates anything,
and no type form holds a value, so `TokenBuf` cannot be written.

- **Easy:** the typing judgment contains no evaluation; type equality is syntactic; D0027's checker stays
  syntax-directed.
- **Hard:** no length-typed arrays or integer generic parameters, ever, unless a later decision supersedes this one.
- **Locks in:** a closed door.

### B. Three phases now, with a guarded door for integer constants in types

As A today. In addition, M05, M06, or M12 may admit integer constants in types, but only if the checker uses the same
compile-time evaluation (no separate type-level language), cycles through types are rejected, type equality is the
same in every implementation, and only constants appear in types, never run-time values (NG-7,
[D0005](D0005-non-goals.md)).

- **Easy:** as A now; programs written today stay valid if the door opens.
- **Hard:** if it opens, checking and evaluation interleave for those types, within the rules above.
- **Locks in:** only the guard rules.

### C. Interleaved: checking evaluates constants on demand

When the checker meets `[Byte; MAX_TOKEN]`, it evaluates `MAX_TOKEN` there and then; evaluation and checking proceed
declaration by declaration.

- **Easy:** sized arrays and integer generic parameters from the start.
- **Hard:** every checker, the Lean reference checker included, embeds the evaluator; type equality may need
  evaluation (`[Byte; 2*128]` against `[Byte; 256]`), so checking is only as decidable as evaluation is bounded; it
  designs type-level computation before M05 designs types.
- **Prior art (recalled):** Zig's `comptime` is interleaved; Rust and C++ evaluate constants during checking, and
  Rust's const generics took years to stabilize even in part; Go uses constants in types only as array lengths.

Recommendation at the time: **B**, which costs nothing now, keeps the reference checker simple, and leaves the
explicit layer and M12 a principled route to sized arrays.

## Choice

**B.**
1. **Phases.** Processing a program has three phases, in this order:
   1. **checking:** the whole program is checked against every static rule;
   2. **compile-time evaluation:** every constant is evaluated ([D0064](D0064-every-constant-once.md));
   3. **the run:** the entry point runs ([D0057](D0057-forms-of-main.md)).

   If the first two phases reject the program, no part of it runs.
2. **Types do not mention constant values.** The typing judgment contains no evaluation.
3. **The guarded door.** M05, M06, or M12 may admit integer constants in types (such as sized arrays or integer
   generic parameters) only under these rules:
   - the checker uses the same compile-time evaluation, not a separate type-level language;
   - cycles, including cycles through types, are rejected;
   - whether two types are equal is the same in every implementation;
   - only constants appear in types, never run-time values (NG-7).
4. **One semantics.** Compile-time evaluation follows the same dynamic semantics as the run. A constant's value is the
   value its initializer would have if it were evaluated at run time, with the same results, panics, and evaluation
   order ([D0049](D0049-precise-panics.md), [D0051](D0051-deterministic-sequential-language.md)).

## Rationale

The need for length-typed arrays is real, but it belongs to the milestones that define types, generics, and layout.
Deciding it now would either force their hand or design type equality before types exist. Fixing the guard rules now
means that programs written today stay valid if those milestones open the door. One dynamic semantics for both phases
follows from determinism: there is no room for a second meaning of the same expression, and it gives one evaluator
design and one set of formal rules.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) names the phases.
- **Formal:** the typing judgment contains no evaluation; constant evaluation is a separate relation that uses the
  dynamic rules, between checking and the run ([dynamic.md](../../spec/formal/dynamic.md)).
- **M05, M06, M12:** may open the door under choice 3.
- **M11:** macros, reflection, and attributes build on this phase structure.
- **I1:** the host front end checks, then evaluates constants with its interpreter, and hands their values on to the
  back end.
- **I3:** a QubeC program cannot run code it generates ([D0043](D0043-native-code-after-v1.md)), so `qubecc` must
  contain an evaluator for the pure language written in QubeC.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rules 1–3
- Grammar rules: none
- Formal rules: none yet ([static.md](../../spec/formal/static.md), [dynamic.md](../../spec/formal/dynamic.md) notes)
- Examples / tour: [vision.md](../vision.md)
