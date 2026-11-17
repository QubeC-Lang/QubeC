# D0077: A source location is written as source name, line, and column

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

With source names decided ([D0076](D0076-source-names.md)), what follows the name in a location, as written in the
report line `panic: <kind>: <message> at <location>` ([D0059](D0059-report-line-and-backtrace.md))? This settles the
location part of
[OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter). What a
column counts belongs to M02, and which point of an operation is its position is stated with each construct (M03,
M05).

## Options considered

In every option, numbers are decimal, lines start at 1, and nothing in a location depends on the platform. The
scenario for every option: line 12 of `wc/src/count.qbc` is `    let w = words[i] + sizes[j];`, and `sizes[j]` fails.
The kind and message are placeholders.

### A. `name:line:column`

```text
panic: <kind>: <message> at wc/src/count.qbc:12:24
```

- **Easy:** tells apart two failing operations on one line (`words[i]` would be `12:15`); editors and terminals already
  turn `file:line:column` into a link.
- **Hard:** the column depends on M02's counting rule.
- **For implementers:** a line and a column per failing operation, which D0050 already requires in the core and the
  bytecode.
- **Prior art:** Rust panics print `file:line:column` (verified by a pilot,
  [R0011](../research/R0011-units-reproducibility-and-source-names.md)); GCC, Clang, and rustc diagnostics use the same
  form (recalled).

### B. `name:line`

```text
panic: <kind>: <message> at wc/src/count.qbc:12
```

- **Easy:** independent of how columns are counted, so tabs and Unicode cannot make implementations disagree.
- **Hard:** `words[i] + sizes[j]` is ambiguous.
- **Prior art:** Go's tracebacks give only the line (verified by a pilot, R0011).

### C. A span, `name:line:column-line:column`

```text
panic: <kind>: <message> at wc/src/count.qbc:12:24-12:31
```

- **Easy:** the most precise; editors could underline it.
- **Hard:** every implementation must agree where each failing operation ends, one more thing to specify per construct
  and to test.
- **Prior art (recalled):** rustc's JSON diagnostics carry spans; no mainstream panic report does.

Recommendation at the time: **A**: precise enough for lines with several operations, the form tools already parse,
and no cost beyond what D0050 requires.

## Choice

**A.**
1. A source location is written `<source name>:<line>:<column>`, where line and column are decimal numbers without
   leading zeros. The first line of a file is line 1, and the first column of a line is column 1.
2. What a column counts, and how line ends are recognized, are specified with the lexical structure (M02).
3. Which position of a failing operation is its location is specified with the operation (M03, M05, and later
   milestones).

## Rationale

A line and a column identify the failing operation even on a crowded line, at no cost beyond the positions D0050
already requires the core and bytecode to carry, and the form is the one editors, terminals, and other tools already
understand.

## Consequences

- **Spec:** [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rule 7;
  [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) rule 5.
- **[OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter):** the
  location's text is decided, apart from M02's column rule; the kinds, messages, line breaks in messages, and the
  delimiter stay open.
- **M02:** defines what a column counts (for example code points), how tabs count, and what ends a line.
- **M03, M05, and later:** each operation that can fail states its position.
- **Conformance suite:** expected report lines contain exact locations.

## Affected artifacts

- Spec: [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rule 7;
  [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) rule 5
- Grammar rules: none
- Formal rules: none (a note in [dynamic.md](../../spec/formal/dynamic.md))
- Examples / tour: none
