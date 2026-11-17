# D0048: Observable behavior is the trace of interactions with the environment, followed by one outcome

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0045](D0045-run-is-a-shortcut.md) requires that running a program has the same observable behavior as building it
and executing the result, and lets each implementation choose its engine
([D0042](D0042-tree-walker-and-bytecode-vm.md)).
[D0023](D0023-claimed-meta-properties.md) claims that every sequential program has at most one outcome. Both need an
exact definition of what about a run is observable. `dbg` output is already not observable
([D0008](D0008-purity.md)).

## Options considered

The scenario for every option (provisional syntax: `print`, `eprint`, `read_line`, and `write_file` stand in for
library procedures of M14):

```
proc main() {
  print("name? ");                 // stdout, no newline
  let n = read_line();             // stdin
  eprint("debug: got input");      // stderr
  write_file("out.txt", n);        // a file
  print("hello " + n);
  let x = dbg(1 + 1);              // dbg: never observable (D0008)
}
```

### A. An interaction trace, then an outcome

A run's behavior is an ordered sequence of **events**, its **trace**, followed by one **outcome**. An event is one
interaction with the environment: what the program sent (bytes to a stream, a file write, a request for input) and
what came back (the bytes read, a success or failure). The outcome is a return with an exit status, a panic, or
divergence (a run that never ends, with an infinite trace). Two runs have the same observable behavior when, given
the same responses from the environment, they produce the same events in the same order and the same outcome. Inputs
(standard input, files, arguments, the clock, randomness) are simply the responses half of the events.

```
trace for the input "Ann":
  1 out  "name? "
  2 in   → "Ann"
  3 err  "debug: got input"
  4 file out.txt ← "Ann"
  5 out  "hello Ann"
  outcome: return, status 0           (the dbg output is not part of it)
```

- **Easy:** interactive programs are defined (the prompt really precedes the read); merged logs of standard output
  and standard error agree between engines.
- **Hard:** the order between streams is observable, so a runtime may buffer output only where no one can tell.
- **For implementers:** differential testing compares two traces; the reference evaluator
  ([D0027](D0027-executable-reference.md)) produces a trace directly; D0023's determinism theorem is stated over
  traces.
- **Locks in / rules out:** every library native (M14) is described as an event; M10 must say how the events of
  concurrent tasks interleave.
- **Prior art:** CompCert defines a program's behavior as termination with a finite trace of I/O events and an exit
  code, divergence (with a finite or an infinite trace), or going wrong, and proves that compilation preserves it
  (verified, [R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)).

### B. The final output of each destination, then an outcome

Each destination is compared separately: all bytes written to standard output, all bytes written to standard error,
the final contents of each file, and the exit status or panic. Order across destinations and timing are not
observable.

```
stdout  : "name? hello Ann"
stderr  : "debug: got input"
out.txt : "Ann"
outcome : return, status 0
allowed : "name? " held back until exit, shown after the user typed
```

- **Easy:** runtimes buffer freely; comparison is simple.
- **Hard:** interactive programs are unspecified; merged logs may differ between engines.

### C. C's hybrid

File contents count only at termination; for interactive devices, prompts must appear before input is awaited;
everything else is as-if.

- **Easy:** the most runtime freedom that is still usable interactively.
- **Hard:** whether a device is interactive is a property of the platform, so the definition depends on the platform;
  it is awkward to state formally.
- **Prior art:** C11 §5.1.2.3p6 lists volatile accesses, the data written into files at program termination, and the
  input and output dynamics of interactive devices as "the observable behavior of the program" (verified, R0008).

| | A Trace | B Final per destination | C C's hybrid |
| --- | --- | --- | --- |
| Interactive prompts defined | yes | no | yes |
| Order across streams | observable | not | partly |
| Runtime buffering | only where unobservable | free | free, except interactive |
| Fit with D0023's determinism | direct | needs a projection | awkward |

Recommendation at the time: **A**, the only option that makes D0045's equivalence exact for interactive programs, and
the form in which D0023's determinism and D0027's reference evaluator are naturally stated.

## Choice

**A.**
1. The **observable behavior** of a run is its **trace**, the ordered sequence of its interactions with the
   environment (each one an **event** recording what the program sent and what it received), followed by its
   **outcome**: a return with an exit status, a panic ([D0049](D0049-precise-panics.md),
   [D0050](D0050-panic-contents.md)), resource exhaustion ([D0053](D0053-resource-exhaustion.md)), or divergence.
2. The program's **inputs** are the environment's responses within the trace. Two runs have the same observable
   behavior when, given the same responses, they have the same trace and the same outcome.
3. Nothing else is observable: not `dbg` output, timing, memory use, backtraces, or the way the run was executed.
4. The order of all events is observable, including the order between different streams. A runtime may hold back
   output only while doing so cannot be observed.

## Rationale

Every safeguard we rely on compares runs: the two permanent implementations
([D0029](D0029-permanent-host-implementation.md)), the whole suite on every back end and platform
([D0047](D0047-platform-parity.md)), the executable reference (D0027), and D0045's equivalence of running and
building. A trace makes each comparison exact, including for interactive programs, and it is the object D0023's
determinism theorem talks about. The cost, buffering only where it cannot be observed, is small, and a program that
writes heavily can use an explicit buffered writer if M14 provides one.

## Consequences

- **T0011:** output delivery at exit and on panic follows from choice 4: every exit path delivers all output before
  the outcome. T0011 states the runtime's obligations and the exit status.
- **M03:** the core's abstract machine emits events; determinism is stated over traces.
- **M10:** must state how the events of concurrent tasks interleave, and what may vary.
- **M14:** every native that interacts with the environment is specified as an event; M14 may offer an explicit
  buffered writer, whose batching is then visible in the source.
- **Conformance suite:** a test gives the inputs (arguments, standard input, files) and the expected trace and
  outcome, and may merge standard output and standard error.

> **Later note (T0011).** A fifth outcome, *terminated by the environment*, joins the four of choice 1
> ([D0060](D0060-termination-by-the-environment.md)). The exit statuses, the report line, and output delivery at
> exit are [D0058](D0058-exit-statuses.md), [D0059](D0059-report-line-and-backtrace.md), and
> [D0061](D0061-failed-standard-output.md).

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (new); the note in §1.2.4
- Grammar rules: none
- Formal rules: [dynamic.md](../../spec/formal/dynamic.md) (outcomes and traces); property 5 in
  [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: none
