# R0010: Compile-time evaluation: prior art, step limits, and an evaluator throughput pilot

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M01 / T0012 |
| Used by | D0064, D0066, D0067, D0069, D0070, OQ-015 |

## Question

How do comparable languages treat unused failing constants, mutation of constants, constants in generic code, and
long-running compile-time evaluation? What step limits do they use? How fast can a simple evaluator in Rust run calls,
and so which guaranteed number of steps can our slowest engine honor?

## Sources

1. Measurements on macOS 27 (Darwin 27.0.0), arm64, on 2026-11-17, with rustc 1.99.1 and Go 1.27.2. The programs
   were throwaway files outside the repository; each is described below.
2. Rust pull request 103877, "Replace const eval limit by a lint and add an exponential backoff warning" (merged
   2023-06-01, released in Rust 1.72.0), <https://github.com/rust-lang/rust/pull/103877>.
3. The rustc documentation of the lint `long_running_const_eval`,
   <https://doc.rust-lang.org/stable/nightly-rustc/rustc_lint/builtin/static.LONG_RUNNING_CONST_EVAL.html>.
4. The LLVM `cfe-commits` discussion of Clang pull request 143785 (2025, proposing a larger default constexpr step
   limit, closed without merging) and pull request 160440 (2025, `-fconstexpr-steps=0` to disable the limit).
5. Discussions on ziggit.dev of `@setEvalBranchQuota`, and Zig compiler commits that document it (secondary sources;
   the official language reference was not read for this note).

## Findings

### Rust and Go constants (verified, source 1)

| Program | Result |
| --- | --- |
| Rust: an unused `const BAD: i32 = SPARE[3];` on a three-element array | rejected, error E0080, "evaluation of `BAD` failed here" |
| Rust: `const V: Vec<i32> = Vec::new();` then `V.push(1); println!("{}", V.len());` | compiles with a warning, "each usage of a `const` item creates a new temporary"; prints `0` |
| Rust: an associated `const SZ: usize = 10 / size_of::<T>();`, used for `u32` and `()` | rejected only for the use with `()`, error E0080, "evaluation of `S::<()>::SZ` failed": a post-monomorphization error |
| Rust: a constant whose `while` loop runs 3,000,000 iterations | rejected by the deny-by-default lint, "constant evaluation is taking a long time" |
| Rust: the same, with `#[allow(long_running_const_eval)]` on that constant | compiles; prints `3000000` |
| Go: an unused `const Spare = 1 / Z`, with `const Z = 0` | rejected, "invalid operation: division by zero" |

### Step limits

- **Rust (verified, sources 2 and 3).** Since 1.72, the fixed limit `const_eval_limit` is gone. Its replacement counts
  function calls and traversed loop back-edges. It emits the lint `long_running_const_eval` at the first power of two
  after 1,000,000 steps; the lint is denied by default and may be allowed on individual constants or on a whole crate.
  Afterwards, a warning that cannot be silenced repeats at each later power of two, so the warnings grow rarer as
  evaluation continues. An allowed constant has no limit. The PR discussion noted that an allowed infinite loop in a
  dependency hangs the build.
- **Clang (verified, source 4).** The default limit is 1,048,576 (2^20) steps, set with `-fconstexpr-steps`; a 2025
  proposal to raise it to 20,000,000 was not merged; since 2025 the value 0 disables the limit.
- **GCC (verified from secondary sources, source 4).** `-fconstexpr-ops-limit` defaults to 33,554,432 (2^25)
  operations, as cited by a Clang developer in the same discussion.
- **Zig (verified from secondary sources, source 5).** Compile-time evaluation fails after 1,000 backward branches by
  default ("evaluation exceeded 1000 backwards branches"); `@setEvalBranchQuota` raises it and must be called at the
  top of the compile-time call stack. Its standard library sets quotas up to 2,000,000 (`fmt.zig`). Users report
  confusion over where the call must be placed.

### Evaluator throughput (verified, source 1)

A naive tree-walker in Rust (about 60 lines: an expression enum with literals, arguments, checked addition and
subtraction, comparison, `if`, and calls; values as an enum; each call recursing on the host stack and allocating its
argument vector) evaluated `fib(n)`:

| Build | Calls | Time | Calls per second |
| --- | --- | --- | --- |
| release | 7,049,155 (`fib(32)`) | 0.231 s | about 30 million |
| debug | 7,049,155 (`fib(32)`) | 1.000 s | about 7 million |

A full evaluator (environments, closures, allocation of values) is likely several times slower; `qubecc`'s
compile-time evaluator, written in QubeC and run on the bytecode VM, is estimated at 0.3 to 3 million steps per second
(an estimate, not measured). At those rates, 10,000,000 steps take about 0.3 to 3 seconds in the host and about 3 to
30 seconds in `qubecc`.

### Recalled, not verified here

- C++ requires every `constexpr` variable's initializer to be a constant expression, whether or not it is used.
- Zig analyzes only referenced declarations.
- Go's package-level variable initializers run, and may panic, at program start; Go reports initialization cycles
  through function bodies.
- Java reports a failing static initializer as `ExceptionInInitializerError` on the first use of the class; Kotlin's
  `by lazy` computes on first use.
- Rust's `include_str!`, `include_bytes!`, and `env!`, Zig's `@embedFile`, Go's `//go:embed`, and C23's `#embed` embed
  build inputs.
- Zig's `@compileLog` prints during compilation and fails the compile.

## Conclusions

- Evaluating every constant, used or not, is what Rust and Go do today (D0064).
- Fresh-copy semantics for constants is real in Rust and silently discards mutation, which supports keeping mutable
  state out of constants instead (D0067).
- Post-monomorphization errors from constants in generic code are real in Rust (D0066).
- Fixed step limits have repeatedly broken legitimate code (Rust, the Clang proposal); Rust's per-constant opt-in, on
  a unit of calls and loop iterations, is the closest prior art for D0070, which adds a guarantee across
  implementations and a stated number instead of no limit.
- A guarantee of 10,000,000 steps is honored in seconds by the planned engines (D0070).
