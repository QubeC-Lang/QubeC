# D0043: Native code comes after Spec v1.0, and no feature may need a VM at run time

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

With the tree-walking interpreter and the bytecode VM fixed ([D0042](D0042-tree-walker-and-bytecode-vm.md)), when does
a **native back end** arrive, if ever? A back end is the half of a compiler that turns the checked program into
something runnable; a native one produces machine code, most likely by emitting C and compiling it with `zig cc`
against the Zig runtime through its C ABI ([D0033](D0033-zig-host-vm.md)). The timing interacts with the stage plan
([D0039](D0039-four-implementation-stages.md)), with Spec v1.0 coming after I4 ([D0041](D0041-spec-v1-after-i4.md)),
and with the host leading every feature ([D0029](D0029-permanent-host-implementation.md)).

## Options considered

The scenario for every option: a word-count CLI built from `wc.qbc`, and what its users have at each stage.

```
                  I1           I2             I3 (fixpoint)     I4        v1.0      later
A. in I2          interp       VM + native    qubecc: VM+native  …         …         …
B. before v1.0    interp       VM             VM                 + native  …         …
C. after v1.0     interp       VM             VM                 VM        VM        + native
D. never          interp       VM             VM                 VM        VM        VM
```

Options A to C come with a **native-compatible rule**: no feature may need a VM at run time. Without it, a feature
designed in a later milestone could make native code a breaking change.

### A. In I2, alongside bytecode

- **Easy:** fast programs early; native code's hard cases are met while the design is young.
- **Hard:** I2 is already the largest stage; under D0029, `qubecc` needs the same back end before I3, which delays
  the fixpoint. Revisits D0039.
- **For implementers:** trampolines or `musttail` for `tailcall`, switched stacks, and GC stack maps land in the same
  stage as the GC itself.
- **Prior art (recalled):** OCaml shipped bytecode and native compilers together early, with a larger team.

### B. After the first fixpoint, before Spec v1.0

- **Easy:** Spec v1.0 ships with fast executables; the fixpoint is not delayed.
- **Hard:** native code competes with M10–M12 in I4, and v1.0 moves later. Revisits D0039.

### C. After Spec v1.0, with the native-compatible rule now

- **Easy:** the path to the fixpoint and to v1.0 stays as planned; native code later is a pure speed-up.
- **Hard:** until then every compiled program is VM-bound, including explicit-layer code, whose ranking puts
  Performance second ([D0004](D0004-ranked-design-values.md)).
- **Locks in / rules out:** the native-compatible rule; VM-only conveniences such as reloading bytecode at run time.
- **Prior art:** Java had no mainstream ahead-of-time compilation for about two decades (recalled); Kotlin/Native
  followed Kotlin/JVM by years (recalled); Erlang's HiPE native compiler was dropped in OTP 24 in favor of a
  load-time JIT (verified, [R0007](../research/R0007-execution-model-prior-art-and-checks.md)).

### D. Never

- **Easy:** the least code; no C toolchain anywhere.
- **Hard:** QubeC stays a VM language, a poor fit for its systems-programming ability, the explicit layer, and
  M12's interop and embedding.
- **Prior art (recalled):** Lua and CPython, whose performance remains a long-running concern.

| | A in I2 | B before v1.0 | C after v1.0 | D never |
| --- | --- | --- | --- | --- |
| Fast executables at v1.0 | yes | yes | no | no |
| Delays | the fixpoint | v1.0 | neither | neither |
| Native-compatible rule | yes | yes | yes | not needed |
| Revisits D0039 | yes | yes | no | no |

Recommendation at the time: **C**, because it keeps the stage plan intact, Performance ranks last in the default
layer, and the native-compatible rule keeps native code fully open at little cost.

## Choice

**C.**
1. Native code comes after Spec v1.0. Spec v1.0 ships with executables that run on the bytecode VM. Native code is
   planned in M17's post-v1.0 plan.
2. **The native-compatible rule** binds every milestone from now on: no language or library feature may need a VM at
   run time. In particular:
   - no evaluation of source text at run time;
   - no reading, inspecting, or generating bytecode at run time;
   - nothing whose meaning depends on the engine that runs the program.

   Compile-time evaluation (T0012, M11) is not affected: it runs inside the compiler.
3. The preferred route, C emitted and compiled with `zig cc` and linked against the Zig runtime, is recorded but not
   decided ([OQ-010](../open-questions.md#oq-010-how-is-native-code-generated)).

## Rationale

Before v1.0, the one firm need for a compiled engine is running `qubecc` for the fixpoint, and the VM meets it.
Putting native code earlier would enlarge a stage that is already the largest, or move v1.0, for speed that the
default layer ranks last. The native-compatible rule is what makes waiting safe: native code later changes how fast
programs run, never what they mean.

## Consequences

- **M06–M14:** a proposal that needs a VM at run time conflicts with this record.
- **T0011:** the runtime keeps its C ABI, and stack growth, stack-exhaustion detection, and panic locations are
  designed so that native code can provide them too.
- **M12:** foreign calls go through the runtime's C ABI, the same one native code would use.
- **M17:** the post-v1.0 plan includes native code and settles OQ-010.
- **Before v1.0,** performance is bounded by the VM, explicit layer included.

## Affected artifacts

- Spec: none (an implementation strategy; the rule constrains later decisions, not programs)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
