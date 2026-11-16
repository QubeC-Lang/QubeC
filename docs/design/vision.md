# Vision

Status: **Vision I complete** (T0002). Further must-haves, and what "functional in style" commits us to, follow in
T0003. Each part links to the decision record that settles it.

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

func eval(expr: Expr, env: Map[Str, Int]) -> Result[Int, CompileError] =   // pure
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
  eval(parse(path, src)?, Map.empty())
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

### What the snippet implies

These leanings are carried forward to the milestones that decide them:

| Construct | Implies | Decided in |
| --- | --- | --- |
| `spawn`, `channel`, `<-` | Uncoloured concurrency; race freedom; closed-channel receive without zero values; `<-` as one token | M10, M01, M02 ([OQ-001](open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)) |
| `func` / `proc` | A declaration-level pure/effectful split | T0003, M08 ([OQ-004](open-questions.md#oq-004-what-does-functional-in-style-commit-qubec-to)) |
| `type Expr = … \| Binary(…, lhs: Expr, …)` | Recursive ADTs without explicit boxes: the default layer manages indirection (GC or reference counting) | M05, M07 |
| `Result`, `?`, `Ok`/`Error` | Errors as values with one-token propagation | M08 |
| `if c { … } else { … }` | Braced conditionals (rather than `if … then … else`) | M03 |
| `;` after declarations and statements | Explicit statement terminators | M02, M03 |
| Upper-case constructors in patterns | Case may carry meaning | M02, M04 |
| `"${file}"` | String templates; the lexer needs modes | M02 |
| `env.insert(…)` returning a new map | Persistent collections in the standard library | M14 |
| `file_system.read_text`, `args()` | Module paths; standard-library names | M09, M14 |
| `&[u32]`, `let mut`, `wrapping_add` | The explicit layer's marking and the numeric model | M05, M07 ([OQ-003](open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones)) |
