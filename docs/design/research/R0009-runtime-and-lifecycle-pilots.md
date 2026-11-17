# R0009: Runtime and program lifecycle: exit statuses, broken pipes, and stack depth pilots

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M01 / T0011 |
| Used by | D0057, D0058, D0059, D0061, D0062, OQ-012 |

## Question

What exit statuses do comparable languages use for a panic, a stack overflow, and an error returned from `main`? How
do they behave when standard output's reader goes away? How much host stack does a recursive tree-walking interpreter
in Rust use per interpreted call, and so which guaranteed call depth can our tree-walker reach?

## Sources

1. Measurements on macOS 27 (Darwin 27.0.0), arm64, on 2026-11-17, with rustc 1.99.1, Go 1.27.2, OCaml (Homebrew),
   Zig 0.17.0, and Python 3. The programs were throwaway files outside the repository; each is described below.
2. Go 1.27.2 source, `src/runtime/proc.go`, lines 164–172 (`maxstacksize`, `maxstackceiling`).
3. POSIX `execve` and `exit` (recalled): arguments are NUL-terminated byte strings; the parent observes the low
   8 bits of the status.

## Findings

### Exit statuses (verified, source 1)

| Program | Status |
| --- | --- |
| Rust, an index out of bounds (panic) | 101 |
| Rust, unbounded recursion (stack overflow) | 134 (abort, 128 + SIGABRT), "fatal runtime error: stack overflow" |
| Rust, `fn main() -> Result<(), String>` returning `Err` | 1, after `Error: "boom"` on standard error |
| Go, an index out of bounds, built binary | 2 (`go run` reports 1 for the child's failure) |
| OCaml, an uncaught exception | 2 |
| Zig, `@panic` | 134 |
| `sh -c 'exit 256'`, Python `SystemExit(256)` | 0 (only the low 8 bits survive) |

Rust's panic report is two lines, `thread 'main' (<id>) panicked at <file>:<line>:<column>:` and the message, then a
note about `RUST_BACKTRACE`; it is not a stable format.

### Broken pipes (verified, source 1)

Each program printed 100,000 lines into `| head -1`:

| Language | Standard error | Writer's status |
| --- | --- | --- |
| Rust (`println!`) | a panic: "failed printing to stdout: Broken pipe (os error 32)" | 101 |
| Go (`fmt.Println`) | nothing | 141 (128 + SIGPIPE) |
| OCaml (`print_endline`) | nothing | 141 |
| Python (`print`) | "Exception ignored on flushing sys.stdout: BrokenPipeError" | 120 |

### Stack depth of a Rust tree-walker (verified, source 1)

A minimal tree-walking evaluator over a typed core expression type (integers, variables, `+`, `-`, `==`, `if`, and
calls with an argument vector), with checked arithmetic and `Result` for errors, ran
`f(n) = if n == 0 then 0 else 1 + f(n - 1)` on a thread with an 8 GiB stack reservation. Host stack per interpreted
call was measured from the addresses of locals:

| Build | Bytes per call | Depth 100,000 | Depth 1,000,000 |
| --- | --- | --- | --- |
| release (`rustc -O`) | 768 | 73 MiB stack (RSS 82 MB) | 732 MiB stack (RSS 802 MB) |
| debug | 7,584 | 723 MiB stack (RSS 764 MB) | 7.1 GiB stack (RSS 6.3 GB) |

A full interpreter, with richer environments, pattern matching, and larger error types, will use more per call; two
to four times is an estimate, not a measurement. A VM frame kept in a heap array was not measured; about 100 bytes per
call is an estimate.

### Limits elsewhere (verified, sources 1 and 2)

- Go's maximum goroutine stack is 1,000,000,000 bytes on 64-bit platforms and 250,000,000 on 32-bit ones.
- Python's default recursion limit is 1000.
- The default main-thread stack limit on the measuring machine is 8 MiB (`ulimit -s` reports 8176 KiB).

## Conclusions

- 101 is a well-known panic status outside every shell-reserved range; 2 collides with the usage-error convention;
  134 is an abort by signal, which has no portable equivalent (D0058).
- Quiet termination on a broken pipe is the behavior of Go, OCaml, and C; Rust's panic on a broken pipe is noisy in
  ordinary pipelines (D0061).
- A recursive tree-walker in Rust reaches 100,000 nested calls in well under 1 GiB in release builds, even allowing
  for a fourfold increase; 1,000,000 would need gigabytes and probably a different interpreter architecture (D0062).
