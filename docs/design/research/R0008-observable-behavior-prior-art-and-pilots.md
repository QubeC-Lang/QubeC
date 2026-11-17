# R0008: Observable behavior and determinism: prior art and a floating-point pilot

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M01 / T0010 |
| Used by | D0048–D0054, OQ-011 |

## Question

How do comparable specifications define observable behavior, panics or exceptions, implementation-defined behavior,
floating point, and implementation limits? And do our implementation languages and Tier 1 platforms agree on
floating-point results?

## Sources

1. C11 committee draft N1570, §5.1.2.3 and §5.2.4.1 (HTML copy): <https://port70.net/~nsz/c/c11/n1570.html>
2. CompCert documentation, modules `Behaviors` and `Events`: <https://compcert.org/doc/html/compcert.common.Behaviors.html>,
   <https://compcert.org/doc/html/compcert.common.Events.html>; X. Leroy, "Formal verification of a realistic
   compiler", CACM 2009: <https://xavierleroy.org/publi/compcert-CACM.pdf>
3. JEP 306, "Restore Always-Strict Floating-Point Semantics": <https://openjdk.org/jeps/306>
4. Java SE 17 API, `java.lang.Math` and `java.lang.StrictMath`:
   <https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Math.html>
5. WebAssembly core specification, Numerics (NaN propagation) and Appendix (Profiles):
   <https://webassembly.github.io/spec/core/exec/numerics.html#nan-propagation>,
   <https://webassembly.github.io/spec/core/appendix/profiles.html>; design note "Nondeterminism":
   <https://github.com/WebAssembly/design/blob/main/Nondeterminism.md>
6. Rust standard library, `f64::sin`: <https://doc.rust-lang.org/std/primitive.f64.html#method.sin>; the Rust
   Reference, "Behavior not considered unsafe": <https://doc.rust-lang.org/reference/behavior-not-considered-unsafe.html>;
   RFC 3514, "Float semantics": <https://github.com/rust-lang/rfcs/blob/master/text/3514-float-semantics.md>
7. The Go specification, "For statements with range clause": <https://go.dev/ref/spec#For_range>
8. Python documentation: "What's New In Python 3.7", the `dict` type, `sys.setrecursionlimit`:
   <https://docs.python.org/3/whatsnew/3.7.html>, <https://docs.python.org/3/library/sys.html#sys.setrecursionlimit>
9. S. Peyton Jones, A. Reid, T. Hoare, S. Marlow, F. Henderson, "A semantics for imprecise exceptions", PLDI 1999:
   <https://alastairreid.github.io/papers/except.pdf>
10. The CORE-MATH project: <https://core-math.gitlabpages.inria.fr/>
11. Lean 4 sources, `src/Init/Data/Float/Float.lean` and `src/include/lean/lean.h`:
    <https://github.com/leanprover/lean4>
12. WG21 paper P3375R3, quoting ISO/IEC 60559 clause 11:
    <https://open-std.org/JTC1/SC22/WG21/docs/papers/2025/p3375r3.html>
13. Local toolchains on `macos-arm64`: Apple clang, rustc 1.99.1, OCaml 5.5.2, Zig 0.17.0, and Rosetta 2 for x86-64.

## Findings

**Observable behavior.**
- **Verified [1]:** C11 §5.1.2.3p6 lists accesses to volatile objects, "all data written into files" at program
  termination, and "the input and output dynamics of interactive devices" (so that "prompting messages actually
  appear prior to a program waiting for input"), and calls this "the observable behavior of the program". The
  freedom to do anything else is implicit in p4; §5.1.2.3 does not use the words "as if".
- **Verified [2]:** CompCert's program behaviors are `Terminates trace int` (the integer is the exit code),
  `Diverges trace` (silent divergence after a finite trace), `Reacts traceinf` (an infinite trace), and
  `Goes_wrong trace`. Events are system calls, volatile loads and stores, and annotations. Its correctness theorem
  is behavior preservation, relaxed so that a compiled program may improve on a source program that goes wrong. A
  language without undefined behavior needs no such relaxation.

**Panics and profiles.**
- **Verified [9]:** GHC's imprecise exceptions redefine an exceptional value "to contain a set of exceptions", and
  `getException` in `IO` chooses one member; non-termination is identified with the set of all exceptions.
- **Verified [6]:** with debug assertions enabled, Rust implementations "must insert dynamic checks that panic on
  overflow"; other builds "may result in panics or silently wrapped values on overflow, at the implementation's
  discretion", with two's-complement wrapping.

**Determinism.**
- **Verified [5]:** WebAssembly's nondeterminism consists of shared-memory threads, NaN bits and sign, relaxed SIMD,
  and resource exhaustion (stack, memory, handles), plus feature support and host calls. In its deterministic
  profile, "only positive canonical NaN outputs are produced", but `memory.grow` and `table.grow` "remain
  non-deterministic, in order to be able to indicate resource exhaustion".
- **Verified [7]:** Go: "The iteration order over maps is not specified and is not guaranteed to be the same from one
  iteration to the next."
- **Verified [8]:** Python 3.7 declared dict insertion order "an official part of the Python language spec".

**Floating point.**
- **Verified [3]:** JEP 306 (Java 17) makes "floating-point operations consistently strict".
- **Verified [4]:** `Math` implementations "are not defined to return the bit-for-bit same results", and `Math.sin`
  must be "within 1 ulp of the exact result"; `StrictMath` requires "the same results as certain published
  algorithms" (fdlibm).
- **Verified [6]:** Rust's `f64::sin`: "The precision of this function is non-deterministic. This means it varies by
  platform, Rust version, and can even differ within the same execution from one invocation to the next." RFC 3514:
  non-NaN results "exactly match IEEE 754-2008", while "NaN generation is non-deterministic".
- **Verified [10]:** CORE-MATH provides correctly rounded functions in several formats; seven binary64 functions are
  in glibc from 2.43, and about thirty binary32 functions from 2.42.
- **Verified [11]:** Lean's `Float` corresponds to C `double`. Basic arithmetic has a logical model (`Float.add` is
  defined through `Float.Model` and compiled to C addition), but `Float.sin` is `@[extern "sin"]`, "implemented in
  compiled code by the C function `sin`", so its results depend on the platform's math library.
- **Partly verified [12]:** IEEE 754 is paywalled. Its clause 11, as quoted in P3375R3, says that programs translated
  into "reproducible operations on reproducible formats produce reproducible results", and that "a language standard
  should support reproducible programming". The correct rounding of the basic operations is recalled.
- **Recalled:** correctly rounded math functions now run at speeds competitive with conventional libraries; x86-64
  produces a NaN with the sign bit set and arm64 one without it by default (confirmed for one case by the pilot
  below).

**Limits.**
- **Verified [1]:** C11 §5.2.4.1 requires an implementation to "translate and execute at least one program that
  contains at least one instance of every one of the following limits", including "127 parameters in one function
  definition", "63 nesting levels of parenthesized expressions within a full expression", and "127 nesting levels of
  blocks".
- **Verified [8]:** "The highest possible limit is platform-dependent" (`sys.setrecursionlimit`); the default is not
  stated in the documentation.
- **Recalled:** the Go specification states no translation limits; the Java class-file format limits a method's
  parameters and code size; Python's parser rejects nesting beyond a fixed depth; Ethereum has a fixed call-depth
  limit.

## Experiments

Run in a scratch directory outside the repository, on one `macos-arm64` machine.

1. **Math functions across languages.** One program per language printed the bit patterns of `sin`, `cos`, and `tan`
   of `1e22`, `exp(0.5)`, `exp(709.7)`, `log(1.0000001)`, `pow(2.5, 0.1)`, `sin(0.1)`, `atan2(2.5, 0.1)`,
   `log10(1e300)`, and `cbrt(0.1)`, in C, Rust (`f64` methods), OCaml (`Stdlib`), and Zig (builtins and `std.math`).
   All four printed identical bits: on this platform, all of them call the same system math library.
2. **The same C program, built for arm64 and for x86-64 (run under Rosetta 2).** The math functions gave identical
   bits on both architectures for these inputs.
3. **NaN bits.** `0.0 / 0.0` and `inf - inf`:

   ```
   arm64    7ff8000000000000
   x86_64   fff8000000000000
   ```

   The two architectures of our Tier 1 platforms produce different NaNs for the same operation.

Not tested: Linux (glibc or musl) against Apple's library, because no Linux environment was available.

## Conclusions

- A trace of events followed by an outcome is the established way to define the observable behavior of a program
  formally (CompCert); C's hybrid depends on what counts as an interactive device.
- Determinism is achievable for everything but resource exhaustion, as WebAssembly's deterministic profile shows,
  provided NaN observations are canonical and math functions do not come from the platform.
- Without NaN canonicalization, even `linux-x86_64` and `macos-arm64` disagree. Using the platform's math library
  would make results depend on the library, and Lean's `Float.sin` would too, so the reference evaluator must
  implement the specified functions itself.
