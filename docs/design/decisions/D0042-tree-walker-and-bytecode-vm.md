# D0042: QubeC runs on a tree-walking interpreter and a bytecode VM; no JIT is planned

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

Which **engines** run a checked QubeC program? An engine is the thing that executes a program:
- a **tree-walking interpreter** evaluates the program's tree (here, the typed core of
  [D0022](D0022-typed-elaboration-into-core.md)) node by node;
- a **bytecode VM** first compiles the program into instructions for an imaginary machine, then runs a loop that
  reads and executes them;
- **native code** is machine code for the real CPU;
- a **JIT** (just-in-time compiler) compiles the hot parts of a running program to machine code.

The tree-walking interpreter is already fixed in the host interpreter, which also serves the REPL
([D0013](D0013-easy-start.md), [D0030](D0030-three-part-host.md)). The question is which compiled path comes with
it. [D0030](D0030-three-part-host.md) presumes a bytecode VM and asks M01 to revisit it otherwise.

## Options considered

The scenario for every option (provisional syntax):

```
func sum_to(n: Int, acc: Int) -> Int =
  if n == 0 { acc } else { tailcall sum_to(n - 1, acc + n) };

proc main() {
  println(sum_to(1_000_000, 0));
}
```

### A. Tree-walker and bytecode VM

The host interpreter checks the program and emits the typed core; the host compiler lowers it to bytecode; the host
VM runs it. A `tailcall` becomes an instruction that reuses the current frame.

```
sum_to:  LOAD 0; PUSH 0; EQ; JMP_IF_FALSE L1; LOAD 1; RET
L1:      LOAD 0; PUSH 1; SUB_CHECKED; LOAD 1; LOAD 0; ADD_CHECKED
         TAILCALL sum_to/2          ; reuses the frame: constant stack (D0012)
```

- **Easy:** fits D0030 and the stage plan ([D0039](D0039-four-implementation-stages.md)) as they are; programs run
  wherever the VM builds.
- **Hard:** speed is bounded by the dispatch loop, typically several times slower than native code.
- **For implementers:** bytecode is the simplest compiled form of a typed core. The VM owns its frames, so growable
  stacks and constant-stack tail calls ([D0012](D0012-tail-calls-and-stacks.md),
  [D0014](D0014-tailcall-keyword.md)) are straightforward, and a line table gives exact panic locations.
- **Locks in / rules out:** nothing that blocks native code later, provided no feature needs a VM at run time.
- **Prior art (recalled):** OCaml's `ocamlc` with `ocamlrun`; Lua, CPython, and Erlang's BEAM, which stayed
  bytecode-based for decades; `clox` in *Crafting Interpreters*.

### B. Tree-walker and native code through C, with no VM

The host compiler emits C, which `zig cc` compiles and links against the Zig runtime.

```c
qb_int sum_to(qb_int n, qb_int acc) {
  for (;;) {                                 /* self tailcall → loop */
    if (n == 0) return acc;
    qb_int n2, acc2;
    if (__builtin_sub_overflow(n, 1, &n2)) qb_panic(LOC(2, 40));
    if (__builtin_add_overflow(acc, n, &acc2)) qb_panic(LOC(2, 47));
    n = n2; acc = acc2;
  }
}
```

- **Easy:** speed; real executables.
- **Hard:** a C toolchain is needed for every build (it can be bundled).
- **For implementers:** tail calls through function values and between functions are not expressible in portable C
  (they need trampolines or Clang's `musttail`); growable stacks need stack switching; precise GC roots need shadow
  stacks or stack maps. D0030's host VM would become a runtime library, a revisit of D0030.
- **Locks in / rules out:** every C undefined behavior must be ruled out by the emitter.
- **Prior art (recalled):** Nim, Chicken Scheme, and Gambit emit C; GHC dropped its C back end over tail calls and
  GC roots.

### C. Tree-walker and a bytecode VM with a JIT

As A, but the VM compiles hot code to machine code while the program runs.

- **Easy:** near-native speed on long runs.
- **Hard:** performance becomes harder to predict (Predictability ranks above Performance,
  [D0004](D0004-ranked-design-values.md)).
- **For implementers:** the most complex engine there is: code generation per CPU, deoptimization (falling back to
  the VM when an assumption fails), and memory that is writable or executable but never both. Under
  [D0029](D0029-permanent-host-implementation.md) it would be maintained forever.
- **Prior art (recalled):** HotSpot, V8, LuaJIT, PyPy: all large efforts; CPython added an experimental JIT only
  recently.

Not offered: a tree-walker alone, because it would undo D0030's compiler and VM and D0039's I2, and leave `qubecc`
without a back end to target.

| | A Tree-walker + VM | B Tree-walker + native C | C VM + JIT |
| --- | --- | --- | --- |
| Fits D0030 and D0039 as they are | yes | revisits D0030 | yes, with a much larger VM |
| Tail calls and growable stacks | easy | hard | easy in the VM, hard in the JIT |
| Speed | slowest | fastest | fast on long runs |
| Permanent implementation cost | low | medium | very high |

Recommendation at the time: **A**, because D0030 and D0039 already assume it, it makes D0012's guarantees easy, and
Performance ranks last in the default layer.

## Choice

**A.**
1. QubeC programs are executed by two kinds of engine: the host interpreter's **tree-walking interpreter** of the
   typed core, and a **bytecode VM** that runs bytecode compiled from the typed core.
2. No JIT is planned.
3. D0030 is confirmed: its revisit trigger does not fire. Native code is decided separately
   ([D0043](D0043-native-code-after-v1.md)).

## Rationale

A bytecode VM is the simplest compiled path from a typed core, and it is the one our host structure was built
around. Because the VM owns its frames, the stack guarantees of D0012 cost little, and panics can name exact
locations. A JIT would be the largest permanent component in the project, for speed that the default layer ranks
last.

## Consequences

- **I1** implements the tree-walking interpreter; **I2** the host compiler and VM, as D0039 planned.
- **T0011** designs the runtime for the VM, keeping the C ABI so that native code can use it later (D0043).
- **I3:** before native code exists, `qubecc`'s only back end can target the host VM's bytecode, so both compilers
  emit one format within a release.

## Affected artifacts

- Spec: [§1.2.4](../../spec/01-introduction.md#124-means-of-execution) (an implementation may execute a program by any
  means)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
