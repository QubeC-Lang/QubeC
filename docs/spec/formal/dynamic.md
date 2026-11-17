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
or divergence after a finite trace. The machine has no resource limits; resource exhaustion is stated about
implementations, as a truncation of the machine's trace ([D0053](../../design/decisions/D0053-resource-exhaustion.md),
[metatheory.md](metatheory.md) property 7). The forms of events and outcomes are fixed in M03, with the machine's
states. The informal statement is [spec §1.2.5](../01-introduction.md#125-observable-behavior-and-determinism).

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
