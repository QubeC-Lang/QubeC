<!--
Template for a specification chapter. Copy to docs/spec/NN-<topic>.md, keeping chapters in dependency order, and
add it to the contents in docs/spec/README.md. Conventions are in docs/spec/README.md.
- Normative text uses the RFC 2119 / RFC 8174 keywords (MUST, MUST NOT, SHOULD, MAY, …) in capitals.
- Every normative rule cites its decisions, e.g. "[D0012]".
- Every rejection rule starts with its rule ID, e.g. "[R-const-cycle]" (D0018).
- Static rules are declarative; dynamic behavior is numbered steps wherever order is observable (D0017).
- Spelling is US English (D0020).
- Every term is defined (in bold, at its definition) before it is used, and added to docs/glossary.md.
- Provisional rules are marked "Provisional (OQ-nnn)".
- Non-normative material is labeled "Note (non-normative)" or "Example (non-normative)".
-->
# NN. <Chapter title>

Status: Draft · Formal: static none, dynamic none
<!-- Status: Draft · Review · Stable. Formal status per aspect: complete · partial · none (D0016). -->

## NN.1 <Section title>

<!-- Definitions first. -->

A **<term>** is … [Dnnnn]

<!-- Then the rules. -->

1. [R-subject-problem] A program MUST NOT … [Dnnnn]
<!-- Dynamic behavior, where order is observable, as steps: "To evaluate …: 1. … 2. …" -->
2. … Provisional (OQ-nnn).

> **Note (non-normative).** <!-- explanation, rationale pointer -->

> **Example (non-normative).**
>
> ```qubec
> // a short program
> ```

**Grammar.** <!-- quote the productions from grammar/qubec.ebnf verbatim, naming them -->

**Formal rules.** <!-- name the rules in formal/static.md or formal/dynamic.md that govern this section -->
