# Tools

Tools that check the repository's design documents. A tool enters this directory only by a decision record that names
it, what it checks, and how it runs.

| Tool | Checks | Run | Decided by |
| --- | --- | --- | --- |
| [`grammar/`](grammar/README.md) | the grammar file, its quotations in the specification, rule IDs, and (stage 2) lexical examples and reject tests | `ocaml tools/grammar/check.ml` | [D0080](../docs/design/decisions/D0080-staged-grammar-checker.md), [D0081](../docs/design/decisions/D0081-ocaml-grammar-checker.md) |
