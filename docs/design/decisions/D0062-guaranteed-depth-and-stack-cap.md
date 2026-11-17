# D0062: The guaranteed depth is 100,000 nested calls of bounded frames; runtimes have a raisable stack cap

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

Stacks are growable, limited by a large cap ([D0012](D0012-tail-calls-and-stacks.md)), and a run does not exhaust
its stack below a **guaranteed minimum depth** ([D0053](D0053-resource-exhaustion.md)). What is that depth
([OQ-012](../open-questions.md#oq-012-what-is-the-guaranteed-minimum-depth-of-nested-calls)), and what is the cap? The
value must be reachable on every Tier 1 and Tier 2 platform ([D0046](D0046-first-platforms-and-tiers.md)), including
`linux-riscv64` under an emulator, by both engines: the VM keeps frames in a heap array, but the Rust tree-walker
recurses in Rust, so each QubeC call costs several host frames. `tailcall`s do not count
([D0014](D0014-tailcall-keyword.md)). Because a frame's size depends on its function, a bare count can be defeated by
a function with very many locals.

## Options considered

A pilot ([R0009](../research/R0009-runtime-and-lifecycle-pilots.md)) measured a minimal Rust tree-walker over a typed
core on macOS arm64: 768 bytes of host stack per QubeC call in a release build (73 MiB at 100,000 deep, 732 MiB at
1,000,000), and 7,584 bytes in a debug build (723 MiB and 7.1 GiB). A full interpreter is likely to use two to four
times as much (an estimate); a VM frame is estimated at about 100 bytes. Go's maximum goroutine stack is 1 GB on 64-bit
platforms and Python's default recursion limit is 1000 (both verified).

The scenario for every option (provisional syntax):

```
type Expr = Num(Int) | Add(Expr, Expr);
func depth(e: Expr) -> Int = match e {           // not a tail call
  Num(_)    => 1,
  Add(a, b) => 1 + max(depth(a), depth(b)),
};
proc main() { print(depth(left_chain(n)).to_str()); }   // about n nested calls
```

### A. 100,000 nested calls, each frame holding at most 256 values

A frame holds a call's parameters and local bindings; a frame of k > 256 values counts as ⌈k/256⌉ calls.

- **Easy:** every engine reaches it comfortably (about 75–300 MB for a release tree-walker, about 10 MB for the VM),
  in CI and under emulation; a hundred times Python's default.
- **Hard:** non-tail recursion over data deeper than 100,000 is not guaranteed; library functions over long lists use
  loops or `tailcall`.
- **Locks in:** I1's simple recursive tree-walker stays viable.

### B. 1,000,000 nested calls, with the same frame bound

- **Easy:** recursion over very large data is guaranteed.
- **Hard:** a release tree-walker needs about 0.75–3 GB, a debug build is infeasible, and the interpreter would likely
  need an explicit continuation stack on the heap.

### C. 10,000 nested calls

- **Easy:** reachable even on small fixed stacks.
- **Hard:** D0012's promise that deep recursion is safe becomes weak; a compiler walking a moderately deep tree may
  exhaust on some implementation.
- **Prior art (recalled):** Java's default thread stacks give roughly 10,000–20,000 frames.

### D. An amount of abstract stack in bytes

For example 64 MiB of an abstract machine's stack, with a specified cost per frame.

- **Easy:** exact for every frame size.
- **Hard:** hard for users to reason about; fixes an abstract frame layout before M03 defines frames.
- **Prior art (recalled):** WebAssembly leaves stack limits to the implementation, with no portable unit.

Recommendation at the time: **A**, comfortably reachable by both engines on every supported platform while keeping
the tree-walker simple; implementations remain free to go much deeper.

## Choice

**A.**
1. **The guaranteed minimum depth** is 100,000 nested calls. A call whose frame holds more than 256 values counts as
   ⌈k/256⌉ calls, where k is the number of values it holds. Calls made by `tailcall` do not add to the depth. This
   settles OQ-012.
2. A frame's values are the call's parameters and local bindings; the exact count is restated when M03 defines
   frames.
3. **The stack cap.** Each runtime has a default **stack cap**, the point at which it reports `exhausted: stack`
   ([D0059](D0059-report-line-and-backtrace.md)) rather than grow further. It is at least what the guaranteed depth
   needs. The host implementation's default is 1 GiB of stack memory per run.
4. An input of the run may raise the cap (its name is M15's). Because the point of exhaustion above the guarantee is
   unspecified (D0053), this changes nothing observable below it.
5. The guarantee binds an implementation as released; development builds of an implementation are not bound by it.

## Rationale

The floor has to be one that every engine reaches on every supported platform without an architecture built around
it; the pilot shows a recursive tree-walker meets 100,000 calls with room to spare, and the VM meets it many times
over. A hundred thousand nested calls is far beyond what ordinary recursion over program trees needs, and the default
cap lets the VM go into the millions. Bounding frames keeps the guarantee from being defeated by a function with
thousands of locals, without exposing a frame layout.

## Consequences

- **[Spec §1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits)** rule 1 states
  the value; OQ-012 is decided.
- **M03:** defines frames, restates the 256-value bound in its terms, and may set the nesting limit of D0054 well
  below the depth, so that checking a program never needs more.
- **M10:** each task's stack follows the same cap and guarantee.
- **M14:** library functions over collections avoid non-tail recursion over their length.
- **I1, I2:** both engines are tested at the guaranteed depth on every Tier 1 and Tier 2 platform.
- **Conformance suite:** a test at the guaranteed depth must not exhaust; deeper tests accept exhaustion.

## Affected artifacts

- Spec: [§1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) rule 1
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
