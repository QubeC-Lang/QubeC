# QubeC Specification

Status: **Draft.** Chapter 1 (Introduction) is written. The conventions below summarize
[§1.3](01-introduction.md#13-notation-and-conventions), which states them normatively.

## Conventions

1. **Requirement keywords.** The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT,
   RECOMMENDED, NOT RECOMMENDED, MAY, and OPTIONAL are to be interpreted as described in BCP 14
   ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174)) when,
   and only when, they appear in all capitals.
2. **Numbering.** Chapters are files named `NN-<topic>.md`, ordered by dependency: a chapter uses only terms and
   rules from itself and earlier chapters. Sections are numbered `NN.M`, subsections `NN.M.K`.
3. **Citations.** Every normative rule cites the decisions it rests on, in brackets: `[D0012]`. A rule with no live
   decision behind it is a defect.
4. **Definitions.** Every term is defined before it is used. A term is set in **bold** where it is defined, and is
   listed in the [glossary](../glossary.md) with a link to its definition.
5. **Provisional rules** depend on an open question and are marked *Provisional (OQ-nnn)*.
6. **Non-normative material** is labeled *Note (non-normative)* or *Example (non-normative)*. Everything else in a
   chapter is normative.
7. **Grammar.** [`grammar/qubec.ebnf`](grammar/qubec.ebnf) is the source of truth. Chapters quote its productions
   verbatim. It is written in W3C EBNF (XML 1.0, section 6), in two layers: lexical productions in `UPPER_SNAKE_CASE`
   over characters, with `TOKEN` and `TRIVIA` listing the kinds of token and trivia, and syntactic productions in
   `UpperCamelCase` over tokens, starting from `SourceFile`. Every production cites its decisions in a trailing
   comment. Parse failures are `R-syntax`; lexical failures have named rules, with `R-token-invalid` as the fallback
   ([§1.3.6](01-introduction.md#136-grammar-notation), [§1.3.8](01-introduction.md#138-rejection-by-the-grammar)). The
   grammar checker is in [`tools/grammar/`](../../tools/grammar/README.md).
8. **Formal rules** live in [`formal/`](formal/README.md), in Markdown with LaTeX math. Chapters name the rules that
   govern them. Elaboration rules over the surface define the static semantics and translate programs into an
   explicitly typed core. Core rules define the core's typing and the dynamic semantics. A core rule is governed by
   its definition in the Lean 4 mechanization, `formal/lean/`, which its Markdown rendering names
   ([D0022](../design/decisions/D0022-typed-elaboration-into-core.md),
   [D0026](../design/decisions/D0026-lean-governs-core-rules.md)).
9. **Examples** in chapters use decided syntax only. Undecided syntax is labeled *provisional syntax*.
10. **Audience and scope.** One specification for programmers and implementers, covering the language and its core
    library; it does not teach ([D0015](../design/decisions/D0015-spec-audience-and-scope.md)).
11. **Status line and authority.** Every chapter starts with `Status: <Draft · Review · Stable> · Formal: static
    <complete · partial · none>, dynamic <complete · partial · none>`. Formal rules govern an aspect only where it is
    *complete*; elsewhere the prose governs ([D0016](../design/decisions/D0016-authority-per-section.md)). Only the
    sequential language can be formally complete; concurrency cannot
    ([D0021](../design/decisions/D0021-formal-target-sequential-language.md)).
12. **Rule style.** Static rules are declarative; dynamic behavior is written as numbered steps wherever order is
    observable ([D0017](../design/decisions/D0017-rule-style.md)).
13. **Rejection rules** carry a rule ID in brackets at their start, `[R-subject-problem]`: lowercase ASCII words
    joined by hyphens, one namespace, never reused or renamed. Every violation is diagnosed, and a rejecting
    implementation reports at least one ID ([D0018](../design/decisions/D0018-diagnosis-and-rule-ids.md)).
14. **Spelling.** US English ([D0020](../design/decisions/D0020-us-english-spelling.md)).

New chapters start from [the spec-section template](../design/templates/spec-section.md).

## Contents

| Chapter | Topic | Status |
| --- | --- | --- |
| [1](01-introduction.md) | Introduction: scope, conformance, notation and conventions | Draft |

Related: [grammar](grammar/qubec.ebnf) · [formal rules](formal/README.md) · [decisions](../design/decisions/README.md)
· [open questions](../design/open-questions.md) · [glossary](../glossary.md)
