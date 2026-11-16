# D0016: Authority is per section: formal rules govern only where an aspect is formally complete

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

The specification describes QubeC twice: in prose in its chapters, and as inference and evaluation rules in
`formal/`. When the two disagree, because one of them has a defect, which one defines QubeC? The answer says what a
conforming implementation follows until the defect is fixed, and whether our proofs are about QubeC or about a
model of it. It must not prejudge T0005 (how far we formalize). It builds on
[D0015](D0015-spec-audience-and-scope.md).

## Options considered

The scenario for every option: the prose says a `func` must not call a `proc` ([D0008](D0008-purity.md)), but a
defect in the formal application rule forgets that calling a closure performs the closure's effects. The formal
rules then accept this program, and the prose rejects it (provisional syntax):

```
proc read_count() -> Int { … }
func f() -> Int = (|| read_count())();   // a closure that calls a proc, called at once
```

### A. Prose governs everywhere

The formal rules are a model that must agree with the prose.

- **During the defect:** `f` is rejected; the model is fixed.
- **Easy:** one readable source of truth; formal work can lag behind safely.
- **Hard:** soundness proofs are about the model, not about QubeC.
- **Locks in / rules out:** nothing for T0005.
- **Prior art (recalled):** the JLS and the Go specification (prose only); the Ferrocene/Rust specification, with
  separate non-normative formal models.

### B. Formal rules govern everywhere

The formal rules are the definition, and the prose explains them.

- **During the defect:** `f` is accepted until the rule is fixed.
- **Easy:** proofs apply to QubeC; no ambiguity.
- **Hard:** every normative rule needs a formal counterpart before it means anything, so readers effectively read
  inference rules.
- **Locks in / rules out:** forces T0005 to formalize everything.
- **Prior art (recalled):** the Definition of Standard ML, admired, but its language stayed small and slow to
  change, and its Basis library is specified in prose.

### C. Both, declared equivalent

Every rule is given in both forms, and the specification declares them equivalent; a disagreement is a defect with
no tie-breaker.

- **During the defect:** undefined until the fix.
- **Easy:** readers choose either form; proofs apply.
- **Hard:** complete double coverage of everything, and no rule for the interim.
- **Locks in / rules out:** forces T0005 to formalize everything.
- **Prior art:** WebAssembly, whose rules "are given in two *equivalent* forms" (verified,
  [R0003](../research/R0003-spec-conventions-prior-art.md)), maintained by a working group with a reference
  interpreter.

### D. Per section, with promotion

Each specification chapter states a **formal status** for its static semantics and for its dynamic semantics:
*complete*, *partial*, or *none*. Where an aspect is *complete*, the formal rules govern and the prose explains
them; elsewhere the prose governs. Moving an aspect to *complete* (a **promotion**) is its own decision, with a
checklist.

```
# 9. Functions and procedures
Status: Draft · Formal: static complete, dynamic none
```

- **During the defect:** if §9's static status is *none* or *partial*, `f` is rejected and the formal rule is fixed.
  If it is *complete*, `f` is accepted until the urgent fix lands.
- **Easy:** authority grows as the formal work matures, whatever T0005 decides.
- **Hard:** a status field per chapter, a promotion step, and the risk that a defect in a promoted rule becomes
  binding.
- **Locks in / rules out:** nothing for T0005; its outcome bounds what can ever be promoted.
- **Prior art (recalled):** no language specification we know of does exactly this. Verified systems such as
  CompCert and seL4 likewise limit their claims to what is formalized (an analogy only).

| | A Prose | B Formal | C Equivalent | D Per section |
| --- | --- | --- | --- | --- |
| `f` during the defect | rejected | accepted | unclear | depends on the status |
| Proofs are about QubeC | no (a model) | yes | yes | yes, for promoted aspects |
| Formal coverage required | none | all | all, in both forms | grows over time |
| Constrains T0005 | no | fully | fully | no |

Recommendation at the time: **D**, narrowly over A. D leaves T0005 free and makes the proofs we do write count for
QubeC itself, at the cost of one status line per chapter. A was the alternative if the formal rules were to stay a
companion model.

## Choice

**D.**
1. Each specification chapter's status line states a **formal status** separately for its **static** semantics
   (what is legal) and its **dynamic** semantics (what happens at run time): *complete*, *partial*, or *none*. For
   example, `Status: Draft · Formal: static partial, dynamic none`.
2. Where an aspect is **formally complete**, the rules in `formal/` govern that aspect, and the prose explains them.
   Everywhere else the prose governs, and the formal rules are a model that must agree with it.
3. Any disagreement is a defect and is fixed. Until the fix lands, the governing text applies.
4. **Promotion** of an aspect to *complete* is recorded as a decision. It requires:
   - every normative rule of the aspect has formal rules;
   - every way a program can fail those rules is tagged with a rule ID ([D0018](D0018-diagnosis-and-rule-ids.md));
   - the meta-properties covering the aspect have at least a proof sketch in `formal/metatheory.md`, or a
     mechanized proof if T0005 chooses mechanization.

## Rationale

Safety ranks first, so our soundness claims should be about QubeC itself, not only about a model. Requiring full
formal coverage up front (B, C) would cost too much before anything is implemented, and would decide T0005 in
advance. Per-section authority serves both. The promotion checklist keeps a chapter from becoming formally governed
before its rules have been checked.

## Consequences

- **Every chapter** carries a `Formal:` field in its status line; §1 and the conventions say so.
- **T0005:** its formalization depth bounds which aspects can ever be promoted.
- **Defects in promoted rules become binding** until fixed; the promotion checklist is the mitigation, and such
  fixes take priority.
- **Every later milestone** that writes formal rules tags failing premises with rule IDs (D0018).

## Affected artifacts

- Spec: [§1.3.3](../../spec/01-introduction.md#133-formal-status-and-authority);
  [conventions](../../spec/README.md); [spec-section template](../templates/spec-section.md)
- Grammar rules: none
- Formal rules: [formal/README.md](../../spec/formal/README.md) (authority and promotion);
  [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: none
