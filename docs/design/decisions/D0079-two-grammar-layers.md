# D0079: The grammar has a lexical layer and a syntactic layer, told apart by naming, with explicit tokens and trivia

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M02 / T0014 |

## Question

How does [`qubec.ebnf`](../../spec/grammar/qubec.ebnf) separate the rules that form tokens from characters (the
**lexical grammar**) from the rules that form programs from tokens (the **syntactic grammar**), and how does a reader
know what counts as a token? The notation is W3C EBNF ([D0078](D0078-w3c-ebnf-notation.md)), which has no layers of
its own.

## Options considered

The scenario for every option: the source `let  x /* note */ = 1;` (provisional syntax; the comment form is T0016's).

### A. Two layers in one file, told apart by naming, with `TOKEN` and `TRIVIA` roots

Lexical productions are named in `UPPER_SNAKE` and match characters; nothing is implicit between their parts.
Syntactic productions are named in `UpperCamel` and match tokens; trivia may appear between any two tokens and is
dropped. `TOKEN` lists the kinds of token and `TRIVIA` the kinds of trivia; every other lexical production is a helper,
used only inside lexical productions. A quoted string in a syntactic production denotes the one token with that text.

```
TOKEN       ::= IDENTIFIER | KEYWORD | INTEGER | PUNCTUATOR
TRIVIA      ::= WHITESPACE | LINE_END | BLOCK_COMMENT
IDENTIFIER  ::= (IDENT_START IDENT_CONTINUE*) - KEYWORD
IDENT_START ::= [a-zA-Z_]                        /* helper */
LetDecl     ::= 'let' 'mut'? IDENTIFIER (':' Type)? '=' Expr ';'
```

The source becomes the tokens `let` `x` `=` `1` `;`, with trivia between them.

- **Easy:** the layer is visible from the name; the rules that differ between layers (trivia or not) are never
  confused.
- **Hard:** two naming styles; text whose division into tokens depends on syntactic context (string templates, a
  newline that ends a statement) must be modeled explicitly, with lexer modes or a token or trivia kind the parser
  consults.
- **For implementers:** a lexer can name its token kinds after the alternatives of `TOKEN`, so the specification and
  the code share names; a checker can enforce the layer rules.
- **Locks in / rules out:** a separate lexer, which is what hand-written front ends have.
- **Prior art:** the Rust Reference names lexer tokens in capitals and syntactic productions in CamelCase (verified,
  [R0012](../research/R0012-grammar-notation-and-checking.md)); ANTLR distinguishes lexer and parser rules by the case of
  their first letter (recalled).

### B. As A, with lexical productions named in `lower_snake`

```
token      ::= identifier | keyword | integer | punctuator
identifier ::= (ident_start ident_continue*) - keyword
LetDecl    ::= 'let' 'mut'? identifier (':' Type)? '=' Expr ';'
```

- **Easy:** Go's convention (verified, R0012); quieter to read.
- **Hard:** in QubeC source, lowercase names are values and functions, so a token reads like a variable in a
  syntactic rule. Otherwise as A.

### C. One layer over characters

There are no tokens; every production matches characters, and whitespace is written where it is allowed.

```
LetDecl ::= 'let' _ ('mut' _)? Identifier _ (':' _ Type _)? '=' _ Expr _ ';'
_       ::= (WHITESPACE | LINE_END | BLOCK_COMMENT)*
```

- **Easy:** context-dependent lexing needs no special treatment; one grammar.
- **Hard:** every syntactic rule is cluttered with whitespace; keywords must be excluded everywhere; a hand-written
  lexer and parser no longer mirror the specification; conflict checks work poorly at the character level.
- **Prior art:** SDF and many PEG tools (recalled).

Recommendation at the time: **A**, because the case difference marks exactly what a reader must never confuse, and it
matches how our lexers will name their token kinds.

## Choice

**A.**
1. **The lexical grammar** consists of the productions named in `UPPER_SNAKE_CASE`. They match characters of the
   source text, with nothing implicit between their parts. They never refer to a syntactic production.
2. **The syntactic grammar** consists of the productions named in `UpperCamelCase`. They match sequences of tokens.
   Trivia may appear between any two tokens and is not part of the token sequence.
3. **`TOKEN`** is the lexical production whose alternatives are the kinds of **token**, and **`TRIVIA`** the one whose
   alternatives are the kinds of **trivia**. Every other lexical production is a **helper production**, used only
   inside other lexical productions. A syntactic production refers only to token kinds, never to a helper.
4. A quoted string in a syntactic production denotes the one token whose text is that string. It must be exactly one
   token of the lexical grammar.
5. The **start symbol** of the syntactic grammar is `SourceFile`; M03 writes its production.
6. How source text is divided into tokens and trivia is specified with the lexical structure (T0019).

## Rationale

The two layers follow different rules, trivia allowed or not, so the naming makes the layer visible wherever a name
appears. Uppercase tokens stand out in syntactic rules and cannot be mistaken for QubeC values. Naming `TOKEN`'s
alternatives gives one list of token kinds that the specification, the reference lexer, and both implementations'
lexers share. Fixing the start symbol's name lets the checker test reachability before M03 writes it.

## Consequences

- **Spec:** [§1.3.6](../../spec/01-introduction.md#136-grammar-notation) states the layers; the lexical chapter (§2)
  specifies tokenization in T0019.
- **T0015:** whichever way statements end must fit this model: a newline that ends a statement becomes a token, or a
  trivia kind the syntactic grammar consults.
- **T0016–T0018:** comments are trivia kinds unless T0016 decides otherwise for doc comments; string templates need
  lexer modes, written as recursive lexical productions and specified in T0019.
- **M03:** writes `SourceFile` and the syntactic grammar under these rules.
- **[D0080](D0080-staged-grammar-checker.md):** stage 1 checks rules 1–5 and stage 2 checks rule 4.
- **I1, I3:** each lexer's token kinds correspond to `TOKEN`'s alternatives.

## Affected artifacts

- Spec: [§1.3.6](../../spec/01-introduction.md#136-grammar-notation)
- Grammar rules: the file's layout (section 1 lexical, section 2 syntactic)
- Formal rules: none
- Examples / tour: none
