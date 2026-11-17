# D0056: Natives are thin and declared in the standard library's source

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

A **native** is an operation whose body is not QubeC code but is supplied by each runtime: in Rust for the
tree-walker, in Zig for the VM, later in QubeC ([D0055](D0055-runtime-contract-and-runtimes.md)), with a model in the
Lean reference ([D0027](D0027-executable-reference.md)). Every copy must behave identically
([D0051](D0051-deterministic-sequential-language.md)), floats included
([D0052](D0052-bit-identical-floats.md)). Which operations are natives, and where are they declared?

## Options considered

The scenario for every option (provisional syntax):

```
proc main() {
  let text = read_file("data.txt");     // must cross into the OS
  let xs = parse_numbers(text);         // List[Float]
  let m = sqrt(mean(xs));               // a math function (bit-identical, D0052)
  print(format_float(m));               // float to text (D0052), and standard output
  print(sorted(xs).len());              // a library algorithm
}
```

### A. Thin natives, declared in the standard library's source

Only what QubeC code cannot express is native: the boundary with the operating system (files, standard input, output,
and error, arguments, the environment, the clock, randomness, ending the run) and a few runtime internals the library
needs. Everything else, including `format_float`, `sqrt`, `sorted`, and number parsing, is ordinary QubeC source in the
standard library, which every runtime and the reference run. Each native is declared in that source with a marker, so
its type and purity are checked like any declaration.

```
// in the standard library (provisional syntax)
native proc read_file(path: Str) -> Result[Str, IoError];
native proc write_stdout(bytes: Bytes);
func format_float(x: Float) -> Str = { … ordinary QubeC: shortest round trip … };
func sqrt(x: Float) -> Float = { … ordinary QubeC, correctly rounded … };
```

- **Easy:** bit-identical floats come almost for free, because math and float printing are written once; a new
  runtime ports a short list; the library is a large realistic test program.
- **Hard:** math and formatting run at VM speed until a runtime optimizes them; correctly rounded algorithms must be
  written in QubeC; I1 needs a small library early, if only to print an integer.
- **Prior art (recalled):** Go's library and runtime are mostly Go; Smalltalk-80's small set of primitives; Lean 4's
  `@[extern]` declarations in library source.

### B. Thick natives

Formatting, parsing, math, sorting, hashing, and string search are natives, specified in prose and implemented in
every runtime and in the reference.

```
// built into each runtime; the library re-exports them
print(format_float(sqrt(mean(xs))));   // three natives, each written three or four times
```

- **Easy:** fast from the start; each runtime can use its host language's libraries.
- **Hard:** three or four independent copies must agree bit for bit, which is exactly the risk D0052 took on; a long
  prose specification; a large port for the runtime in QubeC.
- **Prior art (recalled):** CPython's large C core.

### C. Thin natives in a built-in table

The same thin set as A, listed in the runtime contract and known to the compiler, with no declarations in source.

```
// nowhere in source: the compiler knows read_file : (Str) -> Result[Str, IoError]
func format_float(x: Float) -> Str = { … QubeC … };   // as in A
```

- **Easy:** no declaration syntax.
- **Hard:** natives' types live outside the language, checked by a separate mechanism; adding one edits the compiler
  as well as the library.
- **Prior art (recalled):** Lua's C functions, registered by the runtime.

Recommendation at the time: **A**, the cheapest way to keep three runtimes and the reference identical, and a short
port list for the runtime in QubeC.

## Choice

**A.**
1. **Thin natives.** The natives are limited to operations that QubeC code cannot express: the boundary with the
   operating system (files and directories; standard input, output, and error; arguments and the environment; the
   clock; randomness; ending the run; later processes), and the runtime internals that the standard library needs.
   Everything else in the standard library is written in QubeC.
2. **The source is normative.** A runtime MAY replace a library function written in QubeC with a native body only as
   an optimization that cannot be observed ([D0049](D0049-precise-panics.md)). The QubeC source remains its
   definition, and the conformance suite checks both.
3. **Declared in source.** Each native is declared in the standard library's source with a marker that gives its
   name, parameter types, result type, and purity; the declaration is checked like any other. A native is a `proc`
   unless its specification says otherwise. The marker's syntax, and how the standard library is identified, are
   provisional (M09, M14).
4. **Only the standard library declares natives.** A program that declares one is rejected. Foreign declarations
   belong to M12.
5. **Adding a native** takes a declaration in the library, implementations in both host runtimes and a model in the
   reference, then in the runtime in QubeC when it exists, and conformance tests.

## Rationale

Determinism across three runtimes and a reference is cheapest when they share everything except the boundary with the
operating system. Floating-point printing and math functions, the hardest parts to keep bit-identical, are then
written once in QubeC and run everywhere, the reference included. A short, typed, visible list of natives is also what
keeps the runtime in QubeC ([D0055](D0055-runtime-contract-and-runtimes.md)) small.

## Consequences

- **M05:** the algorithms for float formatting, parsing, and correctly rounded math are library code
  ([OQ-011](../open-questions.md#oq-011-how-are-floating-point-math-functions-and-the-canonical-nan-specified)).
- **M09, M14:** decide the marker's syntax, how the standard library is identified, and the list of natives; every
  native that interacts with the environment is specified as an event ([D0048](D0048-trace-and-outcome.md)).
- **I1:** the tree-walker needs the first few natives (writing to standard output) and a minimal library early.
- **I2:** how bytecode refers to natives is part of the bytecode format
  ([OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)).
- **Conformance suite:** tests of library functions run on every runtime, with and without native replacements.

## Affected artifacts

- Spec: none yet (the library chapter, M14)
- Grammar rules: none yet
- Formal rules: none yet (natives are events of the machine, M03)
- Examples / tour: none
