# D0030: The host implementation has three parts in three languages, connected through the typed core

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

How many languages does the permanent host implementation ([D0029](D0029-permanent-host-implementation.md)) use, and
when are they fixed? A language implementation has a **front end** (lexing, parsing, name resolution, type and purity
checking, elaboration into the typed core of [D0022](D0022-typed-elaboration-into-core.md), with rule-ID diagnostics,
[D0018](D0018-diagnosis-and-rule-ids.md)), an **evaluator** with the REPL ([D0013](D0013-easy-start.md)), possibly a
**back end** (a bytecode compiler, a virtual machine, native code generation), and a **runtime** (garbage collector or
reference counting, the growable stacks of [D0012](D0012-tail-calls-and-stacks.md), later a task scheduler, and native
library functions). The front end is symbolic code; a runtime is low-level code with raw memory and stack switching.
M01 has not yet decided the execution model.

## Options considered

The scenario: add `match` guards (a front-end and lowering change) and make stacks growable (a runtime change).
Directory names are illustrative.

### A. One language for everything, fixed now

```
host/            (one language, one build, one toolchain)
  front/   check  elab            ← match guards
  eval/    interp repl            ← match guards
  runtime/ gc     stacks          ← growable stacks
```

- **Easy:** one build and toolchain; one definition of the typed core; each feature touches one host codebase.
- **Hard:** the language must suit both symbolic code and a GC with stack switching. A language with its own GC
  makes writing QubeC's GC inside it awkward.
- **Prior art (recalled):** Go's compiler and runtime are written in Go with a little assembly (since Go 1.5).

### B. The front end and evaluator now; the runtime language with M01

```
host/
  front/   check  elab            ← chosen now
  eval/    interp repl            ← chosen now (tree-walking: the first runnable QubeC)
  runtime/ ???                    ← M01/M07: same language unless a need is shown
```

- **Easy:** fixes only what can be judged before M01; the first implementation work needs only the front end.
- **Hard:** a second language may still arrive, with an interface to design then.
- **Prior art (recalled):** OCaml (compiler in OCaml, runtime in C), GHC (Haskell plus a C runtime), Erlang (BEAM in
  C).

### C. Two languages, fixed now

```
host/
  front+eval/  (a high-level language)   ← match guards
  runtime/     (a systems language)      ← growable stacks
  interface:   C ABI or a bytecode format
```

- **Easy:** each part in a suitable language.
- **Hard:** two toolchains forever; commits to a separate runtime before M01.

### D. Three languages: front end and interpreter; core compiler; VM and runtime

```
host/
  interp/    front end, tree-walking interpreter, REPL   ← match guards
  compiler/  typed core → bytecode                        ← match guards (lowering)
  vm/        VM, GC, natives (C ABI)                      ← growable stacks
```

- **How it works:** the front end elaborates into the typed core and emits it; a separate compiler reads that core
  and lowers it to bytecode; a VM and runtime library runs the bytecode. No front end is written twice.
- **Easy:** the best-suited language for each kind of work; the runtime, as a C-ABI library, can later serve native
  code too.
- **Hard:** three toolchains and idioms forever, and two interface formats (core and bytecode); presumes a bytecode
  VM.

| | A One, now | B Front now, runtime with M01 | C Two, now | D Three |
| --- | --- | --- | --- | --- |
| Host codebases maintained forever | 1 | 1–2 | 2 | 3 |
| Assumes an execution model | implicitly | no | partly | yes (bytecode VM) |
| Fit of each part's language | compromise | good | good | best per part |
| Interfaces to design early | none | none now | one | two |

Recommendation at the time: **B**, because every extra language is a permanent cost under D0029 and because the
execution model is M01's.

## Choice

**D.**
1. The host implementation has three parts:
   - the **host interpreter**: the front end, a tree-walking interpreter of the typed core, the REPL, and the driver
     (`qubec run` of [D0013](D0013-easy-start.md)). It makes every rejection, and can emit the core of a
     program;
   - the **host compiler**: reads the typed core emitted by the host interpreter and lowers it to bytecode. It has no
     front end of its own and makes no rejections;
   - the **host VM**: the bytecode loader and interpreter loop, the heap and garbage collector, the stacks, panics,
     and the native library functions, built as a library with a C ABI.
2. The parts connect as a pipeline: surface source into the host interpreter; the typed core, in the interchange
   format of [OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core),
   from the host interpreter to the host compiler and to the Lean reference; bytecode, in a format still open
   ([OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)), from
   the host compiler to the host VM.
3. Their languages are Rust, OCaml, and Zig ([D0031](D0031-rust-host-interpreter.md),
   [D0032](D0032-ocaml-host-compiler.md), [D0033](D0033-zig-host-vm.md)).
4. **Revisit trigger:** this structure presumes that M01 includes a bytecode VM. If M01 decides otherwise, M01
   revisits this decision.

## Rationale

We chose a language per kind of work: a front end and interpreter where diagnostics and the REPL live, a compiler
over a typed IR, and a runtime that manages raw memory. Connecting them through the typed core means no front end is
written twice, and the interchange format that [D0027](D0027-executable-reference.md) already requires is exercised
from the start. The same core semantics then runs three ways (the host interpreter, the host compiler with the host
VM, and the Lean reference), which is what differential testing compares. We accept three permanent toolchains and
two interface formats.

## Consequences

- **M01:** decides the execution model knowing that the host has a bytecode compiler and VM; native code, if any,
  can link the host VM's runtime through its C ABI. A decision without a VM triggers a revisit of this record.
- **OQ-008** is needed before the host compiler is built, earlier than M16 alone would require.
- **OQ-009** (the bytecode format) is opened, for M01 or M16.
- **M16:** plans the three parts, their build, and the repository layout of the implementation.
- **T0007:** weighs the load of three host codebases, `qubecc`, and the mechanization when confirming the plan.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [vision.md](../vision.md)
