# D0067: A constant may have any type, but its value contains no mutable state

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

The unqualified `List`, `Map`, and `Set` are mutable ([D0010](D0010-mutable-default-collections.md)), a pure function
may build a mutable value and return it ([D0011](D0011-local-mutation-in-functions.md)), and a program has constants but
no global variables ([D0009](D0009-immutable-bindings.md)). A constant holding a mutable list would be a global
variable in disguise, and a `func` that reads it would see what a `proc` last wrote into it. What may a constant's
value be?

## Options considered

The scenario for every option (provisional syntax):

```
const KEYWORDS: List[Str] = ["func", "proc", "let", "const"];     // List is mutable
const TABLE: ImmutableList[Str] = ImmutableList.of(["func", "proc"]);
const CLASSIFY: (Char) -> Kind = |c| if c.is_digit() { Digit } else { Other };   // a function value

func is_keyword(s: Str) -> Bool = KEYWORDS.contains(s);
proc main() {
  KEYWORDS.push("loop");                    // what happens?
  println(is_keyword("loop").to_str());
}
```

Every option allows any type otherwise, including function values such as `CLASSIFY`, so tables of behavior work.

### A. Any type; each use is a fresh copy

A constant behaves like a literal written at each use. `KEYWORDS.push("loop")` pushes onto a temporary, so the
program prints `false`; directly mutating a constant would be rejected as a mistake.

- **Easy:** any type, no new concept; `let mut ks = KEYWORDS` gives a private copy.
- **Hard:** hidden copies, for example of the whole list on every `KEYWORDS.contains(s)` in a loop, unless the
  implementation proves the use read-only or copies lazily; nested values copy deeply.
- **Prior art:** in Rust each use of a `const` creates a new temporary; mutating one compiles with a warning and
  changes nothing (verified by running it, [R0010](../research/R0010-compile-time-evaluation-prior-art-and-pilots.md)).

### B. Any type; one value, frozen at run time

Mutating a frozen object panics. `KEYWORDS.push("loop")` panics.

- **Easy:** no copies.
- **Hard:** the type says mutable but the value is not; a `func` that receives `KEYWORDS` and pushes to it type-checks
  and then panics; every mutation of every object checks a flag.
- **Prior art (recalled):** Ruby's `freeze`, JavaScript's `Object.freeze`.

### C. Any type, but no mutable state

A constant's value is built only from immutable data: scalars, strings, immutable collections, records and variants
of those, and function values that capture no mutable object. `const KEYWORDS: List[Str]` is rejected; with
`ImmutableList[Str]`, `push` does not exist (a type error). The one value is shared, never copied, which cannot be
observed because nothing can change it and no identity is observable
([D0051](D0051-deterministic-sequential-language.md)).

- **Easy:** no global mutable state, visible in the type; no hidden copies; the same "deeply immutable" property is
  likely what M10 needs to share values between tasks
  ([OQ-001](../open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)).
- **Hard:** constant tables spell an immutable collection type; the check needs a precise notion of "contains no
  mutable object", including closure captures.
- **Prior art (recalled):** Rust rejects a constant whose final value refers to interior-mutable data; Swift's `let`
  of a class type is only shallowly immutable; Pony's `val` and Rust's `Sync` express deep immutability.

Recommendation at the time: **C**, the only option that keeps D0009's "no global variables" true, with mutable
default collections, without hidden copies or run-time panics on data whose type says it is mutable.

## Choice

**C.**
1. A constant may have any type, including function types of either purity.
2. **[R-const-mutable]** A constant's value must contain no mutable state: no mutable object, either directly or
   reachable from it, including the values captured by a function value. At the least, a constant whose type is or
   contains a mutable collection type is rejected.
3. Every use of a constant refers to its one value; whether an implementation shares or copies it cannot be observed.
4. M05 and M07 define how rule 2 is checked: statically from types where they suffice, and otherwise on the value at
   the end of its evaluation.

## Rationale

With mutable default collections, a constant of any type would otherwise reintroduce global mutable state, and
purity would no longer mean what D0008 says. Making the rule part of a constant's meaning, rather than copying or
freezing at run time, keeps costs visible and failures at compile time. The property it relies on, that a value
contains nothing mutable, is one M10 will likely need for sharing values safely, so it is not a concept invented only
for constants.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 7.
- **M05:** defines which types are free of mutable state; **M07:** defines the check for values and closure captures,
  with D0011's escape analysis, and keeps any new mutable heap object out of constants.
- **M10:** may reuse the same property for sharing values between tasks (OQ-001).
- **M14:** constant tables use the immutable collections; short literal syntax for them would help.
- **T0013:** artifacts store constant values, including function values that refer to code in other units.
- **I1, I2, I3:** each implementation turns evaluated values back into constants of its core or bytecode.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 7
- Grammar rules: none
- Formal rules: none yet ([dynamic.md](../../spec/formal/dynamic.md) note)
- Examples / tour: [vision.md](../vision.md)
