# R0004: Formalization depth and proof assistants: prior art and pilots

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0005 |
| Used by | D0021, D0022, D0023, D0024, D0025, D0026, D0027, D0028 |

## Question

The T0005 decisions cite how other languages formalized their semantics, which proofs are known to be hard, and how
proof assistants compare for language metatheory. Which claims did we check, and what did a small pilot in two
proof assistants show?

## Sources

1. A. Timany, L. Stefanesco, M. Krogh-Jespersen, L. Birkedal, "A Logical Relation for Monadic Encapsulation of
   State: Proving contextual equivalences in the presence of runST", PACMPL 2 (POPL 2018), article 64,
   doi:10.1145/3158152; author page https://cs.au.dk/~timany/publications/pub_pages/2018_popl_stmonad/ (found by
   search, abstract read).
2. R. Harper, C. Stone, "An Interpretation of Standard ML in Type Theory", CMU technical report, 1997
   (https://apps.dtic.mil/sti/pdfs/ADA333520.pdf), and the later "A Type-Theoretic Interpretation of Standard ML";
   D. K. Lee, K. Crary, R. Harper, "Towards a Mechanized Metatheory of Standard ML", POPL 2007 (found by search,
   summaries read).
3. W. D. Clinger, "Proper Tail Recursion and Space Efficiency", PLDI 1998, pp. 174–185, doi:10.1145/277650.277719
   (found by search, abstract read).
4. Y. K. Tan, S. Owens, R. Kumar, "A Verified Type System for CakeML", IFL 2015, doi:10.1145/2897336.2897344 (found
   by search, abstract read).
5. C. Watt, "Mechanising and Verifying the WebAssembly Specification", CPP 2018
   (https://www.cl.cam.ac.uk/~caw77/papers/mechanising-and-verifying-the-webassembly-specification.pdf); C. Watt et
   al., "Two Mechanisations of WebAssembly 1.0", FM 2021 (found by search, abstracts read).
6. D. Youn et al., "Bringing the WebAssembly Standard up to Speed with SpecTec", PLDI 2024; WebAssembly news,
   "SpecTec has been adopted", https://webassembly.org/news/2025-03-27-spectec/ (found by search, summaries read).
7. M. de Medeiros et al., "Iris in Lean", arXiv:2609.24252, September 2026 (abstract read); iris-lean repository,
   https://github.com/leanprover-community/iris-lean (readme summary).
8. Verso documentation, https://verso.lean-lang.org/doc/latest, and repository https://github.com/leanprover/verso
   (readme summary).

## Findings

- **Verified [1]:** the encapsulation of state by `runST` was proved with a logical-relations model built in the Iris
  separation logic, formalized in Coq. The paper shows that computations encapsulated by `runST` are heap
  independent, and that equivalences expected of pure code still hold. It describes this as the first such
  relational result.
- **Verified [2]:** Harper and Stone define Standard ML by elaboration rules into an explicitly typed internal
  language. Lee, Crary, and Harper mechanized a version of the internal language in Twelf. Secondary summaries say
  that a full soundness proof of the original Harper–Stone elaboration was not completed.
- **Verified [3]:** Clinger defines proper tail recursion as a property of asymptotic space, using a space model, for
  Scheme.
- **Verified [4]:** CakeML's type system has a declarative specification, a type soundness theorem, and a type
  inferencer proved sound and complete with respect to it, all in HOL4.
- **Verified [5]:** the first mechanization of WebAssembly is in Isabelle/HOL (about 11,000 lines). It includes a
  verified executable interpreter and type checker and a soundness proof, and it found defects in the official
  specification. A Coq mechanization (WasmCert-Coq) followed, with an interpreter proved sound against it.
- **Verified [6]:** SpecTec generates WebAssembly's typeset formal rules, prose, and an interpreter from one source.
  The interpreter passes all applicable official Wasm 2.0 tests, with decoding and validation delegated to the
  reference interpreter. WebAssembly adopted SpecTec in 2025.
- **Verified [7]:** an Iris port to Lean 4 exists and is described in a 2026 paper with a new implementation of the
  Iris proof mode. Another 2026 source still calls the port unfinished, so it is maturing and behind the Rocq
  original.
- **Verified [8]:** Verso is Lean's documentation authoring framework. Its documents are Lean files, and its readme
  names the Lean language reference as an application.
- **Recalled:** Featherweight Java (2001) and Featherweight Go (2020) are research subsets. The Definition of
  Standard ML formalizes the whole language on paper. RustBelt proves a core calculus (λRust) using Iris. The
  original Java memory model was found to be flawed. GHC re-checks its typed Core with Core Lint. Go has no formal
  concurrency semantics. Ott generates LaTeX and prover definitions, but not Lean.

## Experiments

A pilot in a scratch directory outside the repository, run on 2026-11-16 with Lean 4.36.0 and Rocq 9.3.0, using
only each system's standard library.

- **Calculus:**
  - Effects `pure ≤ eff`, with join.
  - Types `unit`, `int`, and `a →φ b` (a function whose call has latent effect φ).
  - Expressions with de Bruijn variables: literals, `unit`, `lam`, application, and a `print` primitive.
  - Typing rules T-Var, T-Lit, T-Unit, T-Lam, T-App (`… ! φ₁ ⊔ φ₂ ⊔ φ`), T-Print, and T-Sub (subsumption).
  - Call-by-value big-step evaluation with an output trace.
- **Theorem:** if `[] ⊢ e : τ ! pure` and `e ⇓ v ⊣ t`, then `t = []` and `[] ⊢ v : τ ! pure`.
- **Structure of the proof in both systems:**
  - lifting and substitution with a cutoff;
  - weakening and a substitution lemma, generalized over a context prefix;
  - inversion lemmas that see through subsumption;
  - a generalized soundness lemma, by induction on evaluation.

| | Lean 4.36.0 | Rocq 9.3.0 |
| --- | --- | --- |
| Result | checks; axioms `propext`, `Quot.sound` | checks; closed under the global context |
| Non-blank lines (definitions / proofs) | 182 (80 / 102) | 171 (69 / 102) |
| Check time | about 0.6–0.9 s | about 0.4 s |
| Fix iterations | 2 | 1 (written after the Lean proof fixed the structure) |

- **Defect test:** changing T-App's conclusion to `φ₁ ⊔ φ₂` broke both proofs, in the application inversion lemma.
  - Lean reported a type mismatch, with the unprovable effect inequality as the expected type.
  - Rocq reported only "Wrong bullet … Current bullet - is not finished"; the stuck goal was visible only with
    `Show.`.
  - When the inversion lemma was also adapted to the defective rule, both failed in the application case of the
    soundness proof. Lean printed the case tag `app.refl.pure.pure.eff` and the hypotheses: an effectful function
    body typed pure at the call site.
- **Friction:**
  - Lean's method-call notation (`e.subst n s`) silently supplied `e` as the wrong argument. Explicit application
    fixed it.
  - De Bruijn index arithmetic took similar effort in both systems.
  - Inversion under subsumption needed separate lemmas in both.
  - Lean continued past errors and checked later theorems. Rocq stopped at the first error.
  - One deprecated tactic form appeared in Lean 4.36.

## Conclusions

The hard items in the target we chose are known. The encapsulation of local mutation needed separation logic in its
relational form, so a syntactic discipline is preferable. Proper tail calls need a semantics with an explicit stack.
Mechanizing an explicitly typed core with a verified interpreter and checker has precedent (WebAssembly), and so does
verified inference (CakeML). In the pilot, both Lean 4 and Rocq handled binder-level metatheory easily at this scale,
and both caught the defect. Lean's diagnostics were markedly better, and Rocq's separation-logic ecosystem is
stronger.
