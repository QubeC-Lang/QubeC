# R0001: Prior art cited by the vision decisions

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0002 |
| Used by | D0002, D0004, D0005, D0006, D0007 |

## Question

The vision decisions cite other languages as evidence. Which of those claims did we check against a source, and
which rest on recollection?

## Sources

1. Swift.org, *API Design Guidelines*, https://www.swift.org/documentation/api-design-guidelines/ (fetched
   2026-11-16).
2. Nada Amin and Ross Tate, "Java and Scala's Type Systems are Unsound: The Existential Crisis of Null Pointers",
   OOPSLA 2016, DOI 10.1145/2983990.2984004. PDF: https://infoscience.epfl.ch/record/227019/files/unsound-oopsla.pdf;
   artifact: https://github.com/namin/unsound.

## Findings

- **Verified [1]:** "Clarity is more important than brevity." The guidelines call the smallest possible code "a
  non-goal".
- **Verified [1]:** abbreviations, "especially non-standard ones, are effectively terms-of-art"; "the intended
  meaning for any abbreviation you use should be easily found by a web search". This supports the test in D0007.
- **Verified [2]:** short programs type-check in Java and Scala yet convert one type into another without a cast.
  The unsoundness arises from `null` interacting with bounded or existential types (a form of subtyping). This
  supports both NG-6 (no inheritance subtyping) and NG-8 (no `null`) in D0005.
- **Recalled:** Java virtual threads were finalized in JDK 21 (2023); OCaml 5 added multicore and effect handlers
  (2022).
- **Recalled:** C#'s `Span<T>` and `ref struct`, and Swift's `borrowing`/`consuming` modifiers, are safe,
  compiler-checked low-level layers under a managed default; only their raw-pointer tiers are unsafe.
- **Recalled:** Ada spells its keywords as whole words (`procedure`, `function`, `constant`) and names its integer
  type `Integer`.
- **Recalled:** OCaml hosted Rust's first compiler, as well as Flow, Hack, and Rocq.

## Conclusions

The two claims that carry weight in the records, the Swift naming guideline and the Java/Scala unsoundness result,
are verified. The recalled items are historical background only; no decision depends on their exact dates.
