# D0072: A program's meaning comes from source alone; compiled units are caches

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

A program is built from many units ([D0073](D0073-acyclic-multi-file-units.md)): its own, its dependencies', and the
standard library's. An implementation compiles each unit into a stored form (its checked core, the values of its
constants, its bytecode) and may reuse that form in later builds. Is such a stored form ever an input to what a
program means, so that a library could be distributed without its source, or is the source of every unit always the
definition, with stored forms only a cache?

Two earlier decisions limit what a stored form can hide. A constant may call any pure function, a library's included,
at compile time ([D0068](D0068-only-pure-code-at-compile-time.md)), and `qubecc` evaluates such calls over the core
because a QubeC program cannot run code it generates ([D0043](D0043-native-code-after-v1.md),
[D0063](D0063-program-phases.md)); compiling a dependent unit can therefore need a library's code, not only its
signatures. Emitted bytecode loads only in the release that wrote it
([D0044](D0044-executables-and-unstable-bytecode.md)).

## Options considered

The scenario for every option (provisional syntax beyond `func`, `proc`, and `const`; imports are M09's):

```
// unit textutil
func build_widths() -> ImmutableMap[Char, Int] = …;
const WIDTHS: ImmutableMap[Char, Int] = build_widths();
const MEASURE: func(Str) -> Int = display_width;   // a function value
func display_width(s: Str) -> Int = …;              // reads WIDTHS
func pad[T](x: T, width: Int) -> Str = …;           // generic

// unit wc (uses textutil)
const BANNER_W: Int = textutil.display_width("wc 1.0");  // runs textutil's code at compile time
proc main() { print(textutil.pad(42, BANNER_W)); }
```

### A. Source-only meaning; compiled units are caches

Acceptance, constant values, and observable behavior are fixed by the source files of every unit (and embedded files,
if M11 adds them). An implementation may reuse a stored form of `textutil`, with `WIDTHS` evaluated and `MEASURE`
stored as a reference to `display_width`'s code, only when the result is the same as compiling `textutil` from
source. A prebuilt cache of the standard library is allowed on the same terms. Every build has the source of every
unit.

- **Easy:** nothing to keep compatible; rebuilding from source always works.
- **Hard:** no closed-source libraries.
- **For implementers:** each implementation chooses and changes its cache format freely; the reference evaluator
  ([D0027](D0027-executable-reference.md)) and the release checks ([D0029](D0029-permanent-host-implementation.md))
  always have the full source.
- **Locks in / rules out:** binary libraries would need a new decision that also revisits D0044.
- **Prior art:** Go 1.12 was the last Go release to support binary-only packages (verified,
  [R0011](../research/R0011-units-reproducibility-and-source-names.md)); Cargo builds every crate from source, and
  rlibs are tied to one compiler version (recalled).

### B. Compiled units as inputs within one release

`textutil` may be shipped as a compiled unit for one release of one implementation, holding its interface, its core
(needed for `pad[T]` and for `BANNER_W`), and its constant values; `wc` builds against it without `textutil`'s source.
The specification must then define compiled units.

- **Easy:** libraries without source, for one release.
- **Hard:** the code is not actually hidden, because the core must be included for compile-time evaluation and
  generics; the two implementations' forms are unrelated.
- **For implementers:** a second format per implementation that must agree with the source semantics; the reference
  must load it, or the release checks need the source anyway.
- **Prior art (recalled):** OCaml's `.cmi` and `.cmx` files and Rust's rlibs are release-bound, and in practice are
  used as caches.

### C. A stable compiled-unit format across releases

A versioned format for compiled units that later releases keep loading, as Java class files are.

- **Easy:** real binary distribution.
- **Hard:** stored constant values, function values included, become a long-term compatibility contract.
- **For implementers:** contradicts D0044's unstable bytecode; both implementations and the reference keep the format
  forever.
- **Prior art (recalled):** Java's class files are stable at a cost; Swift needed a separate interface language for
  library evolution.

Recommendation at the time: **A**, as the only option consistent with D0044 and D0068 at no cost to the language.

## Choice

**A.**
1. **Source-only meaning.** Whether a program is accepted, the values of its constants, and its observable behavior
   are determined by the source files of its units, and by embedded files if M11 adds them
   ([D0068](D0068-only-pure-code-at-compile-time.md)), never by a compiled form of a unit.
2. **Compiled forms are caches.** An implementation may reuse a compiled form of a unit, produced by an earlier build
   or shipped with the implementation (such as a prebuilt standard library), only if the result is the same as
   compiling that unit from source. This covers stored constant values
   ([D0064](D0064-every-constant-once.md), [D0067](D0067-constant-values-without-mutable-state.md)), including function
   values stored as references to code in the same or another unit.
3. **No binary-only libraries.** Every build has the source of every unit of the program. Allowing binary libraries
   later takes a new decision that revisits this one and D0044.

## Rationale

Unstable bytecode and compile-time evaluation over library code leave binary libraries almost nothing to gain: they
could not hide a library's code, and a stable format would be a permanent second contract kept by two
implementations. Source-only meaning costs the language nothing, and it keeps every check we depend on (the
reference, the build from source, the fixpoint, differential testing) working from source.

## Consequences

- **Spec:** [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 4 and 5.
- **I1, I2, I3:** caches are keyed by the contents of everything a unit's compiled form depends on, never by file times;
  stored function values refer to code symbolically, and each implementation turns them back into constants of its
  core or bytecode.
- **M09:** packages are distributed as source.
- **M11:** embedded files are build inputs like source files.

## Affected artifacts

- Spec: [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 4–5
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
