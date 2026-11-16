# Vision

Status: **Vision I and II complete** (T0002, T0003). Spec audience, formalization, and the host language follow in
T0004–T0006. Each part links to the decision record that settles it.

## Starting point

QubeC starts from one idea: mainly a general-purpose language, with some low-level, systems-programming ability,
that can eventually self-host. It should start small and be easy to use like Python, but be more strictly typed,
not indentation-sensitive, and functional in style.

## Purpose and problem domain ([D0002](decisions/D0002-purpose-and-domain.md))

QubeC is general-purpose, and **tooling-first**: when goals conflict, the needs of compilers, interpreters, and CLI
and developer tools win. The standing tie-breaker is the **self-hosting yardstick**: *could QubeC's own compiler be
written comfortably in this?* It breaks ties; it does not require the compiler to use every feature.

## Target users ([D0003](decisions/D0003-target-users.md))

1. **Tool builders** (primary): compiler, interpreter, DSL, and developer-tool authors.
2. **Application developers**, coming from Python, Kotlin, or Go.
3. **Systems programmers**, coming from C, C++, Rust, or Zig, served by the explicit layer.

Learners and teachers are not a design target.

## Design values ([D0004](decisions/D0004-ranked-design-values.md))

| Layer | Ranking |
| --- | --- |
| **Default layer** (everyday code) | Safety > Simplicity > Ergonomics > Predictability > Performance |
| **Explicit layer** (opt-in: sized integers, borrowed slices and references, explicit casts) | Safety > Performance > Predictability |

The explicit layer is part of the same language, and it is safe. Unchecked operations are a separate escape hatch,
decided in M07.

## Non-goals ([D0005](decisions/D0005-non-goals.md))

| ID | QubeC will not have |
| --- | --- |
| NG-1 | Indentation-sensitive syntax |
| NG-2 | Dynamic or gradual typing |
| NG-3 | A systems-first, no-runtime default |
| NG-4 | Lazy evaluation by default |
| NG-5 | Effects encoded as monads (effect tracking itself stays open) |
| NG-6 | Class-based implementation inheritance |
| NG-7 | Dependent types and in-program proofs |
| NG-8 | `null` as a value of ordinary types |
| NG-9 | Implicit conversions, and undefined behaviour in safe code |
| NG-10 | Silently ignorable errors, and error-handling noise |
| NG-11 | Invisible inserted code that a reader cannot find or a diagnostic cannot explain |

## Inspirations and anti-inspirations ([D0006](decisions/D0006-inspirations.md))

- **ML:** ADTs and exhaustive `match`, inference, expression orientation, persistent data.
- **Rust:** `Result` and `?`, expression blocks, traits, ownership for the explicit layer, Cargo-grade tooling.
- **Kotlin and Scala 3:** null-safety, trailing lambdas, extension functions, string templates, data and enum types.
- **Go:** lightweight tasks, channels, and `select`, without `async` colouring.

We guard against undefined behaviour and implicit conversions (C, C++), `null` and boilerplate (classic Java),
ignorable errors and error-handling noise, and invisible magic (implicit conversions and resolutions).

## Names ([D0007](decisions/D0007-intuitive-names.md))

The names QubeC provides are **intuitive**. A widely recognized short form is fine (`func`, `Int`, `println`, `IO`).
A single language's coinage, or a truncation the reader must decode, is spelled out (`channel`, not `chan`).

## Functional style (T0003)

"Functional in style" is a checked commitment, not only a convention:

| Commitment | Record |
| --- | --- |
| **Purity is tracked.** A function (`func`, expression body) is pure: no IO, no mutation of state it did not create, no nondeterminism, no spawning or channels, no procedure calls. A procedure (`proc`, block body) may have effects. Procedures call functions freely. `dbg(e)` is allowed anywhere, and its output is not observable. Higher-order code is purity-polymorphic, with purities inferred. | [D0008](decisions/D0008-purity.md) |
| **Bindings are immutable by default.** `let` binds once; a mutable variable is a visible, local opt-in; top level has constants only, and no global variables. | [D0009](decisions/D0009-immutable-bindings.md) |
| **The default collections are mutable.** `List`, `Map`, and `Set` change in place; immutable collections (`ImmutableMap`, …; names provisional) are in the standard library. | [D0010](decisions/D0010-mutable-default-collections.md) |
| **A function may mutate what it created,** as long as no mutation is observable after it returns. | [D0011](decisions/D0011-local-mutation-in-functions.md) |
| **Recursion is safe.** Marked tail calls are checked and run in constant stack; stacks are growable. | [D0012](decisions/D0012-tail-calls-and-stacks.md) |

## Must-haves

| Must-have | Record |
| --- | --- |
| **Easy start:** `qubec run file.qbc` with no project setup, a one-line hello world, and a REPL early. | [D0013](decisions/D0013-easy-start.md) |

## Dream snippet

This is the program we would like to be able to write: a tiny expression compiler that evaluates several files
concurrently. **Everything here is provisional syntax**; each construct is decided in its milestone.

```
const MAX_FILES: Int = 64;

type Span = { file: Str, line: Int, column: Int };
type Op   = Add | Sub | Mul | Div;
type Expr =
  | Num(value: Int, at: Span)
  | Var(name: Str, at: Span)
  | Binary(op: Op, lhs: Expr, rhs: Expr, at: Span)
  | Let(name: Str, init: Expr, body: Expr, at: Span);
type CompileError = Io(IoError) | Syntax(msg: Str, at: Span)
                  | Unbound(name: Str, at: Span) | DivByZero(at: Span);

func eval(expr: Expr, env: ImmutableMap[Str, Int]) -> Result[Int, CompileError] =   // pure
  match expr {
    Num(value, _)            -> Ok(value),
    Var(name, at)            -> env.get(name).or_error(Unbound(name, at)),
    Let(name, init, body, _) -> eval(body, env.insert(name, eval(init, env)?)),
    Binary(op, lhs, rhs, at) -> {
      let (a, b) = (eval(lhs, env)?, eval(rhs, env)?);
      match op {
        Add -> Ok(a + b),  Sub -> Ok(a - b),  Mul -> Ok(a * b),
        Div -> if b == 0 { Error(DivByZero(at)) } else { Ok(a / b) },
      }
    },
  };

proc compile(path: Path) -> Result[Int, CompileError] {          // effectful: reads a file
  let src = file_system.read_text(path).map_error(Io)?;
  eval(parse(path, src)?, ImmutableMap.empty())
}

proc main() {
  let files   = args().take(MAX_FILES).map(Path.of);
  let results = channel (Path, Result[Int, CompileError]);
  for file in files { spawn { results <- (file, compile(file)); } }   // no async colouring
  for _ in files {
    match <-results {
      (file, Ok(value)) -> println("${file} = ${value}"),
      (file, Error(err)) -> stderr.println("${file}: ${err}"),
    }
  }
}
```

The evaluator's environment is an `ImmutableMap`, because `env.insert(…)` must return a new map and leave the
old one valid ([D0010](decisions/D0010-mutable-default-collections.md)).

And the layering of [D0004](decisions/D0004-ranked-design-values.md), in the same provisional syntax:

```
// default layer (Safety > Simplicity > Ergonomics > Predictability > Performance)
func checksum(data: List[Int]) -> Int =
  data.fold(0, |acc, x| acc + x);              // checked Int: overflow is a defined panic

// explicit layer (Safety > Performance > Predictability)
func checksum_fast(data: &[u32]) -> u32 = {
  let mut acc: u32 = 0;
  for x in data { acc = acc.wrapping_add(x); } // wrap-around is requested, never silent
  acc
};
```

And a word-count tool combining the T0003 commitments (provisional syntax):

```
const TOP: Int = 3;

func tokenize(src: Str) -> List[Str] = {             // pure: builds a list it created (D0011)
  let mut words = List.new();
  for w in src.split_whitespace() { words.push(w.to_lower()); }
  words
};

func count(words: List[Str]) -> Map[Str, Int] = {     // pure: a mutable Map, created here (D0010, D0011)
  let mut counts = Map.new();
  for w in words { counts.insert(w, counts.get(w).unwrap_or(0) + 1); }
  counts
};

func skip_spaces(cs: List[Char], i: Int) -> Int =     // constant stack via a checked tail call (D0012)
  if i < cs.len() && cs[i] == ' ' then become skip_spaces(cs, i + 1) else i;

proc main() {                                          // effects only in procs (D0008)
  let text   = file_system.read_text(Path.of(args()[0])).unwrap_or("");
  let counts = dbg(count(tokenize(text)));             // dbg: allowed, output not observable
  for (w, n) in counts.sorted_by_value().reversed().take(TOP) { println("${w}: ${n}"); }
}
// $ qubec run wc.qbc notes.txt                        (D0013)
```

### What the snippet implies

These leanings are carried forward to the milestones that decide them:

| Construct | Implies | Decided in |
| --- | --- | --- |
| `spawn`, `channel`, `<-` | Uncoloured concurrency; race freedom; closed-channel receive without zero values; `<-` as one token | M10, M01, M02 ([OQ-001](open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)) |
| `func` / `proc` | Decided: the pure/effectful split ([D0008](decisions/D0008-purity.md)); effect mechanics | M08 |
| `type Expr = … \| Binary(…, lhs: Expr, …)` | Recursive ADTs without explicit boxes: the default layer manages indirection (GC or reference counting) | M05, M07 |
| `Result`, `?`, `Ok`/`Error` | Errors as values with one-token propagation | M08 |
| `if c { … } else { … }` | Braced conditionals (rather than `if … then … else`) | M03 |
| `;` after declarations and statements | Explicit statement terminators | M02, M03 |
| Upper-case constructors in patterns | Case may carry meaning | M02, M04 |
| `"${file}"` | String templates; the lexer needs modes | M02 |
| `ImmutableMap`, `env.insert(…)` returning a new map | Decided: immutable collections in the library, mutable by default ([D0010](decisions/D0010-mutable-default-collections.md)); final names | M14 |
| `file_system.read_text`, `args()` | Module paths; standard-library names | M09, M14 |
| `become`, `let mut`, `dbg` | Placeholder spellings under D0007 | M02, M03, M14 ([OQ-005](open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)) |
| `&[u32]`, `wrapping_add` | The explicit layer's marking and the numeric model | M05, M07 ([OQ-003](open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones)) |
