# R0006: Prior art for planning design and implementation together

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0007 |
| Used by | D0036, D0037, D0041 |

## Question

When does a language's implementation start relative to its design, and when is a design frozen? We needed to know
how other language processes relate an accepted design, a working implementation, and a final or stable status,
to choose when QubeC's implementation starts (D0036) and when Spec v1.0 may be published (D0041).

## Sources

1. PEP 1, "PEP Purpose and Guidelines", sections on the PEP workflow and "What belongs in a successful PEP?",
   <https://peps.python.org/pep-0001/> (read 2026-11-16).
2. Swift Evolution, `process.md`, "Proposal states" and the review requirements,
   <https://github.com/swiftlang/swift-evolution/blob/main/process.md> (read 2026-11-16).
3. Rust Compiler Development Guide, "Request for stabilization",
   <https://rustc-dev-guide.rust-lang.org/stabilization-guide.html> (read 2026-11-16).

## Findings

- **Verified:** in Python, a Standards Track PEP may be accepted before its reference implementation exists, but
  "the reference implementation must be completed before any PEP is given status 'Final'" [1]. The design is
  accepted first, and implementation is the gate to finality.
- **Verified:** Swift's Language Steering Group requires language and standard library proposals to "have a prototype
  implementation before they can be reviewed"; the prototype must be "a viable proof of concept" that reviewers can
  use [2]. Implementation comes before a design is even reviewed.
- **Verified:** in Rust, a feature is ready to stabilize once it "has been well-tested with no outstanding concerns",
  and stabilization needs "a complete PR to the Reference describing the feature", approved before the
  stabilization PR merges [3]. The feature is implemented behind a feature gate first, and the specification text
  and the stable status come last.
- **Recalled:** Algol 68 was specified before it was implemented, and its implementations were late and partial.
- **Recalled:** Ada 83 had an executable interpreter, NYU Ada/Ed, validated in the year of the ANSI standard.
- **Recalled:** Rust's design evolved for years alongside its implementations. rustc first compiled itself in 2011,
  four years before Rust 1.0 (2015).
- **Recalled:** C++'s `export` templates were standardized in C++98 before implementations existed. Few
  implementations ever supported them, and C++11 removed them.

## Conclusions

The processes we checked fall into three groups. Python and Rust accept a design first and make implementation the
gate to its final status. Swift requires an implementation before a design is reviewed. Algol 68 and `export`
templates specified first and froze before implementing. Our plan follows the first group, both per feature and for
the spec as a whole: the implementation trails the accepted design (D0036), and Spec v1.0 waits until two
implementations and the self-hosted compiler have exercised every feature (D0041).
