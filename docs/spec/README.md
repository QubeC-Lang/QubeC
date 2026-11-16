# QubeC Specification

Status: **Draft.** No normative chapter is written yet. These conventions apply from the first one.

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
6. **Non-normative material** is labelled *Note (non-normative)* or *Example (non-normative)*. Everything else in a
   chapter is normative.
7. **Grammar.** [`grammar/qubec.ebnf`](grammar/qubec.ebnf) is the source of truth. Chapters quote its productions
   verbatim. Until M02 decides the EBNF dialect, the grammar uses W3C-style EBNF (XML 1.0, section 6) and is marked
   provisional.
8. **Formal rules** live in [`formal/`](formal/README.md), in Markdown with LaTeX math. Chapters name the rules that
   govern them.
9. **Examples** in chapters use decided syntax only. Undecided syntax is labelled *provisional syntax*.

New chapters start from [the spec-section template](../design/templates/spec-section.md).

## Contents

| Chapter | Topic | Status |
| --- | --- | --- |
| — | none yet | |

Related: [grammar](grammar/qubec.ebnf) · [formal rules](formal/README.md) · [decisions](../design/decisions/README.md)
· [open questions](../design/open-questions.md) · [glossary](../glossary.md)
