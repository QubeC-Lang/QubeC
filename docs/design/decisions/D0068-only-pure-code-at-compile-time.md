# D0068: Only pure code runs at compile time, and a constant's value depends on the source alone

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

A constant's initializer calls only `func`s ([D0009](D0009-immutable-bindings.md)), and compile-time evaluation may
run any `func` ([D0008](D0008-purity.md)). Two points remain: whether any native may run at compile time, since natives
are almost all procedures ([D0056](D0056-thin-natives.md)), and whether a constant's value may come from anything
other than the source text, such as the contents of a file.

## Options considered

All options share one rule for natives: a native whose specification makes it pure may run at compile time, and every
compiler and the reference provide it. Forbidding natives at compile time altogether would make some pure library
functions unusable in constants, splitting the library in two, so it was not offered.

The scenario for every option (provisional syntax):

```
const VERSION: Str = embed_file("VERSION.txt").trim();   // a build input?
const BANNER:  Str = "qubec " + VERSION;
const BITS:    Int = Float.to_bits(1.5);                  // a pure native: allowed in every option
const NOW:     Int = clock.now();                         // a procedure: rejected in every option
```

### A. Never: the source alone

There is no way to embed a file, now or later; a version string comes from a source file that the build tool writes.

- **Easy:** the simplest identity of a build.
- **Hard:** tools that embed templates, fixtures, or license texts must convert them to source first.

### B. Source only now; M11 may add embedded files as declared build inputs

As A today. If M11 adds a way to embed files, an embedded file is a build input like a source file, and T0013 counts
it in what identifies a build; reading it is a fact about the build, not an effect, so the same file gives the same
constant in every implementation; paths and packaging belong to M11 and M09.

- **Easy:** nothing to build now; the reproducibility rule is fixed before the feature is designed.
- **Hard:** T0013 leaves room for build inputs other than source files.

### C. Build-input built-ins now

`embed_file(path)`, and perhaps a value passed by the build command, are decided now.

- **Hard:** decides M09's paths and T0013's build identity ahead of time; a value from a command-line flag makes a
  program's meaning depend on how it was built.

Compile-time procedures (Jai's `#run`, Rust's build scripts) were not offered: they contradict D0009 and would make
builds depend on the machine.

- **Prior art (recalled):** Rust's `include_str!` and `include_bytes!` (and `env!` for build-time environment
  variables), Zig's `@embedFile`, Go's `//go:embed` (which fills package variables, not constants), and C23's
  `#embed` all treat embedded files as inputs of the build.

Recommendation at the time: **B**, which costs nothing now, keeps a feature that tooling programs and `qubecc` may
want, and fixes its reproducibility rule in advance.

## Choice

**B.**
1. **No effects at compile time.** Compile-time evaluation performs no effect: no procedure and no effectful function
   value is called during it. Nothing is written, executed, or fetched during compilation on the program's behalf.
   The rule that a constant's initializer is pure (D0008, D0009) is one of the static rules.
2. **Pure natives.** A native whose specification makes it pure may run at compile time. Every compiler, and the
   reference, provides each such native with the same results as at run time.
3. **The source alone.** A constant's value depends only on the program's source, including the standard library's.
4. **A guarded door for embedded files.** M11 may add a way to name files whose contents become constant values,
   only under these rules:
   - an embedded file is a build input, like a source file, and T0013 includes it in what identifies a build;
   - reading it is a fact about the build, not an effect of the program: the same file gives the same constant in
     every implementation;
   - the path rules and packaging are M11's and M09's.

## Rationale

Fixing the boundary now, with no effects at compile time ever, keeps builds independent of the machine and keeps
dependencies' code from doing anything during compilation. Embedded files, if they come, keep builds reproducible
because they are inputs like source files; values passed by the build command would not, so they are not part of the
door.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rules 8–9.
- **M11:** decides whether to embed files, under choice 4; macros and attributes, if any, also run without effects.
- **M14:** marks which natives are pure; each pure native is implemented by both host runtimes, the reference, and
  each compiler's evaluator.
- **T0013:** the definition of a build's inputs leaves room for embedded files.
- **Version strings and similar build data** come from source files or, later, embedded files, never from running a
  program during the build.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rules 8–9
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
