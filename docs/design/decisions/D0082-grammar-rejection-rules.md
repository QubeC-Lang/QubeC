# D0082: Lexical failures have named rules with a fallback, and parse failures share one rule

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M02 / T0014 |

## Question

[D0018](D0018-diagnosis-and-rule-ids.md) requires that a rejected program be reported with the ID of a rejection
rule it violates, and asked M02 to decide how lexical and syntactic violations are named. A file can fail before any
static rule applies: its text cannot be divided into tokens, or its tokens do not form a program. Lexical failures
are facts about a span of text, found at the same place by every correct lexer. Where a parser notices a mistake, and
which production it blames, depends on the parsing strategy, so a rule ID for it must not, if it is to mean the same
thing everywhere ([D0051](D0051-deterministic-sequential-language.md)). And since an implementation may report any
rule a file violates, a general rule must step aside where a specific one applies, or a test expecting the specific
rule could be satisfied by the general one.

## Options considered

The scenario for every option: four rejected files (provisional syntax; the literal forms are T0017's and T0018's,
and the rule names are illustrative).

```
let a = 1__0;     // 1: malformed number
let b = 1 ¤ 2;    // 2: '¤' begins no token
let c = "abc      // 3: unterminated string
let = 1;          // 4: tokenizes, but no name follows 'let'
```

### A. Named lexical rules, a lexical fallback, and one syntax rule, with precedence

Each lexical failure the specification names has its own rule. `R-token-invalid` covers any other failure to
tokenize, and `R-syntax` covers any token sequence the syntactic grammar does not derive. A more specific rule takes
precedence over either.

Files 1 to 4 give `R-number-malformed`, `R-token-invalid`, `R-string-unterminated`, and `R-syntax`. Messages remain
free, so the fourth can still say "expected a name after `let`".

- **Easy:** tests check the reason wherever it is deterministic; diagnostics link to named lexical rules.
- **Hard:** the precedence must be worded exactly; every parse-failure test shares one ID.
- **For implementers:** a lexer's error type maps one-to-one onto the named lexical rules; the reference lexer
  ([D0080](D0080-staged-grammar-checker.md)) checks lexical reject tests against the grammar.
- **Prior art (recalled):** rustc and TypeScript give many lexical errors their own codes and report most syntax
  errors generically; no language specification numbers parse failures.

### B. One rule per layer

`R-lexical` for every lexical failure and `R-syntax` for every parse failure; the details are only in messages.
Files 1 to 3 give `R-lexical`, and file 4 `R-syntax`.

- **Easy:** the least specification text and no precedence.
- **Hard:** tests cannot tell lexical failures apart, and diagnostics cannot link to a specific lexical rule.

### C. A named rule for every failure, syntactic ones included

Each production gets IDs for the ways it can fail, such as `R-let-name-missing` for file 4.

- **Easy:** the most precise tests.
- **Hard:** the specification would have to fix a canonical parsing algorithm or error-recovery strategy to make
  those IDs deterministic, deciding M03's grammar class and both implementations' parsers.

Recommendation at the time: **A**, distinct IDs where failures are deterministic and one honest ID where they are
not, with precedence so that a general ID never satisfies a test that expects a specific one.

## Choice

**A.**
1. **Named lexical rules.** Each lexical failure that the specification names has its own rejection rule and rule ID,
   in the lexical chapter (§2). T0015–T0019 decide which failures are named.
2. **The lexical fallback.** `[R-token-invalid]`: every source file MUST tokenize. Where tokenization fails at a
   position at which a more specific lexical rejection rule applies, the file violates that rule, and not
   `R-token-invalid`.
3. **The syntax rule.** `[R-syntax]`: the token sequence of every source file MUST be derivable from `SourceFile`
   ([D0079](D0079-two-grammar-layers.md)). A file that does not tokenize has no token sequence and does not violate
   `R-syntax`. Where a more specific syntactic rejection rule applies, the file violates that rule, and not `R-syntax`.
4. **Specific syntactic rules.** A later milestone may add a syntactic rejection rule for a mistake worth testing on
   its own. It is stated in prose, states exactly which token sequences it covers, and takes precedence over
   `R-syntax` for them.
5. **Placement.** Both general rules are stated in spec
   [§1.3.8](../../spec/01-introduction.md#138-rejection-by-the-grammar), next to the grammar notation, because they
   apply to every chapter that adds productions.

## Rationale

Lexical failures are few, distinct, and found at the same place by every correct lexer, so they deserve testable
names. A parse failure is deterministic only as a class, since which production failed depends on the parser, so it
gets one ID and its detail goes into the message, which D0018 leaves free. Precedence keeps a test that expects a
specific rule meaningful, because a generic rule can never satisfy it.

## Consequences

- **T0015–T0019:** add one rule per named lexical failure, each with reject tests that the reference lexer runs; T0019
  specifies tokenization exactly, including the position at which it fails.
- **M03 onward:** `R-syntax` covers the new productions; a specific syntactic rule needs a mistake common enough to
  test alone and a precise statement.
- **D0018's advice** that a reject test violate exactly one rule now covers grammar failures: a test violates one
  lexical rule, or it tokenizes and violates only `R-syntax` or one specific syntactic rule.
- **I1, I3:** each lexer reports §2's rule IDs; each parser reports `R-syntax`, with whatever detail M15 asks for.

## Affected artifacts

- Spec: [§1.3.8](../../spec/01-introduction.md#138-rejection-by-the-grammar)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
