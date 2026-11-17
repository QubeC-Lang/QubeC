# D0052: Floating-point results are bit-identical on every implementation and platform

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0051](D0051-deterministic-sequential-language.md) makes the sequential language deterministic. Floating point is
where that costs the most, so it is decided separately. M05 decides the float types and their exact rules; this
record sets the policy M05 must follow.

Two terms. The **basic operations** (`+ − × ÷ √`, and fused multiply-add where written) are
**correctly rounded** by IEEE 754: the result is the representable number nearest the exact one. They are therefore
bit-identical on every IEEE machine, as long as nothing intervenes: no **contraction** (fusing `a*b + c` into one
operation without being asked) and no flushing of tiny results to zero. The **math functions** (`sin`, `exp`, `pow`, …) are usually not
correctly rounded by C libraries, so different libraries can differ in the last bit.

## Options considered

The scenario for every option (provisional syntax):

```
proc main() {
  let a = 0.1 + 0.2;                       // a basic operation
  print(a.to_string());                    // formatting
  print(sin(1.0e22).to_string());          // a math function
  let n = 0.0 / 0.0;
  print(n.to_string());                    // "NaN" or "-NaN"?
  print(n.to_bits().to_string());          // 7ff8… on arm64, fff8… on x86-64
}
```

Our pilot on one machine ([R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)) found that
`0.0 / 0.0` has the bits `7ff8000000000000` on arm64 and `fff8000000000000` on x86-64, so the two Tier 1 platforms
of [D0046](D0046-first-platforms-and-tiers.md) disagree unless the language canonicalizes NaN. On that machine, Rust,
OCaml, Zig, and C all returned the same math-function results, because all of them called the same system library.

### A. Bit-identical everywhere

Basic operations follow IEEE 754 with rounding to nearest, ties to even, and no contraction or flush-to-zero.
Whenever a NaN is observed (by its bits, by formatting, or otherwise), it is one **canonical NaN**. Formatting is
specified, for example as the shortest text that reads back to the same number. Math functions have specified
results: correctly rounded, or computed by one fixed algorithm.

```
every platform:  0.30000000000000004 · the same digits for sin(1.0e22) · NaN · one bit pattern
```

- **Easy:** D0051 holds without exception; float tests compare exactly.
- **Hard:** every runtime uses the same math library rather than the platform's; observing a NaN costs a check.
- **For implementers:** the reference evaluator ([D0027](D0027-executable-reference.md)) must compute the specified
  math functions itself. Lean models its basic `Float` arithmetic, but its `Float.sin` calls the C function `sin`
  (verified, R0008).
- **Prior art (verified, R0008):** Java 17 made all floating-point operations strict (JEP 306), and `StrictMath`
  requires the results of the published fdlibm algorithms; WebAssembly's deterministic profile produces only
  positive canonical NaNs; the CORE-MATH project's correctly rounded functions are entering glibc (seven binary64
  functions from 2.43). That correctly rounded functions now perform competitively is recalled, not verified.

### B. Basic operations identical; math functions within an error bound

As A, except that math functions must be within a stated bound (say one unit in the last place) and their last bits
are implementation-defined: the one listed exception to D0051.

```
every platform:  0.30000000000000004 · NaN · one bit pattern
sin(1.0e22):     may differ in the last digit between platforms
```

- **Easy:** runtimes use the platform's math library.
- **Hard:** float tests involving math functions need tolerances; [D0023](D0023-claimed-meta-properties.md)'s
  determinism is parameterized by the math library; the self-hosted compiler must never depend on such results.
- **Prior art (verified, R0008):** Java's `Math.sin` must be within 1 ulp, and `Math` is "not defined to return the
  bit-for-bit same results"; Rust's `f64::sin` says its precision "varies by platform, Rust version, and can even
  differ within the same execution".

### C. Deterministic by default; fast math functions only where written

As A for the default math functions. The explicit layer ([D0004](D0004-ranked-design-values.md)) adds separately
named platform functions (provisional `sin_fast`) whose last bits are implementation-defined, visible at each call.

- **Easy:** follows D0004's layering: Predictability in the default layer, Performance in the explicit layer.
- **Hard:** two families of math functions; the semantics needs a platform parameter for the fast ones; tests must
  avoid them.

| | A Bit-identical | B Bounded | C Strict, fast where written |
| --- | --- | --- | --- |
| D0051 without exception | yes | no | yes, unless written |
| Runtime math library | specified and shared | the platform's | both |
| Exact float tests | always | not for math functions | not for the fast ones |

Recommendation at the time: **A**. It keeps D0051 without exception at the cost of one shared, specified math library
and NaN canonicalization at a few points. C can still be added later by a new decision if M05 finds a real need,
without breaking any program.

## Choice

**A.**
1. Floating-point results are bit-identical on every conforming implementation, engine, and platform.
2. Basic operations follow IEEE 754, rounding to nearest with ties to even. No implementation contracts operations or
   flushes subnormal results to zero.
3. Every observation of a NaN observes one canonical NaN.
4. The conversion of floats to and from text is specified.
5. Every math function in the core and standard library has specified results, correctly rounded or computed by one
   fixed algorithm. Which of the two is open, together with the canonical NaN's bit pattern
   ([OQ-011](../open-questions.md#oq-011-how-are-floating-point-math-functions-and-the-canonical-nan-specified)).

## Rationale

D0051's rule is only as strong as its weakest exception, and floats are what programs in the tooling domain print
and compare. Our pilot showed that even the two Tier 1 platforms disagree on NaN bits. The basic operations already
cost nothing extra, so the remaining work, one specified math library and canonical NaN observations, buys exact
float tests and a reference evaluator that agrees bit for bit.

## Consequences

- **M05:** decides the float types, the canonical NaN, the text conversions, and how math functions are specified
  (OQ-011); no float operation's result may depend on the platform.
- **M14:** provides the math functions with the specified results.
- **I1, I2, and native code later:** every runtime (the Rust interpreter, the Zig VM) uses the same specified math
  functions, never the platform's; back ends never contract operations.
- **Mechanization (M03 onward):** the reference evaluator implements the specified math functions in Lean rather than
  calling C.
- **Performance:** math-heavy code may run slower than with the platform's library; C remains available as a later
  decision.

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (new)
- Grammar rules: none
- Formal rules: none yet (M05)
- Examples / tour: none
