# D0058: Exit statuses are 0, 1, 101 for a panic, and 102 for resource exhaustion

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

An **exit status** is the integer a finished process hands back to whoever started it; scripts branch on it. It is
part of the outcome ([D0048](D0048-trace-and-outcome.md)), so it must be the same on every platform
([D0051](D0051-deterministic-sequential-language.md)). On POSIX only the low 8 bits survive (verified: `exit 256` is
seen as `0`); shells reserve 126, 127, and 128 + n for "cannot execute", "not found", and "killed by signal n";
Windows, in Tier 3 ([D0046](D0046-first-platforms-and-tiers.md)), passes 32 bits. Which statuses does a run end with?

Common to every option:
- returning normally from `main`, or returning `Ok(())` from the result form ([D0057](D0057-forms-of-main.md)), gives
  `0`;
- returning `Err(e)` writes the display of `e` to standard error, then gives `1`;
- `exit(n)` gives `n` for 0 ≤ n ≤ 255 on every platform, and any other `n` panics, so no platform truncates it
  differently; pending output is delivered first.

## Options considered

The scenario for every option (provisional syntax):

```
proc main() -> Result[Unit, IoError] {
  let argv = args();
  if argv.len() != 2 { eprint("usage: wc FILE"); exit(2); }   // usage error: 2
  let text = read_file(argv[1])?;                            // Err: 1
  print(count_words(text).to_str());
  let xs = [1, 2]; xs[5];                                    // panic: P
  Ok(())                                                     // success: 0
}
```

Measured on macOS arm64 ([R0009](../research/R0009-runtime-and-lifecycle-pilots.md)): a Rust panic exits 101, and a
Rust stack overflow aborts with 134; a Go panic exits 2; an uncaught OCaml exception exits 2; a Zig panic exits 134.

### A. Panic and exhaustion both exit 101

- **Easy:** a script distinguishes a reported error (1) and a usage error (2) from a bug (101); outside every
  reserved range; familiar from Rust.
- **Hard:** exhaustion and panic differ only in the report line.

### B. Panic exits 101; exhaustion exits 102

- **Easy:** a script, a CI job, or the conformance harness sees from the status alone that a run ran out of stack or
  memory, the one outcome that may legitimately differ between implementations
  ([D0053](D0053-resource-exhaustion.md)).
- **Hard:** one more number.

### C. Panic and exhaustion both exit 2

- **Easy:** as Go and OCaml.
- **Hard:** 2 is the common convention for usage errors (`grep`, `diff`), so a tool following it cannot tell bad
  arguments from a crash.

Not offered: 134, an abort as if by a signal, which would mean raising a real signal and has no portable equivalent.

Recommendation at the time: **B**, because it makes the one permitted variation easy to handle mechanically.

## Choice

**B.**

| Outcome | Exit status |
| --- | --- |
| `main` returns normally, or returns `Ok(())` | 0 |
| `main` returns `Err(e)`, after the display of `e` is written to standard error | 1 |
| `exit(n)`, for 0 ≤ n ≤ 255 | n |
| a panic, including `exit(n)` with any other `n` | 101 |
| resource exhaustion | 102 |

1. These statuses are the same on every platform. Termination by the environment is not one of them: the platform
   reports it in its own way ([D0060](D0060-termination-by-the-environment.md)).
2. On every one of these exit paths, all pending output is delivered first (D0048), and for a panic or exhaustion
   the report line is written after it ([D0059](D0059-report-line-and-backtrace.md)).
3. The text written for `Err(e)` is *Provisional
   ([OQ-013](../open-questions.md#oq-013-what-exactly-is-the-result-form-of-main))*. The kind of the panic for an
   out-of-range `exit` is M14's.
4. Whether `exit` runs cleanup (M07) is decided with cleanup; it never skips the delivery of pending output.

## Rationale

The statuses separate the four things a caller wants to know: success, an error the program reported, a bug, and a
run that ran out of resources. The last is the one outcome the specification lets differ between implementations, so
giving it its own status lets scripts and the conformance harness treat it mechanically. 101 and 102 avoid every
range shells reserve and the common usage-error status. Restricting `exit` to 0–255 everywhere keeps a platform
difference from reaching the outcome.

## Consequences

- **M07:** says whether `exit` runs cleanup.
- **M14:** provides `exit` and the kind of its out-of-range panic; if M05 gives a byte-sized type, `exit` may take it
  and the panic disappears.
- **Conformance suite:** a test's expected outcome includes its status; a test that may exhaust a resource accepts
  102 with the exhaustion line, or its expected outcome.
- **M15:** tools may print a hint on 101 or 102, outside the trace.

## Affected artifacts

- Spec: [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) (new)
- Grammar rules: none
- Formal rules: none yet (the outcome's exit status, M03)
- Examples / tour: [vision.md](../vision.md)
