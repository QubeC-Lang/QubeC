# D0018: Every violation is diagnosed; rejection rules have stable mnemonic IDs that must be reported

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

Three linked questions about programs the specification rejects:
1. Must every violation of a rule be diagnosed, or may some rules need no diagnostic?
2. Does the specification say *which* rule a rejected program broke, through a stable name that compilers report?
3. If so, what do the names look like?

The answers matter for conformance tests (they should check the reason a program is rejected), for tooling (an
error that can link to the specification), and for the rules later milestones write. They build on NG-9 (no
undefined behavior in safe code) and NG-10 (no silently ignorable errors) of [D0005](D0005-non-goals.md), on
tooling-first ([D0002](D0002-purpose-and-domain.md)), and on [D0016](D0016-authority-per-section.md).

## Options considered: must every violation be diagnosed?

The scenario: [D0011](D0011-local-mutation-in-functions.md) lets a `func` mutate values it created, if no mutation
is observable (provisional syntax).

```
func sorted(xs: List[Int]) -> List[Int] = {
  let ys = xs.copy();
  ys.sort();               // fine: ys was created here
  ys
};
func sneaky(xs: List[Int]) -> Int = {
  let ys = same_list(xs);  // a helper that returns xs itself
  ys.clear();              // mutates the caller's list: observable
  0
};
```

### A. Always diagnosed

A conforming implementation rejects and reports every program that breaks a rule the specification states. No rule
is "no diagnostic required". Every rule must therefore be stated so that it can be checked. D0011's rule is stated as
a concrete, conservative discipline rather than as "no mutation is observable".

- **`sneaky`:** rejected, with a diagnostic. Some harmless programs are rejected too, and the rule says why.
- **Easy:** "it compiled" means "it obeys every rule"; tests are clear-cut; decidable rules help formalization.
- **Hard:** for hard properties, the specification states the checking discipline itself; rules get more technical.
- **Note:** a milestone may still choose to check a property at run time, as a defined panic. That is dynamic
  semantics, not an unreported violation.
- **Prior art (recalled):** Java, Go (mostly), and Rust in practice; Rust's borrow checker is a conservative,
  decidable discipline.

### B. Bounded "no diagnostic required"

A rule may be marked as needing no diagnostic. The specification bounds what may then happen: the program is
rejected, or it runs and possibly panics, but never has undefined behavior.

- **`sneaky`:** may compile; the caller's list is cleared, and the function was not really pure.
- **Easy:** rules are stated as the property wanted; implementations check what they can afford.
- **Hard:** "compiled" no longer means "valid"; implementations may disagree; purity guarantees become soft.
- **Prior art:** Go's rare "A compiler need not report an error if …" (verified,
  [R0003](../research/R0003-spec-conventions-prior-art.md)).

The unbounded C++ form, where a violating program receives "no requirement" at all (verified, R0003), was not an
option, because it is undefined behavior by another name and NG-9 excludes it.

Recommendation at the time: **A**, because Safety and NG-9 and NG-10 point there, and tool builders benefit when
"accepted" has one meaning across implementations.

## Options considered: named rejection rules

The scenario: a conformance test, and what the compiler prints.

```
// test: spec §9.4, D0008
proc read_count() -> Int { … }
func f() -> Int = read_count();
```

### A. Accept or reject only

The specification says "MUST reject"; the reason is up to the implementation (`// expect: reject`).

- **Easy:** the least specification text.
- **Hard:** tests cannot check the reason, and diagnostics cannot link to the specification.
- **Prior art (recalled):** the JLS, Go, WebAssembly. Rust's and C#'s error codes are compiler conventions.

### B. Named rules, reporting required

Each rejection rule has a stable ID. A conforming implementation reports the ID of at least one rule the program
violates.

```
§9.4.2 [R-func-calls-proc] The body of a `func` MUST NOT call a `proc`. [D0008]
// expect: reject R-func-calls-proc
error[R-func-calls-proc]: func `f` calls proc `read_count`
  --> main.qbc:2:19
```

- **Easy:** tests check the reason; tools link errors to the specification; the diagnostic catalog of M15 has a
  stable backbone.
- **Hard:** every rejection rule needs a permanent name; a reject test should break exactly one rule; a small duty
  on other implementations.
- **Prior art (recalled):** no mainstream specification requires it; C requires a diagnostic for a constraint
  violation without naming the constraint; Ada's test suite ties tests to manual paragraphs.

### C. Named rules, reporting recommended

The same IDs as B, but reporting them is only recommended; tests check an ID only when one is reported.

- **Easy:** the same linking as B, with no duty on other implementations.
- **Hard:** the reason check becomes optional.

Recommendation at the time: **B**, because it fits tooling-first, and our own implementation is the main consumer.

## Options considered: the ID format

### A. Mnemonic, one flat namespace

`R-` followed by lowercase words joined by hyphens, subject first, then the problem: `R-func-calls-proc`,
`R-string-unterminated`. No section number, no phase.

- **Easy:** readable in test headers and errors; survives reorganization.
- **Hard:** names must be chosen well and checked for uniqueness.

### B. Numeric codes

`E0001`, `E0002`, … in order.

- **Easy:** short, unique, familiar from Rust and C#.
- **Hard:** opaque without a lookup.

### C. Mnemonic, grouped by area

`purity.func-calls-proc`, `lex.string-unterminated`.

- **Easy:** visible grouping.
- **Hard:** the area becomes part of a permanent name, even if the rule later moves.

### D. Decide in M02

Use illustrative names until the first real rejection rules.

- **Easy:** defer until real IDs exist.
- **Hard:** illustrative names may need renaming.

Section-based IDs (`R9.4.2-1`) were not offered, because renumbering would change them.

Recommendation at the time: **A**, readable where IDs are used most and stable under reorganization. Numeric
display codes remain possible in M15.

## Choice

1. **Every violation is diagnosed.** A conforming implementation MUST reject, at compile time, every program that
   violates a rejection rule, and MUST diagnose it. No rule of the specification is exempt from diagnosis. Rules are
   therefore stated as checkable conditions. Run-time failures such as panics are not rejections; they are defined
   behavior.
2. **Rejection rules and rule IDs.** Every **rejection rule** (a condition under which a program MUST be rejected)
   carries a **rule ID**, written in brackets at the start of the rule.
   - A rule ID is never reused or renamed once published. A rule that no longer applies keeps its ID, marked
     retired.
3. **Reporting is required.** When a conforming implementation rejects a program, it MUST report the ID of at least
   one rejection rule the program violates, and MAY report more. Wording, layout, display codes, and fix suggestions
   are not specified; they belong to M15.
4. **Format.** A rule ID is `R-` followed by one or more words joined by single hyphens. Each word consists of
   lowercase ASCII letters and digits and begins with a letter. The words name the subject first, then the
   problem (`R-const-cycle`, `R-tailcall-position`). An ID contains no section number and no phase. Rule IDs form
   one namespace across the whole specification.
5. **Conformance tests.** A reject test's header reads `expect: reject <rule-id>`, and a reject test SHOULD violate
   exactly one rejection rule.
6. **Formal rules.** Every premise or side condition whose failure rejects a program is tagged with the rule ID it
   enforces. In a formally complete aspect ([D0016](D0016-authority-per-section.md)), a way to fail that no rule ID
   covers is a specification defect.

## Rationale

A silently accepted ill-formed program has no defined meaning, which NG-9 and NG-10 exclude, so every violation is
diagnosed. Named rules with required reporting follow from tooling-first: threading an ID through a check is cheap
for our own implementation, conformance tests gain a check of the reason, and editors and the diagnostic catalog get
a stable link to the specification. We accept that this is unusual among language specifications. Mnemonic IDs in a
flat namespace are the only format that is both meaningful and stable whatever happens to the specification's
structure later.

## Consequences

- **Spec §1.2** states the diagnosis and reporting requirements; **§1.3.5** states the ID format.
- **M02:** decides how lexical and syntactic violations are named. Each lexical rejection rule gets an ID; how parse
  failures are grouped under IDs is part of that work.
- **M07, M08, M10:** rules about mutation, effects, and race freedom are stated as checkable disciplines. In
  particular, M07 states D0011's "no observable mutation" as a concrete, conservative rule.
- **M15:** maps rule IDs to diagnostic codes, messages, and documentation; it may add short display codes alongside
  the IDs.
- **Conformance tests (M16):** reject tests name the rule they expect.
- **Self-hosting:** the self-hosted checker can be organized around rule IDs, which also indexes its diagnostic
  tests.

## Affected artifacts

- Spec: [§1.2](../../spec/01-introduction.md#12-conformance),
  [§1.3.5](../../spec/01-introduction.md#135-rejection-rules-and-rule-ids); [conventions](../../spec/README.md);
  [spec-section template](../templates/spec-section.md)
- Grammar rules: none yet (M02)
- Formal rules: tagging convention in [formal/README.md](../../spec/formal/README.md)
- Examples / tour: none
