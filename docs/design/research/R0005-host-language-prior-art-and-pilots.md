# R0005: Host languages: prior art and pilots

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Milestone / task | M00 / T0006 |
| Used by | D0029, D0030, D0031, D0032, D0033, D0034, D0035 |

## Question

The T0006 decisions choose the role and languages of the host implementation. How comfortable is each candidate
language for a front end with rule-ID diagnostics, elaboration into a typed core, and a core evaluator, measured on
the same small program? Which claims about other languages' implementations did we check?

## Sources

1. Go 1.5 release notes, https://go.dev/doc/go1.5 (found by search, summary read): the compiler and runtime are
   written in Go with a little assembly; C is no longer needed to build the distribution; bootstrapping needs Go 1.4
   or later.
2. R. Feldman, "Rewriting Roc: transitioning the compiler from Rust to Zig", gist
   https://gist.github.com/rtfeldman/77fb430ee57b42f5f2ca973a3992532f (2025), and the follow-up "How our Rust-to-Zig
   rewrite is going" (2026), seen through aggregator copies (summaries read).
3. "Bun in Rust", https://bun.com/blog/bun-in-rust (2026), and secondary coverage (summaries read).
4. Local checks with OCaml 5.5.2 and Zig 0.17.0 (see Experiments).

## Findings

- **Verified:** Go 1.5 removed C from its compiler and runtime, which are written in Go with a little assembly;
  building Go needs an earlier Go [1].
- **Verified (summaries):** Roc's compiler was written in Rust and was rewritten from scratch in Zig, reaching
  feature parity in mid-2026; the reasons given include Rust's compile times and a preference for passing allocators
  explicitly [2].
- **Verified (summaries):** Bun was rewritten from Zig into Rust in 2026, with memory-safety bugs as a stated reason;
  the release status of the Rust version varied between sources [3]. So the Zig/Rust trade-off has recent
  evidence in both directions: build speed and allocator control for Zig, memory safety for Rust.
- **Verified:** OCaml 5.5 provides `Dynarray`, and `-warn-error +8` turns a non-exhaustive match into a compile error
  [4].
- **Verified:** Zig 0.17's `export fn` produces a C-ABI symbol in a library [4].
- **Recalled:** Go's two compilers, gc and gccgo, exposed spec ambiguities between them; `mrustc` is an independent
  C++ implementation able to compile rustc; GNU Mes supports full-source bootstraps; OCaml keeps a checked-in bytecode
  boot compiler; rustc vendors and audits its crates; most VMs (Lua, CPython, the OCaml runtime, the BEAM) are written
  in C; Rust has mature libraries for source-snippet diagnostics and REPL line editing.

## Experiments

Six pilots, run in a scratch directory outside the repository and not kept. Each implemented the same specification
using only the language's standard library: a small language with `Int`, `Bool`, and function types carrying a
purity (`Pure` < `Effect`); surface forms for literals, variables, `+`, `<`, `if`, `let`, `func` and `proc` lambdas,
application, and `print`; a checker that elaborates the surface AST into a separate core AST in which every node
carries its type, rejecting with `R-var-unbound`, `R-type-mismatch`, `R-call-non-function`, or `R-func-calls-proc`;
and an evaluator over the core. Eight tests covered two successful runs with output and evaluation order, the four
rejections, a higher-order pure function, and a comparison. Each pilot then had one surface `match` case deleted to
see what the compiler said.

| Language (version) | Lines | Clean build | Run | Deleted `match` case |
| --- | --- | --- | --- | --- |
| Rust 1.99.1 (`cargo build --release`) | 221 | 1.3 s | 0.005 s | error E0004 naming the case |
| OCaml 5.5.2 (`ocamlfind ocamlopt`) | 146 | 0.4 s | 0.003 s | warning 8 naming the case |
| Lean 4.36.0 (`lake build`) | 192 | 1.4 s | 0.006 s (`lean --run`: 0.6 s) | error "Missing cases" |
| Scala 3.9.0 (scala-cli, JDK 25) | 184 | 2.2 s | 0.13 s packaged JAR | warning naming the case |
| Zig 0.17.0 (`zig build-exe`, Debug) | 313 | 1.8 s | 0.014 s | error naming the case |
| Go 1.27.2 (`go build`) | 385 | 2.2 s | 0.005 s | nothing: compiler and `go vet` silent |

All six produced the expected output for all eight tests. Line counts exclude blank and comment lines; times are
wall-clock on one machine and indicative only. Friction observed:
- **Rust:** `Box` for trees, `Rc` for closure bodies and environments, `clone` for names; no borrow-checker conflicts.
- **OCaml:** none beyond defining `let*` for `Result`.
- **Lean:** the evaluator needed `partial def` (closure bodies are not structurally smaller), with an `Inhabited`
  instance; values and environments formed a `mutual` inductive pair.
- **Scala:** a method name clashed with a case field; `@main` needed an explicit main class for scala-cli.
- **Zig:** errors carry no payload, so diagnostics went through a side channel; the new `std.Io` API differed from
  earlier releases; the process arena made trees easy.
- **Go:** sum types as interfaces with marker methods and type switches; verbose error checks; `panic("unreachable")`
  after each switch.

## Conclusions

Every candidate can host a front end; the differences that matter for a permanent host are exhaustiveness checking
(an error in Rust, Lean, and Zig; a warning in OCaml and Scala; absent in Go), the ecosystem for user-facing
diagnostics and REPLs, and toolchain churn (high in Zig and Lean). Recent rewrites between Rust and Zig in both
directions confirm that the trade-off between them is real.
