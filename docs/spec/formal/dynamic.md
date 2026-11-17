# Dynamic Semantics

Status: skeleton. Notation follows [README.md](README.md). The dynamic semantics is defined over the core only
([D0022](../../design/decisions/D0022-typed-elaboration-into-core.md)), as an **abstract machine**: small-step rules
over states that carry an explicit stack, so that the tail-call space bound can be stated
([D0023](../../design/decisions/D0023-claimed-meta-properties.md)). Each rule names its governing Lean definition
([D0026](../../design/decisions/D0026-lean-governs-core-rules.md)). The shape of the machine's states is decided in
M03.

## Observable behavior

The machine's transitions emit **events**: interactions with the environment, each pairing what the program sends
with the response it receives ([D0048](../../design/decisions/D0048-trace-and-outcome.md)). A run of the machine
therefore denotes a **trace** (a finite or infinite sequence of events) and, when the trace is finite, an
**outcome**: a return with an exit status, a panic with its kind, message, and source location
([D0049](../../design/decisions/D0049-precise-panics.md), [D0050](../../design/decisions/D0050-panic-contents.md)),
or divergence after a finite trace. The machine has no resource limits and is never interrupted; resource exhaustion
and termination by the environment are stated about implementations, as truncations of the machine's trace
([D0053](../../design/decisions/D0053-resource-exhaustion.md),
[D0060](../../design/decisions/D0060-termination-by-the-environment.md), [metatheory.md](metatheory.md) property 7).
How a run ends (delivering pending output, the report line, the exit status) is stated in prose in
[spec §1.2.7](../01-introduction.md#127-program-start-and-termination)
([D0058](../../design/decisions/D0058-exit-statuses.md), [D0059](../../design/decisions/D0059-report-line-and-backtrace.md)). A panic's source location is a source name, a line,
and a column ([D0076](../../design/decisions/D0076-source-names.md), [D0077](../../design/decisions/D0077-location-text.md)), carried by the core term that can fail; the machine never
sees where files are stored. The forms of events and outcomes are fixed in M03, with the machine's
states. The informal statement is [spec §1.2.5](../01-introduction.md#125-observable-behavior-and-determinism).

## Compile-time evaluation

Constants are evaluated by the same machine, between checking and the run
([D0063](../../design/decisions/D0063-program-phases.md)). Constant evaluation will be a relation over a store that maps
each constant to *unevaluated*, *in progress*, or its value; reading a constant that is in progress is the premise of
`R-const-cycle` ([D0065](../../design/decisions/D0065-cycles-found-during-evaluation.md)), and a panic is the premise of
`R-const-panic` ([D0069](../../design/decisions/D0069-compile-time-panic-is-a-rejection.md)). The machine performs no
events while evaluating constants ([D0068](../../design/decisions/D0068-only-pure-code-at-compile-time.md)). Steps are
counted per constant, and the machine is unbounded; the guaranteed number of steps, like the guaranteed depth, is
stated about implementations ([D0070](../../design/decisions/D0070-compile-time-step-floor-and-cap.md)). The rules come
with the machine's states, from M03.

## Judgment forms

| Judgment | Reading |
| --- | --- |
| — | none yet |

## Metavariables

| Metavariable | Ranges over |
| --- | --- |
| — | none yet |

## Rules

None yet.
