# R0003: Prior art for specification audience, authority, diagnosis, and extensions

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0004 |
| Used by | D0015, D0016, D0017, D0018, D0019 |

## Question

The T0004 decisions cite how other language specifications treat their readers, the relation between prose and
formal rules, rules that need no diagnostic, unspecified evaluation order, and implementation extensions. Which of
those claims did we check against the specifications themselves, and which rest on recollection?

## Sources

1. WebAssembly Core Specification, "Validation › Conventions",
   https://webassembly.github.io/spec/core/valid/conventions.html (fetched 2026-11-16).
2. WebAssembly Core Specification, "Introduction",
   https://webassembly.github.io/spec/core/intro/introduction.html (fetched 2026-11-16).
3. C++ working draft, [intro.compliance.general], https://eel.is/c++draft/intro.compliance.general (fetched
   2026-11-16).
4. The Go Programming Language Specification, https://go.dev/ref/spec (fetched 2026-11-16): "Order of evaluation"
   and the "Implementation restriction" paragraphs.
5. Go 1.21 release notes, https://go.dev/doc/go1.21 (fetched 2026-11-16).
6. Rust blog, "Adopting the FLS" (2025-03-26), https://blog.rust-lang.org/2025/03/26/adopting-the-fls/ (found by
   search, not read in full).

## Findings

- **Verified [1]:** WebAssembly states that "All rules are given in two *equivalent* forms" (prose and formal), and
  that "understanding of the formal notation is *not* required to read this specification".
- **Verified [2]:** the WebAssembly introduction does not itself state the equivalence; it says the specification
  "fully and precisely defines valid programs and their behavior in a way that is easy to reason about informally
  and formally".
- **Verified [3]:** in C++, every rule is diagnosable unless it is marked "no diagnostic is required" or results in
  undefined behavior. For a violation of a rule marked "no diagnostic is required", the standard "places no
  requirement on implementations with respect to that program". Otherwise, a conforming implementation "shall issue
  at least one diagnostic message".
- **Verified [3]:** a conforming C++ implementation "may have extensions … provided they do not alter the behavior of
  any well-formed program". Implementations must diagnose programs that use extensions that are ill-formed by the
  standard, but "having done so, however, they can compile and execute such programs".
- **Verified [4]:** Go leaves some evaluation orders unspecified. Its own example: with `f` incrementing `a`,
  `x := []int{a, f()}` "may be [1, 2] or [2, 2]".
- **Verified [4]:** Go contains bounded exemptions from diagnosis and implementation-chosen rejections, marked
  "Implementation restriction": "A compiler need not report an error if an operand's type is a type parameter with an
  empty type set", and "A compiler may make it illegal to declare a variable inside a function body if the variable
  is never used".
- **Verified [5]:** the Go 1.21 notes say "the description of type inference in the language spec has been
  clarified", and that package initialization order "is now specified more precisely".
- **Verified [6], in outline:** the Rust project adopted the Ferrocene Language Specification (FLS) in 2025. Its
  paragraph-identifier scheme was not checked.
- **Recalled:** the JLS and the Go specification are prose only; the Definition of Standard ML is formal and
  governs, with its Basis library specified separately in prose; ECMAScript states its semantics as algorithmic
  steps; the Haskell 2010 Report includes the Prelude in Part I and libraries in Part II; Ada has an Annotated
  Reference Manual alongside its Reference Manual.
- **Recalled:** no mainstream language specification requires diagnostics to name the rule they enforce. C requires
  a diagnostic for a constraint violation, but not that it names the constraint. Rust's `E0xxx` and C#'s `CSxxxx`
  codes are compiler conventions, not specification rules.
- **Recalled:** Rust gates unstable features behind `#![feature(…)]` in source, on nightly builds only; GHC enables
  extensions with `{-# LANGUAGE … #-}` pragmas; Java enables preview features with `--enable-preview` at both compile
  and run time.

## Conclusions

The WebAssembly model shows that readable prose and formal rules can sit side by side. The C++ and Go texts show
the two forms of "no diagnostic required": unbounded in C++, which is undefined behavior by another name, and
bounded in Go. Go's evaluation-order example is a concrete case of declarative prose leaving observable order open.
C++'s extension rule weakens what "compiled" means; an in-source opt-in keeps it intact.
