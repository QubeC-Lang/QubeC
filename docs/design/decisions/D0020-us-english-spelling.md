# D0020: US English spelling everywhere

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

Which English spelling do the specification, the documents, and the names in the standard library and tools use?
Until now the repository mixed both: about 24 British forms (`behaviour`, `labelled`, `colouring`, `licence`) and
about 50 US forms (`artifact`, `recognized`, `behavior`, `summarize`). Mixed spelling breaks search in the
specification, and library names are permanent API commitments.

## Options considered

The scenario for every option: one specification sentence and two library names.

```
Spec:     "A panic is defined behavior/behaviour, not a rejection."
Library:  Str.normalize() / Str.normalise()      Terminal.color / Terminal.colour
```

### A. US English everywhere

The specification, the formal files, every document, commit messages, and standard-library and tool names use US
English. Exceptions: proper names and titles of external works, and verbatim quotations.

- **Easy:** one rule; it matches the specifications we cite and the APIs users already know (`color` in CSS,
  `normalize` in Unicode APIs).
- **Hard:** about 24 words change now; writers used to British spelling adapt.
- **Prior art (recalled):** almost every major language ecosystem uses US spelling in identifiers.

### B. British (or Oxford) English everywhere

The same scope, in British spelling (Oxford: `-ize`, but `colour`, `behaviour`).

- **Easy:** natural for British-trained writers.
- **Hard:** library names diverge from other ecosystems; about 50 words change now.

### C. US spelling for the specification and names only

Normative text and public names use US spelling; the tour, decision records, and notes may use either.

- **Easy:** fixes what matters for search and APIs.
- **Hard:** mixing continues in half the repository; cross-document search stays unreliable.

Recommendation at the time: **A**, for simplicity and alignment with the APIs users know.

## Choice

**A.** US English spelling is used in the specification and formal files, in every document of the repository, in
commit messages, and in the names of the standard library and tools. The exceptions are proper names and titles of
external works, and verbatim quotations from external sources.

## Rationale

One rule is simpler than two, and US spelling matches the specifications we cite and the names programmers already
use. The change was cheap now and would only grow later.

## Consequences

- **This task** converts the existing British forms in the repository (for example `behaviour` → `behavior`,
  `labelled` → `labeled`, `colouring` → `coloring`, `licence` → `license`).
- **M14, M15:** library and tool names follow this rule (`color`, `normalize`, `initialize`).
- **Reviews** check spelling along with the other conventions.

## Affected artifacts

- Spec: [§1.3.7](../../spec/01-introduction.md#137-spelling); [conventions](../../spec/README.md)
- Grammar rules: none
- Formal rules: none
- Examples / tour: every document (spelling sweep)
