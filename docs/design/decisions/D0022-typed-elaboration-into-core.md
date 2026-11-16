# D0022: Static rules on the surface elaborate into an explicitly typed core; dynamic rules are over the core

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0005 |

## Question

QubeC's surface has conveniences: `if`, method calls, `?`, `for` loops, inferred types and purities. Are the formal
rules written directly over that surface, or over a smaller **core** language into which the surface is translated
(**elaboration**; **desugaring** when the translation is purely syntactic)? Because the formal target is the whole
sequential language ([D0021](D0021-formal-target-sequential-language.md)), any translation must itself be formal, or
a bug in it would escape the theorems.

## Options considered

The scenario for every option (provisional syntax):

```
proc read_count() -> Int { … }
func half(r: Result[Int, Err]) -> Result[Int, Err] = {
  let n = r?;                              // early return on Err
  Ok(n.div(2))                             // method call: needs n's type
}
func f() -> Int = (|| read_count())();     // must be rejected: R-func-calls-proc
```

### A. Surface rules throughout

Every surface construct has its own typing rule and its own evaluation rule (one for `?`, one for method calls, one
for `for`, and so on); there is no core.

- **Easy:** rules map one to one onto the specification's chapters; rule IDs attach to what users wrote; there is no
  translation to trust.
- **Hard:** every convenience adds cases to every proof (progress, preservation, purity), so the proofs grow with
  ergonomics; early exits such as `?` need evaluation machinery for "the enclosing function".
- **Prior art (recalled):** the Definition of Standard ML, which adds a small table of syntactic derived forms.

### B. Typed elaboration into an explicitly typed core

The static rules are written over the surface and also produce a core term: `Γ ⊢ e : τ ⇝ c` reads "in context Γ,
surface `e` has type τ and elaborates to core `c`". The core is **explicitly typed**: every binder, type argument,
and purity argument is written out, so checking core needs no inference. The dynamic rules are written over the core
only. Two theorems connect them: the core is sound, and elaboration produces well-typed core.

- **In the scenario:** the rule for `?` checks the types and emits a `match` with an early return in the core; the
  closure case reports `R-func-calls-proc` from a surface rule, where the user wrote it.
- **Easy:** rule IDs ([D0018](D0018-diagnosis-and-rule-ids.md)) stay on surface constructs; new sugar adds
  elaboration rules but no core cases, so core proofs stay small and stable; the structure matches a compiler with a
  typed intermediate representation.
- **Hard:** two layers of rules; the specification's numbered dynamic steps ([D0017](D0017-rule-style.md)) describe
  surface behavior while the formal dynamics are over core, so the correspondence passes through elaboration.
- **Prior art:** Harper and Stone's interpretation of Standard ML elaborates into an explicitly typed internal
  language (verified, [R0004](../research/R0004-formalization-prior-art-and-pilots.md)); GHC type-checks Haskell and
  produces typed Core, which it can re-check (recalled).

### C. Untyped desugaring, then everything over the core

The surface is rewritten into the core before any type checking; typing and evaluation are both over the core.

- **Easy:** the smallest formal system, with one typing judgment.
- **Hard:** type-directed sugar (method calls such as `n.div(2)`, implicit purity arguments) cannot be desugared
  without types, so the core needs inference after all; errors are diagnosed on code the user did not write.
- **Prior art (recalled):** Scheme and Racket expand to a small core, which suits untyped languages.

A core whose elaboration is specified only in prose was not offered, because it contradicts D0021: an elaboration bug
would escape the theorems.

| | A Surface | B Typed elaboration | C Desugar first |
| --- | --- | --- | --- |
| Rule IDs on what users wrote | yes | yes | no |
| Proof cases grow with every convenience | yes | no (elaboration only) | no |
| Type-directed sugar | yes | yes | poorly |
| Specification steps ↔ formal dynamics | direct | via elaboration | via desugaring |

Recommendation at the time: **B**, as the only option that keeps diagnostics on what users write while keeping the
proved core small enough to survive several milestones of new conveniences.

## Choice

**B.**
1. The static semantics is a set of **elaboration rules** over the surface language, of the form
   `Γ ⊢ e : τ ⇝ c`. Each rule both states a legality condition and produces a term of the core. Every premise whose
   failure rejects a program carries its rule ID ([D0018](D0018-diagnosis-and-rule-ids.md)).
2. The **core** is an explicitly typed internal language: every binder, type instantiation, and purity
   instantiation ([D0008](D0008-purity.md)) is written in the core term. Core typing is syntax-directed and needs no
   inference.
3. The dynamic semantics is defined over the core only. The meaning of a surface program is the meaning of its
   elaborated core.
4. In a chapter whose dynamic aspect is formally complete, the numbered steps of the prose
   ([D0017](D0017-rule-style.md)) correspond to the core rules through the chapter's elaboration rules, and the
   chapter states that correspondence.

## Rationale

Rejections must name rules about constructs users write, which puts the static rules on the surface. The proofs,
however, should not grow with every convenience, which puts the dynamics and the soundness theorem on a small core.
Typed elaboration gives both, and it is the shape of a real compiler front end, which serves tooling-first
([D0002](D0002-purpose-and-domain.md)) and the self-hosted compiler.

## Consequences

- **M03–M09** define each surface construct by elaboration rules and add core constructs only when no elaboration
  into existing ones exists.
- **M05/M06:** generics and purity parameters appear in the core as explicit type and purity abstraction and
  application.
- **The inference algorithm** that realizes the elaboration rules is specified separately (see
  [D0023](D0023-claimed-meta-properties.md), property 6).
- **Every chapter** of the specification describes surface behavior; the core appears only in `formal/` and in
  notes.

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority),
  [§1.3.4](../../spec/01-introduction.md#134-rule-style)
- Grammar rules: none (the core has no surface grammar)
- Formal rules: [formal/README.md](../../spec/formal/README.md); [static.md](../../spec/formal/static.md) (the
  elaboration and core typing judgments); [dynamic.md](../../spec/formal/dynamic.md) (over the core)
- Examples / tour: none
