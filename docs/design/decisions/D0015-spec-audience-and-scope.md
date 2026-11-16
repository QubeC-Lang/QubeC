# D0015: One specification for programmers and implementers, covering the language and its core library

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0004 |

## Question

Two questions about the specification:
- **Audience.** Who is it written for? The answer sets its vocabulary, how many examples it has, and whether it
  teaches.
- **Scope.** What does it cover? Some library pieces are mentioned by the language's own rules: `?` needs `Result`,
  `dbg` is built in ([D0008](D0008-purity.md)), and a program needs an entry point. A whole standard library changes
  faster than the language.

The answers set the shape of spec §1 and the size of every later milestone's spec work. They build on
[D0003](D0003-target-users.md) (tool builders are the primary users) and [D0004](D0004-ranked-design-values.md)
(Simplicity ranks second).

## Options considered: audience

Every option states the same rule, "a `func` body must not call a `proc`" ([D0008](D0008-purity.md)).

### A. Implementers first

Terse, legal-style prose with its own technical vocabulary, each word used in one sense, and few examples.
Programmers learn from the tour and from compiler errors.

```
§9.4.2 Purity of function bodies
Let b be the body of a function declaration (§9.2). A call expression
in b whose callee has callable kind proc (§9.1), and which does not
occur within a nested lambda body, is an effect occurrence of b. If b
contains an effect occurrence, the declaration is ill-formed. [D0008]
```

- **Easy:** precision; each sentence turns into a test or a check almost mechanically.
- **Hard:** programmers cannot answer "is this legal?" from it, so the compiler's behavior becomes the de facto
  definition.
- **Locks in / rules out:** in practice, a second readable document.
- **Prior art (recalled):** the C and C++ standards and ECMAScript, which ordinary programmers rarely read.

### B. One specification for both

One document. Its normative prose uses QubeC's own vocabulary and plain sentences with requirement keywords, and
short non-normative examples sit beside the rules. Mathematical precision lives in `formal/`. A vague spot found in
the prose is a defect.

```
§9.4.2 Functions are pure
The body of a `func` MUST NOT call a `proc`. It MAY allocate, panic,
call `dbg`, and mutate values it created (§9.4.3). [D0008, D0011]

> Example (non-normative).
>   proc read_count() -> Int { … }
>   func f() -> Int = read_count()   // rejected: calls a proc
>   func g(n: Int) -> Int = dbg(n)   // accepted
```

- **Easy:** tool builders can settle legality questions themselves; one document to keep current; the examples seed
  conformance tests.
- **Hard:** readable prose tends to leave corner cases vague; the formal rules and the "vagueness is a defect" rule
  are the defense.
- **Locks in / rules out:** the tour stays the learning document, and the spec does not teach.
- **Prior art:** the Go specification, widely read, though its type-inference description was clarified only in Go
  1.21 (verified, [R0003](../research/R0003-spec-conventions-prior-art.md)); the Rust Reference (recalled);
  WebAssembly, whose prose alone suffices to read it (verified, R0003).

### C. Two documents

A terse normative specification, plus a non-normative annotated reference with the same section numbers.

- **Easy:** each reader gets a document that suits them.
- **Hard:** every section is written and kept in step twice; documentation drift is the classic failure.
- **Prior art (recalled):** Ada's Reference Manual and Annotated Reference Manual; C and its Rationale. Both are kept
  by standards committees.

Recommendation at the time: **B**, because our primary users read specifications, Simplicity favors one
document, and the precision of A can come from `formal/` instead.

## Options considered: scope

The scenario for every option: where each piece of this program is specified (provisional syntax).

```
proc main() {
  let xs = [3, 1, 2];                   // List
  let total = sum_checked(xs)?;         // `?` relies on Result
  dbg(total);                           // built in (D0008)
  println("total: ${total}");           // IO library
}
// $ qubec run main.qbc                  (D0013)
```

### A. The language only

Syntax and static and dynamic semantics, plus the few built-in names the rules cannot avoid. Library types are
referred to by name and contract.

- **Easy:** the smallest specification; the library is free to change.
- **Hard:** the contracts the language relies on (what `?` requires of `Result`) still leak in as fragments.
- **Prior art (recalled):** the JLS, which relies on the separately specified Java SE API; the Go specification,
  which covers built-in functions and package `unsafe` only.

### B. The language plus its core library

Also normative: the **core library**, meaning the types and functions that the language's own rules depend on
(such as `Int`, `Bool`, `Str`, `List`, `Option`, `Result`, `panic`, `dbg`, and the entry point), in a chapter of
its own. The rest of the standard library is documented outside the specification.

- **Easy:** the specification is self-contained for everything the language relies on, and the boundary has a
  principle: "does a language rule depend on it?".
- **Hard:** the line is drawn item by item, and core types become harder to change.
- **Prior art (recalled):** the Haskell 2010 Report includes the Prelude in Part I, with libraries in Part II.
  Standard ML keeps even its core in the separate Basis.

### C. The language plus the whole standard library

Every standard module is specified normatively.

- **Easy:** one authoritative answer for everything.
- **Hard:** a very large specification; every library change becomes a specification change; a self-hosted
  compiler must implement all of it to conform.
- **Prior art (recalled):** the C standard (its library clause) and ECMAScript (all built-in objects).

### D. The core library plus the tool interface

As B, plus a normative chapter on the command-line tool (`qubec run`, `qubec build`, the REPL), so that the easy
start of [D0013](D0013-easy-start.md) becomes a testable guarantee.

- **Easy:** every implementation must offer the same easy start.
- **Hard:** tools evolve fast, and this ties the specification to M15.
- **Prior art (recalled):** no mainstream language specification we know of; tools document themselves.

Recommendation at the time: **B**, the smallest scope that makes every language rule self-contained.

## Choice

1. **Audience (B).** The specification is one document, written for both QubeC programmers and implementers of
   compilers and tools.
   - Its normative prose uses QubeC's own vocabulary and plain language, with non-normative examples beside the
     rules.
   - Mathematical notation stays in `formal/`.
   - Vagueness found in the prose is a defect: it is fixed, or recorded as an open question.
   - The specification does not teach; the [tour](../../guide/tour.md) is the learning document.
2. **Scope (B).** The specification covers the language (lexical structure, syntax, static semantics, dynamic
   semantics) and the **core library**: the types, values, and functions that a rule of the language depends on.
   - The exact list of core items is drawn in M14 by that criterion.
   - The rest of the standard library, and the `qubec` tool, are documented outside the specification (M14, M15).

## Rationale

Tool builders, our primary users, read specifications, and one readable document serves them without the drift that
two documents invite. The precision an implementer-only text would add comes from the formal rules instead. For
scope, a specification that leaves out what its own rules rely on is not self-contained, while one that includes
the whole library grows with every library change. The core-library line follows a principle that can be checked
item by item. Simplicity, ranked second, argues against including the library or the tool.

## Consequences

- **Spec §1.1** states the audience and scope. A core-library chapter is added when M14 (or an earlier milestone
  that needs a core item) writes it.
- **M14:** draws the list of core items by the criterion above. Items outside the core, such as `println` for now,
  may change without a specification change. If a language rule comes to depend on one of them, it moves into the
  core.
- **M15:** documents the `qubec` tool, including `qubec run` ([D0013](D0013-easy-start.md)), outside the
  specification.
- **The tour** carries all teaching.

## Affected artifacts

- Spec: [§1.1](../../spec/01-introduction.md#11-scope)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
