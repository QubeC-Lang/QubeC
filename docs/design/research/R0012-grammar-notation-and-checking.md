# R0012: Grammar notations and grammar checking: prior art and pilots

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M02 / T0014 |
| Used by | D0078, D0079, D0080, D0081, D0082 |

## Question

Which notations do language specifications use for their grammars, and what can each express at the character
level? How hard is it to parse and interpret W3C EBNF ourselves? What does each candidate language bring to a grammar
checker, including which Unicode tables its toolchain carries?

## Sources

1. Extensible Markup Language (XML) 1.0, Fifth Edition, section 6 "Notation", <https://www.w3.org/TR/xml/#sec-notation>.
2. The Go Programming Language Specification, section "Notation", <https://go.dev/ref/spec#Notation>.
3. RFC 5234, "Augmented BNF for Syntax Specifications: ABNF", <https://www.rfc-editor.org/rfc/rfc5234>.
4. David A. Wheeler, "Don't Use ISO/IEC 14977:1996 Extended Backus-Naur Form (EBNF)",
   <https://dwheeler.com/essays/dont-use-iso-14977-ebnf.html>.
5. The Rust Reference, "Notation", <https://doc.rust-lang.org/reference/notation.html>.
6. The Menhir reference manual, <https://gallium.inria.fr/~fpottier/menhir/manual.html>.
7. Measurements on macOS 27 (Darwin 27.0.0), arm64, on 2026-11-17, with OCaml 5.5.2, Python 3.13.14, rustc 1.99.1,
   and Lean 4.36.0. The programs were throwaway files outside the repository.

## Findings

### Notations (verified, sources 1–5)

- **W3C EBNF (source 1):** `#xN` code points; `[a-zA-Z]`, `[#xN-#xN]`, `[abc]`, and negated `[^…]` classes; quoted
  strings in either quote; grouping; `A?`, `A B`, `A | B`, `A - B` ("matches A but does not match B"), `A+`, `A*`;
  `/* … */` comments; `[ wfc: … ]` and `[ vc: … ]` annotations. Sequence has higher precedence than alternation
  (`A B | C D` is `(A B) | (C D)`). The section does not state how `A B - C` groups.
- **Go (source 2):** a Wirth-style variant: `Production = production_name "=" [ Expression ] "." .`, with `|`, `()`,
  `[]` (0 or 1), and `{}` (0 or more), in increasing precedence. `a … b` is a character range. Lowercase production
  names identify lexical tokens and CamelCase names non-terminals. Code points such as newline are given in prose
  comments.
- **ABNF (source 3):** `/` alternation, `=/` incremental alternatives, `%x30-39` value ranges, `n*m` repetition,
  `[ ]` optional, `;` comments. Rule names are case-insensitive, and quoted strings are case-insensitive: `"abc"`
  matches `ABC`; case-sensitive text must be written as numeric values.
- **ISO/IEC 14977 (source 4):** a comma for every concatenation; no standard way to write character ranges; only
  ISO/IEC 646 characters, with no way to give code points by value; one-or-more written `{ symbol }-`. Wheeler
  recommends the W3C notation instead, as close to regular-expression syntax and clearly described, and finds ABNF less
  flawed but not recommended outside RFCs. (The criticism of the standard's added dialects is quoted from Zaytsev in
  Wikipedia's EBNF article; recalled, not checked further.)
- **The Rust Reference (source 5):** `CAPITAL` names for tokens produced by the lexer and CamelCase names for
  syntactic productions; `x?`, `x*`, `x+`, bounded repetitions; `[ ]` and `~[ ]` character sets; `!` negative
  lookahead and a `^` hard cut, both described in terms of PEG parsing; `U+xxxx` characters; prose in `<…>`. Sequence
  binds tighter than `|`. The page does not say whether the grammar is machine-checked.

### Menhir (verified, source 6)

Menhir "is based on Knuth's LR(1) parser construction technique". `--explain` writes explanations of conflicts to a
`.conflicts` file. `--interpret` reads sentences and reports ACCEPT, OVERSHOOT (the sentence ended too early), or
REJECT, without generating a parser. Its standard library defines `option`, `list`, `nonempty_list`, and
`separated_list`.

### Pilot: a W3C EBNF parser and matcher (verified, source 7)

A 78-line OCaml program (the standard distribution, with its `Str` library for one search) parsed W3C EBNF into an
algebraic data type (literal, reference, class, sequence, alternation, `?`, `*`, `+`, `-`) and matched strings against
a production by computing every end position, so that `A - B` is exact. On this grammar:

```
LETTER      ::= [a-zA-Z]
DIGIT       ::= [0-9]
IDENT_START ::= LETTER | '_'
WORD        ::= IDENT_START (LETTER | DIGIT | '_')*
KEYWORD     ::= 'let' | 'func' | 'proc' | 'tailcall'
IDENTIFIER  ::= WORD - KEYWORD
COMMENT     ::= '/*' (COMMENT | ([^*/] | '*' [^/] | '/' [^*]))* '*/'
LINE_END    ::= #xA | #xD #xA
```

it parsed all 8 productions and gave: `IDENTIFIER` accepts `letter` and `tailcall_x` and rejects `let` and `9a`;
`COMMENT` accepts `/* a /* nested */ b */` and rejects `/* open /* only */`; `LINE_END` accepts CR LF and rejects a lone
CR. It ran as a script and as a native build. A full stage 1 and stage 2 checker is larger, with error reporting,
the layer rules, and quotation checks, but the core is small.

### Unicode tables in toolchains (verified, source 7)

`unicodedata.unidata_version` in Python 3.13.14 is `15.1.0`; `char::UNICODE_VERSION` in Rust 1.99.1 has major version
17. A grammar checker that used either table would give a Unicode-dependent grammar a meaning that changes with the
checker's toolchain.

### Lean as a scripting language (verified, source 7)

`lean --run` ran a small Lean 4 program that splits a string, in about 2.3 seconds of wall time.

### Recalled, not verified here

- ANTLR distinguishes lexer and parser rules by the case of the rule name's first letter.
- rustc and TypeScript give many lexical errors their own codes and report most syntax errors generically.
- SDF and many PEG tools are scannerless; CPython's grammar is a PEG processed by its own generator.
- lalrpop is an LR(1) parser generator for Rust; Lark parses with Earley or LALR(1) and builds lexers from regular
  expressions, which cannot express recursive terminals.
