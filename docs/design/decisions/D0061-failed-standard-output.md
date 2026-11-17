# D0061: A closed reader of standard output or error ends the run quietly; any other failed write to them panics

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

Writing to standard output or error can fail. The common case for command-line tools is `prog | head -1`: once `head`
has its line it exits, and the program's next write fails with "broken pipe" (EPIPE), which on POSIX also raises
SIGPIPE, whose default action kills the writer silently. Rarer failures are a full disk behind a redirection, or a
closed stream. Every write is an event and its failure is that event's response ([D0048](D0048-trace-and-outcome.md)).
What does the language do by default? M14's explicit writers may offer finer control.

## Options considered

The scenario for every option (provisional syntax), run as `qubec run gen.qbc | head -1`:

```
proc main() {
  for i in 0..100_000 { print(i.to_str()); }
}
```

Measured on macOS arm64 with the same program in each language
([R0009](../research/R0009-runtime-and-lifecycle-pilots.md)): Rust panics ("failed printing to stdout: Broken pipe")
and exits 101; Go and OCaml die silently by SIGPIPE (141); Python reports `BrokenPipeError` and exits 120.

### A. A closed reader ends the run quietly; any other failure panics

A write to standard output or error that fails because its reader has gone ends the run as terminated by the
environment ([D0060](D0060-termination-by-the-environment.md)), with no report. Any other failed write to them panics
with an "output failed" kind.

```
$ qubec run gen.qbc | head -1
0                                   (nothing else; the writer died by SIGPIPE: 141)
$ qubec run gen.qbc > /full-disk/out.txt
panic: output failed: no space left on device at gen.qbc:2:23        (status 101)
```

- **Easy:** `| head`, `| grep -q`, and quitting `less` behave as Unix tools are expected to; real failures stay loud.
- **Hard:** two cases to tell apart.
- **Prior art:** Go's rule, SIGPIPE on standard output and error kills while other descriptors get an error (the
  behavior verified, the rule recalled from Go's documentation); OCaml and C by default.

### B. Every failed write to standard output or error panics

```
$ qubec run gen.qbc | head -1
0
panic: output failed: broken pipe at gen.qbc:2:23                    (status 101)
```

- **Easy:** one rule, never silent.
- **Hard:** a harmless, common use prints an alarming panic and fails, turning success into failure under
  `set -o pipefail`.
- **Prior art:** Rust (verified); a long-standing complaint, for which Rust has an unstable attribute (recalled).

### C. `print` returns a result the program must handle

```
proc main() -> Result[Unit, IoError] {
  for i in 0..100_000 { print(i.to_str())?; }   // NG-10: a result cannot be ignored
  Ok(())
}
```

- **Easy:** fully explicit.
- **Hard:** every `print` needs handling, hello world included (against [D0013](D0013-easy-start.md)), since NG-10
  forbids ignoring errors ([D0005](D0005-non-goals.md)); a broken pipe still ends with an error and status 1 unless
  every tool special-cases it.
- **Prior art (recalled):** Go's `fmt.Println` returns an error that is nearly always ignored.

Recommendation at the time: **A**: a reader that has gone is the environment ending the conversation, which is what
D0060's outcome describes.

## Choice

**A.**
1. If a write to standard output or standard error fails because the stream's reader has closed it (on POSIX, a
   broken pipe), the run ends as **terminated by the environment** (D0060): no report line, and on POSIX the run
   dies by SIGPIPE, as the platform's default does.
2. Any other failure of a write to standard output or standard error is a panic with an "output failed" kind, whose
   message names the failure. Its report line is written to standard error if standard error still works
   ([D0059](D0059-report-line-and-backtrace.md)).
3. Writes to files and other destinations report failures through M14's API.
4. The kind's exact name and message are *Provisional
   ([OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter))*.

## Rationale

Pipelines that stop reading early are part of everyday use of command-line tools, QubeC's tie-breaking domain
([D0002](D0002-purpose-and-domain.md)); treating them as the environment ending the run keeps them quiet and keeps the
pipeline's status honest. A full disk or a stream that fails for another reason is a real failure the user must see.
The simple `print` stays free of results, and M14's explicit writers can give programs full control.

## Consequences

- **The runtimes** do not let SIGPIPE kill the process blindly: a closed reader of other destinations is reported
  through M14's API, and for standard output and error the runtime ends the run as above.
- **M14:** the standard-output procedures, explicit writers with results, and a way to ask for broken-pipe errors
  instead of termination.
- **Conformance suite:** tests close the reader of standard output at a stated point.

## Affected artifacts

- Spec: [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) (new)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
