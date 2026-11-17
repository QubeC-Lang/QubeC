# D0078: The grammar is written in W3C EBNF, with exclusion limited to finite sets in the lexical grammar

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M02 / T0014 |

## Question

Which notation is the grammar file [`qubec.ebnf`](../../spec/grammar/qubec.ebnf) written in? Since T0001 it has used
W3C-style EBNF, marked provisional until M02 ([§1.3.6](../../spec/01-introduction.md#136-grammar-notation)). The
notation needs sequence, choice, optional, and repetition for both layers of the grammar and, for the lexical layer,
code points, character classes, and a way to exclude (an identifier that is not a keyword). It must be precise enough
to be machine-checked ([D0080](D0080-staged-grammar-checker.md)), because the grammar file governs where a quotation
differs from it ([D0001](D0001-repository-layout.md)).

## Options considered

The scenario for every option: an identifier that is not a keyword, a line end of LF or CRLF, a block comment that
nests, and a `let` declaration. The comment form and the declaration are illustrations only (T0016, M03).

### A. W3C EBNF (XML 1.0, Fifth Edition, section 6)

`Name ::= expression`. Sequence is juxtaposition (`A B`), choice is `A | B`, with `A?`, `A*`, `A+`, and grouping
`( )`. `#xN` is a code point, `[a-zA-Z_]` and `[^…]` are character classes, `"…"` and `'…'` are literal strings,
`A - B` matches what A matches and B does not, and `/* … */` is a comment. The XML specification states that
sequence binds tighter than choice; it does not state how `A B - C` groups.

```
IDENT_START    ::= [a-zA-Z_]
IDENT_CONTINUE ::= [a-zA-Z0-9_]
KEYWORD        ::= 'let' | 'func' | 'proc' | 'tailcall'
IDENTIFIER     ::= (IDENT_START IDENT_CONTINUE*) - KEYWORD
LINE_END       ::= #xA | #xD #xA
BLOCK_COMMENT  ::= '/*' (BLOCK_COMMENT | COMMENT_CHAR)* '*/'
LetDecl        ::= 'let' 'mut'? IDENTIFIER (':' Type)? '=' Expr ';'
```

- **Easy:** precise at the character level with no prose; reads like regular expressions.
- **Hard:** the language of QubeC's inspirations' specifications is Wirth-style, not this; `A - B` is a difference
  of languages, which is well behaved only when B is simple.
- **For implementers:** no generator reads it, so checking it is our own code; a stdlib-only OCaml parser and matcher
  for it took 78 lines in a pilot, and matched and rejected the sample above as intended
  ([R0012](../research/R0012-grammar-notation-and-checking.md)).
- **Locks in / rules out:** a context-free reading, in which every alternative counts equally, so M03 remains free to
  choose the grammar class.
- **Prior art:** XML (verified); recommended over ISO/IEC 14977 by David Wheeler because it has code points and
  ranges (verified, R0012).

### B. ISO/IEC 14977 EBNF

`name = a , b ;` with a comma between every two items, `{ }` repetition, `[ ]` option, and `-` exception. It has no
character ranges, and characters outside ISO 646 can be written only as prose "special sequences" `? … ?`.

```
identifier = ( ident start , { ident continue } ) - keyword ;
ident start = "a" | "b" | "c" | (* …all 52 letters… *) | "_" ;
line end = ? U+000A ? | ? U+000D ? , ? U+000A ? ;
let decl = "let" , [ "mut" ] , identifier , [ ":" , type ] , "=" , expr , ";" ;
```

- **Easy:** an international standard.
- **Hard:** wordy; no ranges; code points as prose, so the lexical grammar cannot be checked.
- **Prior art:** criticized for exactly these points by Wheeler (verified, R0012).

### C. Wirth-style EBNF, as in Go's specification

`Name = expression .` with `|`, `( )`, `[ ]`, `{ }`, and ranges `"a" … "z"`. There is no exclusion and no code-point
notation; Go writes both as prose comments.

```
ident_start    = "a" … "z" | "A" … "Z" | "_" .
identifier     = ident_start { ident_continue } .   /* not a keyword: stated in prose */
line_end       = newline | carriage_return newline .
newline        = /* the code point U+000A */ .
LetDecl        = "let" [ "mut" ] identifier [ ":" Type ] "=" Expr ";" .
```

- **Easy:** compact, and familiar to readers of Go's specification.
- **Hard:** the exclusions and code points the lexical grammar most needs become prose a checker cannot read;
  extending the notation for them turns it into option D.
- **Prior art:** Go (verified, R0012); Pascal and Oberon (recalled).

### D. A dialect of our own, like the Rust Reference's

A regular-expression-like notation that we define, such as the Rust Reference's `U+xxxx`, `~[…]` (any character
except), `!X` (X does not follow), and `^` (a hard cut). The last two come from parsing expression grammars (PEGs),
whose choice is ordered: the first alternative that matches wins.

```
IDENT_START   = [`a`-`z` `A`-`Z` `_`]
IDENTIFIER    = !KEYWORD IDENT_START IDENT_CONTINUE*
LINE_END      = U+000A | U+000D U+000A
BLOCK_COMMENT = `/*` (BLOCK_COMMENT | ~`*/`)* `*/`
LetDecl       = `let` `mut`? IDENTIFIER (`:` Type)? `=` Expr `;`
```

- **Easy:** the most expressive, and tailored to what we need.
- **Hard:** its meaning would be ours to specify; PEG features move the grammar toward ordered choice, deciding M03's
  grammar class in advance and hiding ambiguities instead of reporting them.
- **Prior art:** the Rust Reference (verified, R0012); CPython's PEG grammar (recalled).

ABNF (RFC 5234) was not offered: its quoted strings and rule names are case-insensitive (verified, R0012), a trap for
a case-sensitive language.

| | A W3C | B ISO 14977 | C Wirth | D Own dialect |
| --- | --- | --- | --- | --- |
| Code points and classes | yes | prose | ranges only | yes |
| Exclusion | `A - B` | `-` | prose | `!` lookahead |
| Defined by | W3C | ISO | Go's specification, informally | us |
| Reading | context-free, with difference | context-free | context-free | PEG-leaning |

Recommendation at the time: **A**, the only option that is both precise at the character level and defined outside
this project, with `A - B` parenthesized inside longer sequences and without XML's validity annotations.

## Choice

**A**, with these clarifications.
1. `qubec.ebnf` is written in the EBNF notation of XML 1.0 (Fifth Edition), section 6. The notation is no longer
   provisional.
2. XML's `[ wfc: … ]` and `[ vc: … ]` annotations are not used.
3. Where `A - B` is one item of a longer sequence, it is written in parentheses.
4. The operator `-` appears only in lexical productions ([D0079](D0079-two-grammar-layers.md)), and its right operand
   matches only finitely many strings, such as a list of keywords or `'*/'`. Character exclusion is written with
   `[^…]`.
5. Lexical productions may be recursive, as a comment that nests would need.
6. Every production carries a trailing comment that names the decisions it implements, such as `/* [D0078] */`.

## Rationale

W3C EBNF is precise down to the code point, its meaning is fixed by a published specification rather than by us or by
a tool, it reads like the regular expressions every programmer knows, and it is what the file already used. The
pilot showed that checking it ourselves is cheap. We weighed that our inspirations' specifications use Wirth-style
notations; they differ from this one mainly in spelling, and lack exactly the character-level forms the lexical
grammar needs. Limiting `-` to finite right operands in the lexical grammar keeps every production context-free and
the check simple, since the difference of two context-free languages need not be context-free, and no parser tool
supports it in syntactic rules.

## Consequences

- **Spec:** [§1.3.6](../../spec/01-introduction.md#136-grammar-notation) states the notation; its provisional note is
  removed.
- **T0015–T0018:** every production is written in this notation, with its decision comment.
- **[D0080](D0080-staged-grammar-checker.md):** stage 1 checks rules 3, 4, and 6; a right operand is finite when it
  contains no `*`, no `+`, and no reference that leads back to itself.
- **M03:** chooses the grammar class freely; the notation implies none.
- **M15:** may generate railroad diagrams or editor grammars from the file.

## Affected artifacts

- Spec: [§1.3.6](../../spec/01-introduction.md#136-grammar-notation); [conventions](../../spec/README.md)
- Grammar rules: the file's header
- Formal rules: none
- Examples / tour: none
