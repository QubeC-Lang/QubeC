# Vision

Status: **Vision I and II complete** (T0002, T0003); **how QubeC is specified** decided (T0004), including **how far
it is formalized** (T0005); **how QubeC is first implemented** decided (T0006); **how design and implementation are
planned** decided (T0007); **how QubeC runs** decided (T0009). Each part links to the decision record that settles it.

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
| NG-9 | Implicit conversions, and undefined behavior in safe code |
| NG-10 | Silently ignorable errors, and error-handling noise |
| NG-11 | Invisible inserted code that a reader cannot find or a diagnostic cannot explain |

## Inspirations and anti-inspirations ([D0006](decisions/D0006-inspirations.md))

- **ML:** ADTs and exhaustive `match`, inference, expression orientation, persistent data.
- **Rust:** `Result` and `?`, expression blocks, traits, ownership for the explicit layer, Cargo-grade tooling.
- **Kotlin and Scala 3:** null-safety, trailing lambdas, extension functions, string templates, data and enum types.
- **Go:** lightweight tasks, channels, and `select`, without `async` coloring.

We guard against undefined behavior and implicit conversions (C, C++), `null` and boilerplate (classic Java),
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
| **Recursion is safe.** Tail calls marked `tailcall f(x)` are checked and run in constant stack; stacks are growable. | [D0012](decisions/D0012-tail-calls-and-stacks.md), [D0014](decisions/D0014-tailcall-keyword.md) |

## Must-haves

| Must-have | Record |
| --- | --- |
| **Easy start:** `qubec run file.qbc` with no project setup, a one-line hello world, and a REPL early. | [D0013](decisions/D0013-easy-start.md) |

## How QubeC is specified (T0004, T0005)

| Commitment | Record |
| --- | --- |
| **One specification** for programmers and implementers, covering the language and its **core library**; it does not teach, the tour does. | [D0015](decisions/D0015-spec-audience-and-scope.md) |
| **Authority per chapter:** formal rules govern an aspect only once it is promoted to formally complete; elsewhere the prose governs. | [D0016](decisions/D0016-authority-per-section.md) |
| **Rule style:** legality rules are declarative; run-time behavior is numbered steps wherever order is observable. | [D0017](decisions/D0017-rule-style.md) |
| **Every violation is diagnosed,** and every rejection rule has a permanent ID (`R-func-calls-proc`) that a rejecting compiler reports. | [D0018](decisions/D0018-diagnosis-and-rule-ids.md) |
| **Extensions** take effect only in files that opt into them by name. | [D0019](decisions/D0019-extensions-by-source-opt-in.md) |
| **US English** spelling everywhere, including library names. | [D0020](decisions/D0020-us-english-spelling.md) |
| **Formal target:** the whole sequential language has formal rules and theorems; concurrency stays in prose. | [D0021](decisions/D0021-formal-target-sequential-language.md) |
| **Typed elaboration:** surface legality rules translate programs into an explicitly typed core, over which the dynamics are defined. | [D0022](decisions/D0022-typed-elaboration-into-core.md) |
| **Claimed theorems:** type soundness, elaboration soundness, purity with a frame property, the tail-call space bound, determinism, decidable checking. | [D0023](decisions/D0023-claimed-meta-properties.md) |
| **The core is mechanized in Lean 4,** which governs the core rules, and it runs as a verified reference evaluator and checker. Elaboration proofs are on paper. The mechanization starts in M03. | [D0024](decisions/D0024-mechanize-the-core.md)–[D0028](decisions/D0028-mechanization-starts-in-m03.md) |

## How QubeC is implemented (T0006)

| Commitment | Record |
| --- | --- |
| **A permanent host implementation** that leads every feature: the self-hosted compiler never has a feature the host lacks, and once QubeC self-hosts, every release needs both to pass the whole conformance suite. | [D0029](decisions/D0029-permanent-host-implementation.md) |
| **Three parts, connected through the typed core:** the **host interpreter** (Rust: front end, tree-walking core interpreter, REPL, driver; it makes every rejection), the **host compiler** (OCaml: typed core → bytecode), and the **host VM** (Zig: interpreter loop, heap and GC, stacks, natives, as a C-ABI library). | [D0030](decisions/D0030-three-part-host.md)–[D0033](decisions/D0033-zig-host-vm.md) |
| **Idiomatic code in each part,** with conformance (rule IDs, checked core, the specified formats) as the only shared contract; the self-hosted compiler is designed fresh. | [D0034](decisions/D0034-idiomatic-code-per-part.md) |
| **Pinned toolchains,** and third-party libraries only when recorded with their purpose and locked by checksum. | [D0035](decisions/D0035-pinned-toolchains-and-recorded-libraries.md) |

## How the work is planned (T0007)

| Commitment | Record |
| --- | --- |
| **Implementation trails the design:** it starts once the execution model (M01) and the lexical structure (M02) are decided, implements only closed design milestones, and design never waits for it. | [D0036](decisions/D0036-trailing-implementation-track.md) |
| **Two tracks of milestones:** design milestones M00, M01, … and implementation milestones I1, I2, …, with tasks in one series and at most one Active task per track. | [D0037](decisions/D0037-implementation-milestones-and-tasks.md) |
| **Four implementation stages:** I1 the front end and core interpreter, I2 the complete host with its compiler and VM, I3 the self-hosted compiler and the fixpoint, I4 concurrency, metaprogramming, and interop in both. Each architecture is designed at the start of the stage that builds it. | [D0038](decisions/D0038-m16-merged-into-implementation-milestones.md), [D0039](decisions/D0039-four-implementation-stages.md) |
| **The design milestones stay as drafted,** with corrected dependencies. | [D0040](decisions/D0040-design-milestones-kept.md) |
| **Spec v1.0 waits for the self-hosting test:** it is published only after both implementations implement the whole specification. | [D0041](decisions/D0041-spec-v1-after-i4.md) |

## How QubeC runs (T0009)

| Commitment | Record |
| --- | --- |
| **Two engines:** a tree-walking interpreter of the typed core and a bytecode VM; no JIT is planned. | [D0042](decisions/D0042-tree-walker-and-bytecode-vm.md) |
| **Native code after Spec v1.0,** and meanwhile no feature may need a VM at run time, so that native code is a pure speed-up when it comes. | [D0043](decisions/D0043-native-code-after-v1.md) |
| **A build is one self-contained executable;** bytecode can be emitted for inspection, and loads only in the release that wrote it. | [D0044](decisions/D0044-executables-and-unstable-bytecode.md) |
| **Running a file directly behaves as building and executing it;** the engine is each implementation's choice. | [D0045](decisions/D0045-run-is-a-shortcut.md) |
| **Linux x86-64 and macOS arm64 first,** with Linux arm64 and RISC-V next and Windows later, in three tiers; the host implementation can build the self-hosted compiler for every platform it supports. | [D0046](decisions/D0046-first-platforms-and-tiers.md), [D0047](decisions/D0047-platform-parity.md) |

## What every run can rely on (T0010)

| Commitment | Record |
| --- | --- |
| **Observable behavior is a trace and an outcome:** the ordered interactions with the environment, then a return, a panic, resource exhaustion, termination by the environment (added in T0011), or divergence. Nothing else, not even `dbg` output or timing, is observable. | [D0048](decisions/D0048-trace-and-outcome.md) |
| **Panics are precise,** with their kind, message, and source location the same everywhere; no engine, build profile, or optimization changes what a program does, and no build setting removes a check. | [D0049](decisions/D0049-precise-panics.md), [D0050](decisions/D0050-panic-contents.md) |
| **One meaning everywhere:** the same program with the same inputs behaves the same on every implementation and platform, including bit-identical floating point. | [D0051](decisions/D0051-deterministic-sequential-language.md), [D0052](decisions/D0052-bit-identical-floats.md) |
| **The one exception is running out of stack or memory,** which may happen at different points above a guaranteed depth, never with a wrong result; structural limits on programs are exact rules, so every implementation accepts the same programs. | [D0053](decisions/D0053-resource-exhaustion.md), [D0054](decisions/D0054-implementation-limits-as-rules.md) |

## How a run starts and ends (T0011)

| Commitment | Record |
| --- | --- |
| **One runtime contract, independent runtimes:** the host's Rust and Zig runtimes each meet one written contract (memory, stacks, natives, the outcome and its report, output delivery), so differential tests check them against each other; native code after v1.0 links a runtime written in QubeC. | [D0055](decisions/D0055-runtime-contract-and-runtimes.md) |
| **Thin natives:** only the boundary with the operating system is supplied by each runtime; everything else in the standard library, float printing and math included, is QubeC source that every runtime runs. | [D0056](decisions/D0056-thin-natives.md) |
| **`main` has two forms,** `proc main()` and `proc main() -> Result[Unit, E]`; arguments come from the library, as inputs. | [D0057](decisions/D0057-forms-of-main.md) |
| **Exit statuses mean the same everywhere:** 0 success, 1 an error returned from `main`, `exit(n)` for 0–255, 101 a panic, 102 resource exhaustion; pending output is always delivered first. | [D0058](decisions/D0058-exit-statuses.md) |
| **A failure is reported in one line** on standard error, identical on every engine, with an optional backtrace after it that is not observable. | [D0059](decisions/D0059-report-line-and-backtrace.md) |
| **Interrupts and closed pipes end a run quietly:** termination by the environment is an outcome of its own, abrupt by default; other output failures panic. | [D0060](decisions/D0060-termination-by-the-environment.md), [D0061](decisions/D0061-failed-standard-output.md) |
| **Deep recursion is safe to 100,000 nested calls** on every implementation, and much deeper by default; the stack cap can be raised. | [D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md) |

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
  for file in files { spawn { results <- (file, compile(file)); } }   // no async coloring
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

func skip_spaces(cs: List[Char], i: Int) -> Int =     // constant stack via a checked tail call (D0012, D0014)
  if i < cs.len() && cs[i] == ' ' then tailcall skip_spaces(cs, i + 1) else i;

proc main() -> Result[Unit, IoError] {                // effects only in procs (D0008); a form of main (D0057)
  let text   = file_system.read_text(Path.of(args()[0]))?;   // an error: shown on stderr, status 1 (D0058)
  let counts = dbg(count(tokenize(text)));             // dbg: allowed, output not observable
  for (w, n) in counts.sorted_by_value().reversed().take(TOP) { println("${w}: ${n}"); }
  Ok(())                                               // status 0; a panic gives its report line and 101 (D0059)
}
// $ qubec run wc.qbc notes.txt | head -3              (D0013; head closing the pipe ends the run quietly, D0061)
```

### What the snippet implies

These leanings are carried forward to the milestones that decide them:

| Construct | Implies | Decided in |
| --- | --- | --- |
| `spawn`, `channel`, `<-` | Uncolored concurrency; race freedom; closed-channel receive without zero values; `<-` as one token | M10, M01, M02 ([OQ-001](open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)) |
| `func` / `proc` | Decided: the pure/effectful split ([D0008](decisions/D0008-purity.md)); effect mechanics | M08 |
| `type Expr = … \| Binary(…, lhs: Expr, …)` | Recursive ADTs without explicit boxes: the default layer manages indirection (GC or reference counting) | M05, M07 |
| `Result`, `?`, `Ok`/`Error` | Errors as values with one-token propagation | M08 |
| `if c { … } else { … }` | Braced conditionals (rather than `if … then … else`) | M03 |
| `;` after declarations and statements | Explicit statement terminators | M02, M03 |
| Upper-case constructors in patterns | Case may carry meaning | M02, M04 |
| `"${file}"` | String templates; the lexer needs modes | M02 |
| `ImmutableMap`, `env.insert(…)` returning a new map | Decided: immutable collections in the library, mutable by default ([D0010](decisions/D0010-mutable-default-collections.md)); final names | M14 |
| `file_system.read_text`, `args()` | Module paths; standard-library names | M09, M14 |
| `let mut`, `dbg` | Placeholder spellings under D0007 (`tailcall` is decided, [D0014](decisions/D0014-tailcall-keyword.md)) | M02, M03, M14 ([OQ-005](open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)) |
| `&[u32]`, `wrapping_add` | The explicit layer's marking and the numeric model | M05, M07 ([OQ-003](open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones)) |
