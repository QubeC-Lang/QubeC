# D0060: A run ended from outside has the outcome "terminated by the environment," abruptly by default

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — (extends the outcomes of [D0048](D0048-trace-and-outcome.md)) |
| Milestone / task | M01 / T0011 |

## Question

[D0048](D0048-trace-and-outcome.md) lists four outcomes: a return, a panic, resource exhaustion, and divergence. None
covers a run that the environment stops: an interrupt from the keyboard (SIGINT on POSIX), a request to terminate
(SIGTERM), a kill that cannot be caught (SIGKILL), or a closed terminal (SIGHUP). A **signal** arrives asynchronously,
at any instruction; POSIX's default is that the process dies, and its parent sees "killed by signal n" (a shell shows
128 + n). How programs handle interrupts is M14's and M10's API; what does the language say by default?

## Options considered

The scenario for every option: the user presses Ctrl-C during the loop (provisional syntax).

```
proc main() {
  let out = buffered_writer(stdout());       // M14: explicit buffering (D0048)
  for i in 0..10_000_000 {
    out.write(i.to_str() + "\n");            // the interrupt arrives somewhere here
  }
  out.flush();
}
```

### A. A new outcome, abrupt by default

The run's outcome is **terminated by the environment**; its trace is a prefix of the trace it would otherwise have
had. The runtime runs no cleanup and flushes no explicit writer, and lets the platform's default action happen, so the
parent sees a real death by the signal. Output written directly is never lost, because there is no hidden buffering;
only what an explicit writer still holds is dropped.

```
outcome:  terminated by the environment (SIGINT)    the parent sees 130
trace:    the output events up to the last flush; the writer's unflushed part is gone
```

- **Easy:** simple; matches what shells expect; needs no safe points; native code gets it for free.
- **Hard:** an orderly shutdown needs the opt-in API.
- **Prior art (recalled):** the defaults of Go (deferred functions do not run), Rust, and C.

### B. A new outcome, orderly by default

On an interrupt or termination request, the runtime sets a flag that each engine checks at **safe points** (loop back
edges, calls); then it flushes explicit writers, runs cleanup, and raises the signal again. SIGKILL stays abrupt.

- **Easy:** nothing buffered is lost on Ctrl-C.
- **Hard:** every engine, native code included, polls at safe points, which then have to be specified; cleanup at an
  arbitrary point interacts with M07 and M10.
- **Prior art (recalled):** Python's `KeyboardInterrupt`; Java's shutdown hooks.

### C. Not modeled

The specification covers only runs the environment lets finish; an interrupted run has no outcome.

- **Easy:** nothing to specify.
- **Hard:** silent about something every command-line user does daily; M14's interrupt API has nothing to attach to.
- **Prior art (recalled):** CompCert's behaviors assume the program is never killed.

Recommendation at the time: **A**, because D0048 already rules out hidden buffering, so the abrupt default loses only
what a program deliberately held, and orderly shutdown stays a visible choice.

## Choice

**A.**
1. A fifth outcome is added to D0048's list: **terminated by the environment**. It applies when the environment ends
   a run, for example by a signal on POSIX, or when standard output or error is closed by its reader
   ([D0061](D0061-failed-standard-output.md)).
2. The trace of a terminated run is a prefix of the trace it would have had otherwise. When the environment ends a
   run is an input, so determinism ([D0051](D0051-deterministic-sequential-language.md)) is unaffected.
3. **Abrupt by default.** The runtime runs no cleanup and delivers nothing further: output the run has already written
   has been delivered (D0048), and what an explicit writer holds is lost.
4. **The platform's report is kept.** The run ends as the platform's default action ends it, so that its parent sees
   the cause (on POSIX, death by that signal, which a shell shows as 128 + n). No QubeC report line is written, and
   the outcome has no QubeC exit status ([D0058](D0058-exit-statuses.md)).
5. A program may ask to receive interrupts and termination requests and handle them itself, through an API of M14 and
   M10; a run that handles one is not terminated by it.

## Rationale

The environment can always stop a process, so the outcomes should say what that means rather than stay silent. The
abrupt default is what every Tier 1 and Tier 2 platform does, costs the runtimes nothing, and is honest about a
signal's asynchrony. Because hidden buffering is already ruled out, it loses only what a program chose to hold, and
an orderly shutdown becomes a visible decision of the program.

## Consequences

- **D0048** has five outcomes; [spec §1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism)
  lists them. **Formal:** property 7 in [metatheory.md](../../spec/formal/metatheory.md) covers termination as well as
  exhaustion: both truncate the trace.
- **M07:** cleanup does not run on termination; resources the operating system reclaims are unaffected.
- **M10, M14:** the API to receive interrupts and termination requests (for example as events on a channel).
- **Conformance suite:** a test may send a signal at a stated point and expect the prefix and the termination.
- **Windows (Tier 3):** its console events map to the same outcome when that platform is promoted.

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (the outcomes),
  [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) (new)
- Grammar rules: none
- Formal rules: [dynamic.md](../../spec/formal/dynamic.md) (observable behavior); property 7 in
  [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: [vision.md](../vision.md)
