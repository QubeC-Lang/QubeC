# D0080: The grammar is checked in three stages: structure, a reference lexer, and conflicts

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M02 / T0014 |

## Question

M02's exit criteria require the lexical grammar to be complete and machine-checked (see
[roadmap.md, M02](../roadmap.md#m02-lexical-structure)). What does the check verify, and when is each part needed? A
grammar can be wrong as a document (an undefined name, a stale quotation), wrong about real text (it accepts a number
we meant to reject), or ambiguous for a parser. Each needs more machinery than the last.

## Options considered

The scenario for every option: T0017 adds a production for integers, and a reject test `1__0` that expects a lexical
rule ID ([D0082](D0082-grammar-rejection-rules.md)). Rule names are illustrative.

### A. A staged checker, each stage added when its inputs exist

- **Stage 1, structure (defined in T0014):** the file parses in the notation of
  [D0078](D0078-w3c-ebnf-notation.md); the layer and naming rules of [D0079](D0079-two-grammar-layers.md) hold;
  every production is reachable, and every quotation in the specification matches the file.
- **Stage 2, a reference lexer (T0015–T0019):** a program that interprets the lexical grammar directly divides text
  into tokens and trivia; every quoted string in a syntactic production is one token; every lexical example in the
  specification lexes; every lexical reject test fails with the rule ID it expects.
- **Stage 3, conflicts (M03):** the syntactic grammar is conflict-free in the class M03 chooses, and the examples
  parse.

```
$ <check> docs/spec/grammar/qubec.ebnf
ok: 41 productions, 9 tokens, 3 trivia; 12 quotations match; 7 rule IDs
tests/conformance/lexical/int-double-underscore.qbc: expect reject R-number-malformed ... ok
```

- **Easy:** the lexical grammar is executable from M02 on, independently of both implementations.
- **Hard:** the most code, a few hundred lines by the pilot's measure
  ([R0012](../research/R0012-grammar-notation-and-checking.md)), and a third lexer to keep in agreement, which is its
  purpose.
- **For implementers:** a disagreement between the host interpreter's lexer and `qubecc`'s lexer
  ([D0029](D0029-permanent-host-implementation.md)) is settled by the grammar itself.

### B. Structure only in M02; the host interpreter's lexer is the executable check

Stage 1 as in A; nothing runs the grammar on text, and lexical tests run on the host interpreter from I1.

- **Easy:** less code now.
- **Hard:** errors in the grammar are found only when the host lexer disagrees with it, and someone must decide which
  is wrong; lexical reject tests are unchecked until I1; M02 closes with a grammar never run on text.

### C. Translate the grammar for an existing lexer or parser generator

- **Easy:** less code of our own.
- **Hard:** generators' lexers are based on regular expressions; `A - B` and recursive lexical productions do not
  translate, and the tool's semantics would replace W3C's.

Recommendation at the time: **A**, because stage 2 is what makes "machine-checked" mean "tested against text", gives
lexical reject tests a meaning before I1, and referees between the two lexers we must keep in agreement.

## Choice

**A.** The grammar checker has three stages.
1. **Stage 1, structure.** It verifies that:
   - the file parses in the notation of D0078, with D0078's rules 2–4 and 6 (no validity annotations, `A - B`
     parenthesized inside sequences, `-` only in lexical productions with a finite right operand, a decision comment
     on every production);
   - every name is defined exactly once, every name used is defined, and every production is reachable from
     `TOKEN`, `TRIVIA`, or `SourceFile`;
   - the rules of D0079 hold: names in the two styles, no syntactic name in a lexical production, no helper in a
     syntactic production;
   - every decision a production cites exists;
   - every production quoted in `docs/spec/` matches the file verbatim;
   - every rule ID is defined exactly once in the specification, and every rule ID used in tests, formal rules,
     decisions, or examples is defined.
2. **Stage 2, the reference lexer.** It interprets the lexical grammar to divide text into tokens and trivia, and
   verifies that every quoted string in a syntactic production is exactly one token, that every lexical example in
   the specification lexes, and that every lexical reject test is rejected with the rule ID it expects. Until T0019
   specifies tokenization, it divides text by longest match, as a provisional rule of the tool.
3. **Stage 3, conflicts.** M03 chooses the grammar class and how stage 3 checks it; the examples in `examples/`
   parse.
4. Stage 1 is defined in T0014 and is built during M02, before T0015 closes. Stage 2 grows with T0015–T0019. Stage 3
   is built in M03.

## Rationale

Only a check that runs the grammar on text can show that the grammar says what we mean, and only an executable
grammar can referee between the two lexers that the permanent host and the self-hosted compiler bring. Building each
stage when its inputs exist keeps the work proportional: stage 1 is useful as soon as productions appear, stage 2
grows token by token, and stage 3 waits for the syntax it checks.

## Consequences

- **M02's exit criterion** "lexical grammar machine-checked" is met by stages 1 and 2.
- **T0015–T0019:** each lexical rule comes with examples and reject tests that stage 2 runs; T0019 replaces the
  provisional longest-match rule with the specified tokenization.
- **Conformance tests:** lexical reject tests start in `tests/conformance/` with T0015, with the header of
  [D0018](D0018-diagnosis-and-rule-ids.md).
- **M03:** builds stage 3 and chooses its grammar class.
- **I1:** the host interpreter's lexer must pass the same lexical tests.

## Affected artifacts

- Spec: [§1.3.6](../../spec/01-introduction.md#136-grammar-notation) (a note on checking)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [tools/grammar/README.md](../../../tools/grammar/README.md)
