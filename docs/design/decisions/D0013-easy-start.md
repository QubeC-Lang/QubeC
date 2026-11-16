# D0013: Easy start is a must-have: run a file directly, and a REPL

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

Beyond the ranked values ([D0004](D0004-ranked-design-values.md)), which goals are **must-haves**: obligations that
every later milestone has to satisfy, rather than tie-breakers? Spec formality and proofs are excluded here; they are
decided in T0004 and T0005.

## Options considered (multi-select)

The scenario is the same for all: a small word-count tool, `wc.qbc`. Provisional syntax.

### A. Easy start: run a file directly, and a REPL

A single file runs without a project file or build step; hello world is one line inside `main`; an interactive
read-eval-print loop (REPL) exists early.

```
$ qubec run wc.qbc notes.txt
words: 412
$ qubec repl
> let xs = [3, 1, 2];
> xs.sorted()
[1, 2, 3] : List[Int]
```

Forces a run mode (M01), single-file programs (M09), and incremental checking for the REPL (M16). Prior art
(recalled): Python, `go run`, Kotlin scripts, OCaml's toplevel; Rust's lack of a REPL is a common complaint.

### B. First-class diagnostics

Error messages are designed with each feature; a feature whose errors cannot be explained clearly counts against it.

```
error: this result is ignored
  ┌─ wc.qbc:7:3
7 │   file_system.read_text(path);
  │   ^^^^^^^^^^^^^^^^^^^^^^^^^^^ returns Result[Str, IoError]
  = help: handle it with `?`, or `match` on it
```

Forces every milestone to write diagnostics alongside rules. Prior art (recalled): Elm and Rust.

### C. Fast compilation

Build speed as an obligation with a budget (for example, the self-hosted compiler rebuilds in seconds). Forces M01,
M05, M06, M11, and M16. Prior art (recalled): Go made it a founding goal.

### D. C interop early

Calling C, and being called from C, before M12. Pulls the unsafe escape hatch (M07) forward, and interacts with a
task scheduler (cgo's overhead is the precedent).

```
extern "C" func isatty(fd: i32) -> i32;
proc main() { let color = unsafe { isatty(1) } == 1; … }
```

Recommendation at the time: **A and B**. C is already weighed by the self-hosting yardstick as a tie-breaker, and D
conflicts in timing with uncoloured concurrency (OQ-001).

## Choice

**A only.**
- `qubec run file.qbc` runs a single source file with no project file or separate build step.
- Hello world is one line inside `main`.
- An interactive REPL is available early in the implementation.

The other candidates stay what they were: diagnostics remain a first-order concern of M05 and M15
([D0003](D0003-target-users.md)), compile speed a tie-breaker under the yardstick
([D0002](D0002-purpose-and-domain.md)), and C interop part of M12.

## Rationale

The initial idea asks for a language that is easy to start with, like Python; this makes that part of it a
checkable obligation. The other candidates remain served in the ways listed under Choice, without becoming
obligations.

## Consequences

- **M01:** a run mode that compiles and executes in one step.
- **M09:** a single file is a complete program, with no manifest required.
- **M15, M16:** a REPL early in the implementation plan, which needs incremental checking and evaluation of
  declarations one at a time.

## Affected artifacts

- Spec: none yet (M01, M09)
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md)
