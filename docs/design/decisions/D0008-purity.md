# D0008: Purity is tracked: pure functions (`func`) and effectful procedures (`proc`)

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

What does "functional in style" commit QubeC to
([OQ-004](../open-questions.md#oq-004-what-does-functional-in-style-commit-qubec-to))? In particular: does the
compiler track which functions are **pure**, meaning that calling them does nothing observable besides returning a
value? If so, how is it made visible? And what exactly may a pure function do? Constraints: NG-5 rules out monad-encoded
effects ([D0005](D0005-non-goals.md)); Simplicity ranks #2 in the default layer
([D0004](D0004-ranked-design-values.md)); the spelling `func`/`proc` is acceptable under
[D0007](D0007-intuitive-names.md).

An **effect** is anything a pure function may not do. Tracking purity makes three things safe: evaluating a pure
function at compile time, running pure calls in parallel, and caching or reordering them.

## Options considered: how purity is tracked

The scenario is the same for all: count word frequencies, map over a list with a lambda, and print a report.
Provisional syntax.

### A. Two kinds of callable: a pure `func` and an effectful `proc`

A `func` body is checked for effects; a `proc` may do anything, including calling `func`s. The split is one-way:
a procedure calls functions freely, so it is not the `async` colouring rejected in
[D0006](D0006-inspirations.md). Function types carry a hidden purity, so that a higher-order `func` such as `map`
accepts both pure and effectful lambdas: an effect variable is to purity what a type variable is to types.

```
func word_counts(text: Str) -> Map[Str, Int] = { … };            // checked: no effects
func lengths(ws: List[Str]) -> List[Int] = ws.map(|w| w.len());   // pure lambda => pure call

proc report(path: Path) -> Result[Unit, IoError] {
  let text = file_system.read_text(path)?;                        // effects live in procs
  word_counts(text).each(|w, n| println("${w}: ${n}"));           // effectful lambda: fine in a proc
  Ok(())
}
func noisy(text: Str) -> Int = { println(text); 0 };              // error: a func cannot print
```

- **Easy:** purity is visible from the keyword; the system has two points (pure ≤ effectful); compile-time
  evaluation and parallelism can rely on `func`.
- **Hard:** the *cascade*: when a deeply nested `func` later needs a real effect (logging, metrics, caching), it
  and every `func` above it must become `proc`s. Debugging needs an exemption.
- **For implementers:** one purity per function type plus purity variables; inference is propagation over two
  points. Formally a standard type-and-effect judgment, $\Gamma \vdash e : \tau \mathbin{!} \varphi$.
- **Prior art (recalled):** Nim's `func`/`proc` (Nim's `func` still allows mutation through parameters); D's `pure`;
  Fortran's `pure` procedures.

### B. Effects listed in types (effect rows), one callable keyword

Every function type lists the effects it may perform as a row, such as `/ {io, fail[IoError]}`; a pure function has
the empty row. Row variables make higher-order code polymorphic. Handlers may intercept effects.

```
func report(path: Path) -> Unit / {io, fail[IoError]} = {
  let text = file_system.read_text(path)?;
  word_counts(text).each(|w, n| println("${w}: ${n}"));
};
func map[A, B, e](xs: List[A], f: (A) -> B / e) -> List[B] / e = …;
func noisy(text: Str) -> Int / {} = { println(text); 0 };         // error: io not in {}
```

- **Easy:** precise; errors and async could become effects in one framework; handlers help testing.
- **Hard:** heavier types and row-mismatch diagnostics, against Simplicity; handlers need continuations at run time.
- **Prior art (recalled):** Koka, Flix, Unison's abilities, Eff; OCaml 5 has untyped effect handlers.

### C. Not tracked: functional by convention

One callable keyword. The language encourages functional style (first-class functions, immutability by default,
ADTs, expression orientation) but does not enforce purity.

```
func report(path: Path) -> Result[Unit, IoError] = { … println(…) … };
func noisy(text: Str) -> Int = { println(text); 0 };              // fine: nothing says it prints
```

- **Easy:** no cascade, no exemptions; the simplest checker and formal rules.
- **Hard:** compile-time evaluation and parallelism cannot rely on purity; adding tracking later is a breaking
  change.
- **Prior art (recalled):** OCaml, F#, Scala, Kotlin, Rust, Gleam.

Recommendation at the time: **A**. It makes "functional in style" a guarantee with the smallest machinery, and a
two-point system can later grow into effect labels, whereas moving from C to A breaks existing code.

## Options considered: what a `func` may not do

The scenario is counting word frequencies. Its tricky cases are local mutation, an overflow panic, and mutating a
caller's map.

1. **Observable-effect purity.** Forbidden: IO; mutating state the function did not create (non-local variables,
   anything reachable from its parameters); observing nondeterminism (clock, randomness); spawning tasks or using
   channels; calling a `proc`. Allowed: allocation, local mutable variables, panics, divergence. Prior art
   (verified, [R0002](../research/R0002-purity-and-tail-calls.md)): D's strongly pure functions may modify their
   local state and return newly allocated memory.
   ```
   func count_words(text: Str) -> Map[Str, Int] = {
     let mut counts = Map.new();                                // allowed: local
     for w in text.split_whitespace() { counts.insert(w, counts.get(w).unwrap_or(0) + 1); }   // + may panic: allowed
     counts
   };
   func bad(text: Str) -> Int = { println(text); HITS = HITS + 1; random_int() };   // three errors
   ```
2. **Weak purity.** As 1, plus mutation through mutable parameters. "Same input, same output" no longer holds.
   Prior art: D's weakly pure functions; Nim's `func`.
3. **Total functions.** As 1, but no panics and no divergence. Every checked `+` would need an error result, plus a
   termination checker. Prior art: Agda, Idris, Koka's `total`.
4. **No mutation at all, even local.** The simplest rules; loop code and most of the explicit layer would become
   `proc`s. Prior art: Elm.

## Options considered: debugging inside a `func`

1. **A built-in `dbg(e)`, allowed by definition.** It evaluates `e` once, writes
   `[file:line:column] <source text of e> = <debug form of the value>` to standard error, and returns the value.
   Its output is declared **not observable**: it may be deduplicated, dropped, reordered, printed at compile time,
   or stripped in release builds.
   ```
   func area(w: Int, h: Int) -> Int = dbg(w * h);   // stderr: [geo.qbc:1:36] w * h = 12
   const N: Int = area(2, 3);                       // printed at build time, if at all
   ```
   Prior art (recalled): Haskell's `Debug.Trace`, Nim's `debugEcho`, Rust's `dbg!`.
2. **No escape:** printing makes the function, and all its callers, `proc`s.
3. **An unsafe effect block inside `func`:** the optimizer and compile-time evaluation can no longer trust `func`.
   Prior art: Haskell's `unsafePerformIO`.

## Options considered: higher-order functions

The scenario is `map` with a pure lambda, `map` with an effectful lambda, `compose`, and a lazy iterator.

1. **An inferred purity parameter.** Every function type carries a purity (pure, effectful, or a variable); a
   `func` may be effectful only through its purity parameters, instantiated at each call from the actual arguments.
   ```
   func map[A, B](xs: List[A], f: (A) -> B) -> List[B] = …;          // f's purity is a parameter
   func total_len(ws: List[Str]) -> Int = ws.map(|w| w.len()).sum();  // pure
   proc show(ws: List[Str]) { ws.map(|w| println(w)); }               // effectful, in a proc
   func compose(f, g) = |x| g(f(x));                                   // inferred
   ```
   Formal basis: type-and-effect systems with effect polymorphism (recalled: Lucassen and Gifford 1988; Talpin and
   Jouvelot 1992).
2. **Rethrows-style:** a `func` may call its function parameters but not store or return them. It breaks lazy
   iterators and `compose`. Prior art: Swift's `rethrows`.
3. **Two function types and no polymorphism:** duplicated APIs (`map` and `map_effectful`). Prior art: Haskell's
   `map` and `mapM`.

## Choice

**A, with observable-effect purity (1), `dbg` (1), and inferred purity parameters (1).**

1. **Forms.**
   - `func name(params) -> T = expr` declares a **function**. It must be pure. Its body is one expression, which may
     be a block expression `= { … }`.
   - `proc name(params) -> T { … }` declares a **procedure**. It may have effects. Its body is a block; omitting
     `-> T` means the unit type.
   - The body form is tied to the keyword: `func` with a bare block body, or `proc` with `= expr`, is a syntax error.
   - **Callable** means either. The entry point `main` is a procedure.
2. **What a function may not do.** A `func` body MUST NOT:
   - perform IO;
   - mutate state it did not create, including non-local variables and anything reachable from its parameters;
   - observe nondeterminism;
   - spawn tasks or use channels;
   - call a `proc`, or an effectful function value except through its purity parameters.

   It MAY allocate, use local mutable variables, panic, and diverge. Mutating values it created itself is governed
   by [D0011](D0011-local-mutation-in-functions.md).
3. **`dbg(e)`** is allowed in a `func`, with the behavior and non-observability above. Its spelling is open
   ([OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)).
4. **Higher-order code.**
   - Function types carry a purity: pure, effectful, or a purity variable. Purities are inferred.
   - A `func`'s own effect is the join of the purity parameters it calls through; a `proc` is always effectful.
   - **Elision rule:** in a `func` signature, each function-typed parameter written without an explicit purity gets
     its own fresh purity parameter, and the function is effectful exactly when one of them is.
   - Explicit purity notation is rarely needed; its syntax is provisional (M05, M06).

## Rationale

We want "functional in style" to be a guarantee the compiler checks, not a convention, and we want it with the
least machinery: a two-point purity system visible from the keyword. Observable-effect purity matches the intuition
that purity is about what the caller can see; `dbg` keeps debugging cheap without weakening the guarantee; purity
parameters let one `map` serve pure and effectful code.

## Consequences

- **The cascade is a known cost.** A deep `func` that later needs a real effect (logging, metrics, caching,
  configuration) forces conversions up the call chain. M08 and M15 must mitigate it (for example with clear
  diagnostics and refactoring support).
- **M02:** `func`, `proc` are reserved keywords.
- **M03:** block expressions yield values (for `= { … }`), and a `proc` block's result must not reintroduce a
  silent-unit hazard.
- **M05:** typing judgments carry a purity ($\Gamma \vdash e : \tau \mathbin{!} \varphi$); function types carry
  purities.
- **M06:** generics include purity parameters; data types that store closures carry them.
- **M07:** decides the check behind [D0011](D0011-local-mutation-in-functions.md).
- **M08:** extends this two-point system (for example with error or async effects) rather than starting from
  scratch. NG-5 remains satisfied, since effects are not monads.
- **M10:** spawning and channels are effects, so concurrency lives in procedures; pure functions may run in parallel
  safely.
- **M11:** compile-time evaluation may run any `func`.
- **M13:** the soundness statement includes effect soundness: evaluating a well-typed pure expression performs no
  observable effect other than `dbg` output.
- **M15:** the diagnostic for "a `func` calls a `proc`" must explain the rule; readers from Swift or Go read `func`
  as "any function".

## Affected artifacts

- Spec: none yet (declarations in M04; effects in M08)
- Grammar rules: none yet (a provisional sketch: `FuncDecl ::= 'func' Ident Params ('->' Type)? '=' Expr`,
  `ProcDecl ::= 'proc' Ident Params ('->' Type)? Block`)
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md) (dream snippet, combined sample)
