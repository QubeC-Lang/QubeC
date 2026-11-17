# D0055: One runtime contract, two independent host runtimes, and a runtime in QubeC for native code

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

A **runtime** is the code that runs alongside a program and does what the program cannot do by itself: it manages
memory and call stacks, supplies the natives that cross into the operating system, produces the outcome (the report,
pending output, the exit status), and later schedules tasks (M10) and makes foreign calls (M12). The specification does
not define a runtime ([§1.2.4](../../spec/01-introduction.md#124-means-of-execution)), so this is a decision about
implementations. The host runs programs with two engines, the Rust tree-walker and the Zig VM
([D0042](D0042-tree-walker-and-bytecode-vm.md)), and both need a runtime. How do they relate, and what happens when
native code arrives after v1.0 ([D0043](D0043-native-code-after-v1.md))?

Every option shares one written **runtime contract**, listing the responsibilities above.

## Options considered

The scenario for every option (provisional syntax):

```
proc main() {
  let text = read_file("notes.txt");   // a native: crosses into the OS
  print(text.len());                   // a native: an event on standard output
  let xs = [1, 2];
  xs[5];                               // a panic: the report, then the exit status
}
```

### A. One shared runtime: the Zig runtime serves both engines

The VM calls the Zig runtime directly; the Rust tree-walker links it through Rust's C FFI, converting its values to
C-ABI values at each native call. Memory and stacks stay with each engine.

```
run    → Rust tree-walker ──C ABI──▶ Zig runtime: read_file, print, report, exit
build  → Zig VM ────────────────────▶ Zig runtime (the same code)
```

- **Easy:** each native is written once; the C ABI is exercised from I1, which helps native code and M12.
- **Hard:** I1 cannot be built without the Zig runtime, although it was planned in Rust alone
  ([D0039](D0039-four-implementation-stages.md)); value conversion at every native call.
- **Locks in / rules out:** differential testing between the two engines can no longer find a bug in a native; only
  the Lean reference's model could.
- **Prior art (recalled):** CPython's C runtime; GraalVM's Truffle interpreters share one runtime.

### B. Two independent runtimes under one contract

The Rust interpreter implements the contract in Rust and the Zig VM in Zig, each idiomatically
([D0034](D0034-idiomatic-code-per-part.md)). The conformance suite and differential tests check that they agree.

```
run    → Rust tree-walker → Rust runtime: read_file, print, report, exit
build  → Zig VM          → Zig runtime: read_file, print, report, exit
          both follow the runtime contract; the suite compares their traces
```

- **Easy:** I1 stays in Rust; a bug in either runtime's natives shows up as a difference between traces.
- **Hard:** every native is written twice and must be tested to agree, a cost that depends on how many natives there
  are ([D0056](D0056-thin-natives.md)).
- **Prior art (recalled):** Lua and LuaJIT; HotSpot and OpenJ9 under one specification and test suite.

### C. B now, and a runtime written in QubeC for native code after v1.0

As B until v1.0. When native code arrives, `qubecc`'s native output links a third runtime written in QubeC itself,
using the explicit layer and an unsafe escape hatch, so that the self-hosted implementation is self-hosted all the way
down.

```
before v1.0:  as B (a Rust runtime and a Zig runtime)
after v1.0:   qubecc native output → runtime written in QubeC
                (explicit layer and unsafe, M07; layout control, M12)
```

- **Easy:** in the end, `qubecc` and its runtime form a second fully independent implementation.
- **Hard:** it commits now to something that depends on M07, M12, and native code
  ([OQ-010](../open-questions.md#oq-010-how-is-native-code-generated)), none of which is designed yet.
- **Prior art (recalled):** Go's runtime is written in Go; Rust's standard library in Rust.

| | A Shared Zig | B Two, one contract | C B, then a QubeC runtime |
| --- | --- | --- | --- |
| Natives written | once | twice | twice, later three times |
| Differential tests find native bugs | no | yes | yes |
| I1 needs Zig | yes | no | no |
| Commits ahead of M07 and M12 | no | no | yes |

Recommendation at the time: **B**, leaving the runtime for native code to M17, which plans native code anyway.

## Choice

**C.**
1. **The runtime contract.** Every QubeC runtime meets one written contract. Its responsibilities are:
   - memory: allocation, and reclamation as M07 decides;
   - call stacks: growth, the stack cap and the guaranteed depth ([D0062](D0062-guaranteed-depth-and-stack-cap.md)),
     and constant-space `tailcall` ([D0014](D0014-tailcall-keyword.md));
   - the natives ([D0056](D0056-thin-natives.md));
   - the outcome: the exit status ([D0058](D0058-exit-statuses.md)), the report
     ([D0059](D0059-report-line-and-backtrace.md)), termination by the environment
     ([D0060](D0060-termination-by-the-environment.md), [D0061](D0061-failed-standard-output.md)), and delivery of
     all pending output before it ([D0048](D0048-trace-and-outcome.md));
   - **reserves:** enough memory and stack, set aside in advance, to write the exhaustion report and to deliver
     pending output after a resource is exhausted ([D0053](D0053-resource-exhaustion.md));
   - later, the task scheduler (M10) and foreign calls (M12).
2. **Two independent host runtimes.** The host interpreter has its own runtime, in Rust; the host VM has its own, in
   Zig, with a C ABI ([D0030](D0030-three-part-host.md)). Neither links the other.
3. **A runtime in QubeC for native code.** When native code arrives after Spec v1.0, `qubecc`'s native output links a
   runtime written in QubeC. Its plan belongs to M17's post-v1.0 plan, with OQ-010. Until then, `qubecc`'s output runs
   on the Zig VM and its runtime ([D0042](D0042-tree-walker-and-bytecode-vm.md)).

## Rationale

Comparing independent engines is our main safeguard ([D0029](D0029-permanent-host-implementation.md),
[D0047](D0047-platform-parity.md)), and it stays sharp only if the engines do not share the code that touches the
operating system. A written contract makes "the runtime" one thing that three codebases can be checked against. We
want the self-hosted implementation to be self-hosted down to its runtime, as Go's is, so that after native code the
project has two complete, independent implementations whose runtimes check each other. Committing to that now gives
M07 and M12 a concrete obligation, rather than discovering in M17 that the language cannot express its own runtime.

## Consequences

- **M07** must give the explicit layer and the unsafe escape hatch enough power to write a garbage collector or
  reference counting, and stack management, in QubeC.
- **M10:** the scheduler is a contract responsibility, met by each runtime; the runtime in QubeC includes it.
- **M12:** layout control and the C ABI must be enough for a runtime in QubeC to call the operating system.
- **M17:** the post-v1.0 plan includes the runtime in QubeC, together with OQ-010.
- **I1:** the host interpreter's runtime is written in Rust, with the tree-walker. **I2:** the host VM's runtime in
  Zig. Both are checked by the same suite.
- The contract itself is maintained with the implementation (I1's opening task decides where), and cites these
  records.

## Affected artifacts

- Spec: none (runtimes are not language, [§1.2.4](../../spec/01-introduction.md#124-means-of-execution))
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
