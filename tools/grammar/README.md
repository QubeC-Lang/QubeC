# Grammar checker

The grammar checker reads [`docs/spec/grammar/qubec.ebnf`](../../docs/spec/grammar/qubec.ebnf) and checks it against the
rules of spec [§1.3.6](../../docs/spec/01-introduction.md#136-grammar-notation) and
[§1.3.8](../../docs/spec/01-introduction.md#138-rejection-by-the-grammar). It is decided by
[D0080](../../docs/design/decisions/D0080-staged-grammar-checker.md) (what it checks) and
[D0081](../../docs/design/decisions/D0081-ocaml-grammar-checker.md) (how it is built).

**Status:** not built yet. Stage 1 is built during M02, before T0015 closes; stage 2 grows with T0015–T0019; stage 3
comes with M03.

## How it is built

- One OCaml program, `check.ml`, run as a script from the repository root: `ocaml tools/grammar/check.ml`. It uses
  only the libraries of the standard OCaml distribution, at the OCaml version pinned for the host compiler, with no
  build system and no packages.
- It shares no code with the host implementation or with `qubecc`. It is a third, independent reading of the grammar,
  and the conformance tests hold all three together.
- Any Unicode property it needs comes from Unicode Character Database files of the version the specification pins,
  stored in or generated into the repository, never from the OCaml toolchain's own tables.
- It exits with status 0 when every check passes, and 1 otherwise, after listing every failure with its file and
  line.

## Stage 1: structure

1. **Notation.** The file parses as the EBNF of XML 1.0 (Fifth Edition), section 6
   ([D0078](../../docs/design/decisions/D0078-w3c-ebnf-notation.md)):
   - no `[ wfc: … ]` or `[ vc: … ]` annotations;
   - a difference `A - B` that is one item of a longer sequence is in parentheses;
   - `-` appears only in lexical productions, and its right operand is finite: it contains no `*` and no `+`, and no
     reference in it leads, directly or through other productions, back to a production being expanded;
   - every production has a trailing comment citing at least one decision, `[Dnnnn]` or `[Dnnnn, Dmmmm]`.
2. **Names.** Every name is defined exactly once, and every name used is defined.
3. **Layers** ([D0079](../../docs/design/decisions/D0079-two-grammar-layers.md)):
   - every name is in `UPPER_SNAKE_CASE` (lexical) or `UpperCamelCase` (syntactic);
   - no lexical production refers to a syntactic one;
   - no syntactic production refers to a helper production, meaning a lexical production other than `TOKEN`,
     `TRIVIA`, and their alternatives;
   - once the file has productions, `TOKEN`, `TRIVIA`, and (from M03) `SourceFile` exist.
4. **Reachability.** Every lexical production is reachable from `TOKEN` or `TRIVIA`, and every syntactic production
   from `SourceFile`.
5. **Citations.** Every decision a production cites has a record in `docs/design/decisions/`.
6. **Quotations.** Every production quoted in `docs/spec/` (a fenced block whose lines have the form `Name ::= …`)
   matches the file's production of that name verbatim, apart from the trailing decision comment.
7. **Rule IDs** ([D0018](../../docs/design/decisions/D0018-diagnosis-and-rule-ids.md)):
   - every rule ID defined in the specification (written `[R-…]` at the start of a rule) is well formed and defined
     exactly once;
   - every rule ID used elsewhere (tests' `expect: reject R-…` headers, `formal/`, decision records, examples) is
     defined.

## Stage 2: the reference lexer

- It interprets the lexical grammar directly to divide text into tokens and trivia. Until T0019 specifies
  tokenization, it takes the longest match among the alternatives of `TOKEN` and `TRIVIA`, as a provisional rule of
  the tool.
- Every quoted string in a syntactic production is exactly one token.
- Every lexical example in the specification lexes.
- Every lexical reject test in `tests/conformance/` is rejected with the rule ID its `expect: reject` header names
  ([D0082](../../docs/design/decisions/D0082-grammar-rejection-rules.md)).

## Stage 3: conflicts

M03 chooses the grammar class and how this stage checks it, possibly with Menhir. The syntactic grammar is
conflict-free in that class, and every program in `examples/` parses.
