# D0050: A panic's kind, message, and source location are observable; a backtrace is not

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0049](D0049-precise-panics.md) fixes where in the trace a panic happens. What does the panic outcome carry, and so
what must every engine agree on? T0011 decides the form of the panic report (its text, its stream, and the exit
status); this record decides which information the outcome contains.

## Options considered

The scenario for every option (provisional syntax):

```
func nth(xs: List[Int], i: Int) -> Int = xs[i];        // line 1, `xs[i]` at column 42

proc main() {
  print("before");
  let n = nth([1, 2, 3], 7);                           // index out of bounds
  print("after");                                      // never reached
}
```

### A. Kind, message, and location are observable; a backtrace is not

The outcome is a panic with its **kind** (such as index out of bounds, overflow, division by zero, or an explicit
panic), its **message**, and the **source location** of the failing operation. Every engine must agree on all three.
A backtrace may be printed, but it is not observable, like `dbg` output, and its frames may be merged or missing
after optimization.

```
trace:   out "before"
outcome: panic(index-out-of-bounds, "index 7, length 3", main.qbc:1:42)
```

- **Easy:** tests pin a panic exactly; users see the same error from every engine.
- **Hard:** the wording of messages becomes part of the specification.
- **For implementers:** bytecode maps every check to its source position, which debug information needs anyway.
- **Prior art (recalled):** Go and Rust print the message and the location; the text is stable in practice but not
  specified.

### B. Kind and message are observable; the location is not

Engines agree on what failed, but may report where with different precision, or not at all.

```
outcome: panic(index-out-of-bounds, "index 7, length 3")
engine 1 says main.qbc:1; engine 2 says main.qbc:1:42          (both conform)
```

- **Easy:** optimizing back ends need not keep precise positions.
- **Hard:** a misreported location goes unnoticed, although D0049 already fixes the failing operation.

### C. Only the fact of a panic is observable

The outcome is just "panicked"; kind, message, and location are free per engine.

- **Easy:** the least to specify.
- **Hard:** tests cannot tell an overflow from an index error; D0045's equivalence is weak exactly where users look.

| | A Kind, message, location | B Kind, message | C Fact only |
| --- | --- | --- | --- |
| Test precision | exact | no site | panicked or not |
| Engine burden | a position for every check | messages | none |
| Specified text | messages | messages | none |

Recommendation at the time: **A**. D0049 already fixes the failing operation, so its location costs only position
tracking, and it makes panics fully testable.

## Choice

**A.**
1. A panic outcome consists of the panic's **kind**, its **message**, and the **source location** of the failing
   operation. All three are observable.
2. A **backtrace**, if an implementation prints one, is not observable. It may be incomplete.
3. The form of a source location is decided with how source files are named (T0013) and how columns are counted
   (M02). The kinds and their messages are decided with the constructs that fail (M05, M08, M14).

## Rationale

A panic is the outcome users read most closely, so it should be the same on every engine, and the conformance suite
should be able to check it exactly. Because panics are precise, the location is determined by the program, so
reporting it identically costs only keeping positions, which debugging needs anyway.

## Consequences

- **T0011:** the panic report presents the kind, message, and location; its form, its stream, and the exit status are
  T0011's.
- **T0013 and M02:** define the form of a source location.
- **M05, M08, M14:** each kind of panic and its message are specified with the operation that can fail.
- **I1 and I2:** the elaborated core and the bytecode carry a source position for every operation that can fail.
- Resource exhaustion carries no location ([D0053](D0053-resource-exhaustion.md)).

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (new)
- Grammar rules: none
- Formal rules: [dynamic.md](../../spec/formal/dynamic.md) (outcomes)
- Examples / tour: none
