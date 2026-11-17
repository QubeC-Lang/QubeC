# D0053: Resource exhaustion may happen at different points above a guaranteed floor, and truncates the trace

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0051](D0051-deterministic-sequential-language.md) leaves one exception: running out of a resource, the stack
(through deep recursion) or memory. [D0012](D0012-tail-calls-and-stacks.md) makes stacks growable, limited by a large
cap, and leaves the cap and a guaranteed minimum depth to M01. What may the specification promise about when
exhaustion happens? T0011 decides the failure's report and exit status, and the value of the minimum.

## Options considered

The scenario for every option (provisional syntax):

```
func depth(n: Int) -> Int = if n == 0 { 0 } else { 1 + depth(n - 1) };   // not a tail call

proc main() {
  print("start");
  print(depth(100_000).to_string());       // fine everywhere?
  print(depth(100_000_000).to_string());   // exhausts somewhere: where?
}
```

### A. The point may vary above a guaranteed floor; the failure is defined

Every implementation supports at least a guaranteed minimum depth of nested calls (the value is T0011's). Beyond it,
an implementation may run out at any point. The run's trace is then a **prefix** of the trace it would have had with
unlimited resources, followed by the outcome **exhausted**, which names the resource (stack or memory) but no
location, because the place varies.

```
depth(100_000):      works everywhere (within the floor)
depth(100_000_000):  implementation 1: exhausted (stack); implementation 2: prints 100000000
either way, the trace begins: out "start", out "100000"; no wrong value is ever printed
```

- **Easy:** a clean formal statement (exhaustion truncates the trace); a floor programmers can rely on.
- **Hard:** tests that probe exhaustion check only "exhausted, or finished correctly".
- **For implementers:** every runtime reserves enough stack and memory to report exhaustion.
- **Prior art:** WebAssembly lists resource exhaustion as nondeterministic; Python's highest recursion limit is
  "platform-dependent" (both verified, [R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)). The
  JVM's stack size is set by an option (recalled).

### B. The point may vary, with no guaranteed floor

As A, but the specification promises no depth; each implementation documents its own.

- **Easy:** the least to specify.
- **Hard:** a program may fail at modest depth on one implementation and not another; D0012's promise has no number.

### C. An exact, deterministic stack limit

Depth is counted in abstract frames (one per unmarked call in progress; `tailcall` adds none), and every
implementation fails at exactly the same count, so stack exhaustion becomes a deterministic panic with a location.
Memory exhaustion still varies.

- **Easy:** stack overflow is tested exactly, like any other panic.
- **Hard:** every engine and later native code counts frames on every call; every implementation must reach the cap;
  deep recursion can still exhaust memory first.
- **Prior art (recalled):** Ethereum's fixed call-depth limit and gas metering.

| | A Floor, then varies | B Varies | C Exact frames |
| --- | --- | --- | --- |
| Stack overflow tested exactly | no | no | yes |
| What programmers can rely on | a floor | nothing | an exact cap |
| Engine cost | a reserve for the report | a reserve | a counter per call and a reserve |
| Memory exhaustion | varies | varies | varies |

Recommendation at the time: **A**, an honest exception (the point varies, but nothing before it does) that gives
D0012's promise a number. C's exactness costs a counter on every call in every back end and still leaves memory
nondeterministic.

## Choice

**A.**
1. **Resource exhaustion** is a run's running out of stack or of memory. It is the only behavior of the sequential
   language that may differ between implementations, engines, profiles, and platforms.
2. Every conforming implementation supports at least a **guaranteed minimum depth** of nested calls; its value is
   decided in T0011. Below it, a run does not exhaust its stack.
3. When a run exhausts a resource, its trace is a prefix of the trace it would have had without limits, and its
   outcome is **exhausted**, naming the resource (stack or memory), with no source location.
4. Resource exhaustion is never undefined behavior and never yields a wrong result.
5. An implementation that exhausts a resource while checking or compiling a program reports it and does not run the
   program. That is not a rejection: the program may be conforming.

## Rationale

Exhaustion is the one difference that cannot be removed cheaply: stack frames differ in size between engines, and
memory depends on the machine. Bounding the difference to "a correct prefix, then a defined failure" keeps every
other comparison exact, and a guaranteed floor makes D0012's promise that deep recursion is safe concrete.

## Consequences

- **T0011:** the value of the guaranteed minimum depth and the default cap; the exhaustion report and exit status;
  the runtime's reserve for reporting and for delivering pending output.
- **M03:** the abstract machine's semantics is unbounded; exhaustion is stated as truncation of the trace.
- **M07:** memory exhaustion includes failing allocations.
- **Formal:** a new claimed property, exhaustion truncates the trace (property 7 in
  [metatheory.md](../../spec/formal/metatheory.md)), amending the list of [D0023](D0023-claimed-meta-properties.md).
- **Conformance suite:** a test that may exhaust a resource has the outcome "exhausted, or the expected outcome".

> **Later note (T0011).** The guaranteed minimum depth is 100,000 nested calls of frames holding at most 256 values,
> with a raisable stack cap ([D0062](D0062-guaranteed-depth-and-stack-cap.md)); exhaustion is reported as
> `exhausted: stack` or `exhausted: memory` ([D0059](D0059-report-line-and-backtrace.md)) and exits with status 102
> ([D0058](D0058-exit-statuses.md)); the reserve is part of the runtime contract
> ([D0055](D0055-runtime-contract-and-runtimes.md)).

## Affected artifacts

- Spec: [§1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) (new)
- Grammar rules: none
- Formal rules: property 7 in [metatheory.md](../../spec/formal/metatheory.md); outcomes in
  [dynamic.md](../../spec/formal/dynamic.md)
- Examples / tour: none
