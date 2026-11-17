# D0081: The grammar checker is an OCaml program in tools/grammar/, independent of both implementations

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M02 / T0014 |

## Question

What language is the grammar checker of [D0080](D0080-staged-grammar-checker.md) written in, and where does it live?
[D0001](D0001-repository-layout.md) creates `tools/` when the checker is decided. Facts that hold for every option,
from [R0012](../research/R0012-grammar-notation-and-checking.md):
- Stages 1 and 2 are our own code in any language: a parser for W3C EBNF and an interpreter of its syntax tree. Only
  stage 3 might use an outside engine.
- The checker referees between the host interpreter's lexer (Rust, [D0031](D0031-rust-host-interpreter.md)) and
  `qubecc`'s; code shared with either would let a shared bug pass both.
- Toolchains carry different Unicode tables: Python 3.13.14 reports Unicode 15.1.0 and Rust 1.99.1 reports Unicode 17
  (tested). Tables taken from a toolchain would make the grammar's meaning depend on the checker's toolchain, against
  [D0051](D0051-deterministic-sequential-language.md).

## Options considered

The scenario for every option: the stage-2 check that a quoted string in a syntactic production is exactly one token.

### A. OCaml, the standard distribution only for stages 1 and 2

```ocaml
let check_quoted_are_tokens g lex report =
  Grammar.syntactic g |> List.iter (fun p ->
    Prod.quoted p |> List.iter (fun q ->
      match Lexer.tokenize lex q with
      | [_] -> ()
      | toks -> report p (Printf.sprintf "%S lexes as %d tokens" q (List.length toks))))
```

- **Easy:** the grammar is an algebraic data type, and a new notation form makes the compiler flag every match that
  does not handle it; runs as a script with no build step (tested in the pilot).
- **Hard:** fewer people know OCaml than Python; opam is needed if stage 3 uses Menhir.
- **For implementers:** OCaml is already a pinned host toolchain ([D0032](D0032-ocaml-host-compiler.md),
  [D0035](D0035-pinned-toolchains-and-recorded-libraries.md)); the OCaml host compiler reads typed core and never lexes
  surface QubeC ([D0030](D0030-three-part-host.md)), so independence is natural. For stage 3, Menhir is based on
  Knuth's LR(1) construction, explains conflicts, and can interpret a grammar on sentences without generating code
  (verified, R0012).
- **Locks in / rules out:** an ML-style checker ports nearly line by line to QubeC later.

### B. Rust

```rust
for p in g.syntactic() { for q in p.quoted() {
    let n = lex.tokenize(q).len();
    if n != 1 { report(p, format!("{q:?} lexes as {n} tokens")); }
}}
```

- **Easy:** static types and exhaustive matching; no extra toolchain.
- **Hard:** a build step and more ceremony for tree code; sharing the lexer with the host front end would be tempting
  and would destroy its value as a referee, so a written rule would be needed.

### C. Python 3

```python
for p in g.syntactic():
    for q in p.quoted():
        if len(toks := lex.tokenize(q)) != 1:
            report(p, f"{q!r} lexes as {len(toks)} tokens")
```

- **Easy:** the fastest to write and change.
- **Hard:** a fourth language for tooling only, with its own pin; no exhaustiveness checking.

### D. Lean 4

```lean
for p in g.syntactic do
  for q in p.quoted do
    let toks ← lex.tokenize q
    unless toks.length == 1 do report p s!"{q} lexes as {toks.length} tokens"
```

- **Easy:** already pinned ([D0025](D0025-lean-4.md)) and runs as a script (tested); the lexical grammar could later
  be stated and proved in the same system as the core.
- **Hard:** weaker for everyday text processing; ties tooling to the proof toolchain's upgrades; the least familiar
  to contributors.

| | A OCaml | B Rust | C Python | D Lean 4 |
| --- | --- | --- | --- | --- |
| Toolchain already pinned | yes | yes | no | yes |
| Runs as a script | yes | no | yes | yes |
| Independence from the host lexer | natural | by discipline | natural | natural |
| Stage-3 engine | Menhir (LR(1)) | lalrpop (recalled) | Lark (recalled) | our own |

Recommendation at the time: **A**, because the checker is a small compiler over a grammar tree, which suits an ML
language, it adds no toolchain, and its independence from the Rust host lexer comes free.

## Choice

**A.**
1. The grammar checker lives in `tools/grammar/` and is written in OCaml, at the version pinned for the host
   compiler.
2. Stages 1 and 2 use only the libraries of the standard OCaml distribution and run as a script,
   `ocaml tools/grammar/check.ml`, with no build system and no packages.
3. Whether stage 3 uses Menhir, with pinned versions, is decided in M03 with the grammar class.
4. The checker shares no code with the host implementation or with `qubecc`.
5. Any Unicode property the checker needs comes from Unicode Character Database files of the version the
   specification pins, stored in or generated into the repository, never from a toolchain's built-in tables.
6. `tools/README.md` lists each tool, what it checks, and how to run it.

## Rationale

The checker is mostly a compiler over the grammar's syntax tree, which algebraic data types and exhaustive matching
serve best. OCaml is already one of our toolchains, so no language is added, and because the OCaml host compiler
never reads surface QubeC, the checker is independent of both lexers without any rule to enforce it. Running it as a
script keeps it usable with nothing installed beyond OCaml. Pinned Unicode data keeps the grammar's meaning
independent of whatever toolchain runs the check.

## Consequences

- **D0001:** `tools/` is created, and the repository layout in [workflow.md, section 2](../../agent/workflow.md#2-repository-layout)
  lists it.
- **T0016:** if identifiers use Unicode properties, the specification pins a Unicode version, and its data files enter
  the repository under rule 5.
- **M03:** decides stage 3's engine; Menhir needs opam and a recorded, locked version (D0035).
- **I1, I3:** both lexers are tested against the checker's results, through the conformance tests.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [tools/README.md](../../../tools/README.md),
  [tools/grammar/README.md](../../../tools/grammar/README.md)
