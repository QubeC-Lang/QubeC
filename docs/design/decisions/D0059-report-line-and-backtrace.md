# D0059: A panic or exhaustion is reported in one specified line on standard error, then an optional backtrace

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

A panic's kind, message, and source location are observable, and a backtrace is not
([D0050](D0050-panic-contents.md)); an exhaustion outcome names the resource and has no location
([D0053](D0053-resource-exhaustion.md)). How do they reach the user: is the text written to standard error an event,
the same on every engine, or only a presentation of the outcome? The location's exact form waits for T0013 and M02,
and each kind's wording for M05, M08, and M14.

## Options considered

The scenario for every option (provisional syntax):

```
func at(xs: List[Int], i: Int) -> Int = xs[i];                     // geo.qbc, line 1
func second(xs: List[Int]) -> Int = at(xs, 5);                     // line 2
proc main() { print("start"); print(second([1, 2]).to_str()); }   // line 3
```

### A. One specified report line, then an optional backtrace after a delimiter

After delivering pending output, the runtime writes exactly one line to standard error; that line is an event,
identical everywhere. If an input of the run asks for it, a delimiter line and a backtrace follow; everything from the
delimiter on is outside the trace.

```
stdout: start
stderr: panic: index out of bounds: index 5, length 2 at geo.qbc:1:41
        --- backtrace (not observable) ---        ← only on request
          at      geo.qbc:1:41
          second  geo.qbc:2:37
          main    geo.qbc:3:44
exhaustion:  exhausted: stack        (or: exhausted: memory; no location)
```

- **Easy:** a merged log of standard output and error is byte-identical everywhere; the suite compares it as text;
  the optimizer stays free, because backtraces are excluded.
- **Hard:** the format must be fixed exactly; tests strip what follows the delimiter.
- **Prior art:** Rust's opt-in `RUST_BACKTRACE` (recalled); Rust's own panic text is not a stable format (two lines,
  observed in [R0009](../research/R0009-runtime-and-lifecycle-pilots.md)).

### B. Only the outcome is observable; the text is each tool's choice

The runtime may print a rich, multi-line report; the conformance harness reads the outcome through a separate
machine-readable channel.

```
stderr: error[panic]: index out of bounds
          ┌─ geo.qbc:1:41
        1 │ func at(xs: List[Int], i: Int) -> Int = xs[i];
          │                                         ^^^^^ index 5, length 2
harness:  {outcome: panic, kind: index-out-of-bounds, message: "…", at: geo.qbc:1:41}
```

- **Easy:** friendly runtime errors that each implementation can improve.
- **Hard:** standard error no longer compares as text; scripts cannot rely on it; every implementation needs a side
  channel; an excerpt needs the source inside the executable.
- **Prior art (recalled):** Go's panic output and Java's stack traces are unspecified text.

### C. One specified multi-line report with a source excerpt

B's rich format, fixed exactly and observable, with no backtrace.

- **Easy:** friendly and comparable.
- **Hard:** every layout detail (carets, wide characters, tabs, long lines) is normative across three runtimes;
  executables embed their source; the report can never improve without changing observable behavior.

Recommendation at the time: **A**, the only option that keeps a failing run's whole trace comparable as text without
a side channel or a frozen rich layout.

## Choice

**A.**
1. **The report line.** When a run panics or exhausts a resource, the runtime first delivers all pending output
   ([D0048](D0048-trace-and-outcome.md)), then writes exactly one line to standard error. The line is an event of the
   trace, identical on every implementation, engine, and platform:
   - for a panic: `panic: <kind>: <message> at <location>`;
   - for resource exhaustion: `exhausted: stack` or `exhausted: memory`, with no location.
2. **The backtrace.** If an input of the run requests it, the runtime then writes a fixed delimiter line and a
   backtrace. Everything from the delimiter to the end of the run is not observable, like `dbg` output; it may be
   incomplete. How it is requested is M15's.
3. **Then the exit status** of [D0058](D0058-exit-statuses.md): 101 or 102.
4. **If the line cannot be written** (standard error is closed or fails), the outcome and its status are unchanged.
5. *Provisional ([OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter)):*
   the exact text of the location (T0013, M02), the names of kinds and their messages (M05, M08, M14), how a message
   containing a line break is written, and the delimiter's text.

## Rationale

The trace already includes the bytes written to standard error and their order relative to standard output, so a
specified report line is what keeps a failing run, the case users examine most, exactly comparable between the two
implementations, their engines, and the reference. One line is little to fix; excluding the backtrace keeps
optimizations and `tailcall` free. Friendlier explanations can come from tools, outside the trace.

## Consequences

- **T0013, M02:** fix the location's text. **M05, M08, M14:** name each kind and its message.
- **M15:** names the input that requests a backtrace (for example an environment variable), and may let tools explain
  a report afterwards, outside the trace.
- **I1, I2:** both runtimes write the line; the conformance harness compares standard error up to the delimiter.
- **The reference evaluator** produces the line as the final event of a failing run.

## Affected artifacts

- Spec: [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) (new)
- Grammar rules: none
- Formal rules: none yet (M03, M08)
- Examples / tour: [vision.md](../vision.md)
