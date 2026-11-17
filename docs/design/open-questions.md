# Open Questions

Each question has an ID (OQ-nnn), the task where it arose, what is blocked on it, and the options so far (see
[the template](templates/open-question.md)). Anything marked *Provisional* in the spec, grammar, formal rules, or
examples points to one of these. When a question is decided, it moves to **Decided** with a link to its D record.

## Open

### OQ-001: How does Go-style concurrency become data-race-free, and what does it require of the runtime?

- **Status:** Open
- **Arose in:** T0002 (M00), from [D0006](decisions/D0006-inspirations.md) (Go's concurrency as an inspiration) and
  [D0004](decisions/D0004-ranked-design-values.md) (Safety first)
- **To be settled in:** M10, with constraints on M01 (runtime) and M07 (memory)
- **Blocked on it:** the concurrency parts of the dream snippet in [vision.md](vision.md) (`spawn`, `channel`, `<-`)
- **Options so far:**
  1. Restrict what crosses a channel or is captured by `spawn` to values safe to share (as Rust's `Send` and `Sync`
     do).
  2. Share nothing mutable between tasks: tasks communicate only by moving or copying values (actor-like).
  3. A dynamic race detector only (as Go's), which does not meet Safety (#1) on its own.
- **Notes:**
  - Uncolored lightweight tasks need an M:N scheduler and growable stacks, which M01 must allow.
  - A receive from a closed channel cannot return a zero value (NG-8, [D0005](decisions/D0005-non-goals.md)). It
    must return an `Option`, block, or panic, or closing must be designed differently.
  - Directional channel types, if any, cannot convert implicitly (NG-9).
  - `<-` as one token makes `x<-1` a send; M02 must accept or avoid that.
  - Default collections are mutable ([D0010](decisions/D0010-mutable-default-collections.md)), so a mutable
    collection sent over a channel or captured by `spawn` must be moved (the sender loses access) or forbidden.
  - Lightweight tasks share the growable-stack machinery of [D0012](decisions/D0012-tail-calls-and-stacks.md).
  - The scheduler is a responsibility of the runtime contract, met by every runtime, including the runtime in QubeC
    ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); each task's stack follows the cap and guaranteed depth
    of [D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md).

### OQ-002: Is absence written `Option[T]`, `T?`, or both?

- **Status:** Open
- **Arose in:** T0002 (M00), from [D0006](decisions/D0006-inspirations.md) (ML/Rust and Kotlin are both
  inspirations)
- **To be settled in:** M05
- **Blocked on it:** nothing yet
- **Options so far:**
  1. `Option[T]` only, an ordinary sum type.
  2. `T?` only, built into the type system (as in Kotlin).
  3. Both: `T?` as sugar for `Option[T]`.
- **Notes:** NG-8 (no `null`) holds in every option.

### OQ-003: How is the explicit layer marked, and how do default integers relate to sized ones?

- **Status:** Open
- **Arose in:** T0002 (M00), from [D0003](decisions/D0003-target-users.md) and
  [D0004](decisions/D0004-ranked-design-values.md)
- **To be settled in:** M05 (numeric model, marking), M07 (safe borrowed references)
- **Blocked on it:** the explicit-layer sample in [vision.md](vision.md)
- **Options so far:**
  1. No marker: explicit-layer forms (sized integers, `&[T]`, casts) are simply used where needed.
  2. A visible marker at the function or block level.
  3. `Int` is an alias for one sized type, or a separate checked type with explicit conversions.
- **Notes:** the explicit layer must stay safe; unchecked operations are a separate escape hatch (M07).

### OQ-005: Which spellings replace the placeholder keywords `mut`, `become`, and `dbg`?

- **Status:** Open
- **Arose in:** T0003 (M00), from [D0007](decisions/D0007-intuitive-names.md) (intuitive names) applied to
  [D0008](decisions/D0008-purity.md) (`dbg`), [D0009](decisions/D0009-immutable-bindings.md) (`let mut`), and
  [D0012](decisions/D0012-tail-calls-and-stacks.md) (`become`)
- **To be settled in:** M02 (keywords), M14 (`dbg`, a built-in rather than a keyword); the `become` item is decided
- **Blocked on it:** every example using these spellings, which are provisional
- **Options so far:**
  1. `mut`: keep it, or spell it out as `mutable`.
  2. `become`: **decided** by [D0014](decisions/D0014-tailcall-keyword.md) on 2026-11-16 (T0008): `tailcall f(x)`.
  3. `dbg`: keep it (common tool vocabulary), or `debug`.
- **Notes:** each spelling must pass the test in D0007: a reader understands it without knowing a particular source
  language.

### OQ-006: How is an extension opt-in written, and where may it appear?

- **Status:** Open
- **Arose in:** T0004 (M00), from [D0019](decisions/D0019-extensions-by-source-opt-in.md) (extensions only with an
  opt-in in the source file)
- **To be settled in:** M09 (units and the build model) or M11 (attributes), whichever comes first
- **Blocked on it:** the syntax and placement of the opt-in in spec
  [§1.2.3](../spec/01-introduction.md#123-extensions), which is provisional
- **Options so far:**
  1. A declaration at the top of a file, such as `use feature pipe_operator;` (provisional syntax).
  2. An attribute on the file or unit, once M11 decides attributes.
  3. An entry in a unit's manifest, if M09 has manifests. This weakens "meaning visible in the file" unless the file
     also names the extension.
- **Notes:** an opt-in naming an unknown extension is rejected with `R-extension-unknown`. Extension names follow
  [D0007](decisions/D0007-intuitive-names.md) and [D0020](decisions/D0020-us-english-spelling.md).

### OQ-007: How does the mechanized core represent binders?

- **Status:** Open
- **Arose in:** T0005 (M00), from [D0024](decisions/D0024-mechanize-the-core.md) and
  [D0028](decisions/D0028-mechanization-starts-in-m03.md) (the core is mechanized in Lean 4 from M03)
- **To be settled in:** M03, by the first task that writes formal rules
- **Blocked on it:** the first Lean definitions of the core in `docs/spec/formal/lean/`
- **Options so far:**
  1. De Bruijn indices: a variable is the number of binders between it and its binder (used in the T0005 pilot,
     [R0004](research/R0004-formalization-prior-art-and-pilots.md)).
  2. Locally nameless: names for free variables, indices for bound ones.
  3. Intrinsically typed (well-scoped or well-typed by construction) syntax.
- **Notes:** the choice is internal to the core. Surface scoping is resolved by elaboration
  ([D0022](decisions/D0022-typed-elaboration-into-core.md)) before the core sees any variable. The core has binders
  for terms, types, and purities (M05, M06), and the representation must serve all three.

### OQ-008: What is the core interchange format, and how do implementations emit core?

- **Status:** Open
- **Arose in:** T0005 (M00), from [D0027](decisions/D0027-executable-reference.md) (a verified reference evaluator and
  checker that read core programs)
- **To be settled in:** I2's opening task, before the host compiler is built, because the host compiler reads the core
  the host interpreter emits ([D0030](decisions/D0030-three-part-host.md)); or earlier, in I1, if I1 is the first to
  send core across a boundary, for example to the Lean reference
  ([D0038](decisions/D0038-m16-merged-into-implementation-milestones.md); M16 was merged into I1–I3)
- **Blocked on it:** the reference tool's name and commands, which are provisional; running implementations against
  the reference; the interface between the host interpreter and the host compiler
- **Options so far:**
  1. A textual S-expression form of the core, printed by implementations on request.
  2. A binary serialization.
  3. Both, with the textual form normative.
- **Notes:** the format must carry every explicit type and purity instantiation, and enough source locations to map
  a core rejection back to surface code.

### OQ-009: What is the bytecode format between the host compiler and the host VM?

- **Status:** Open
- **Arose in:** T0006 (M00), from [D0030](decisions/D0030-three-part-host.md) (the host compiler lowers the typed core
  to bytecode, which the host VM runs)
- **To be settled in:** I2's opening task (the format itself;
  [D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)); the M01 part is decided
- **Blocked on it:** the interface between the host compiler ([D0032](decisions/D0032-ocaml-host-compiler.md)) and
  the host VM ([D0033](decisions/D0033-zig-host-vm.md))
- **Options so far:**
  1. An internal, unversioned format that changes freely between releases.
  2. A versioned, documented format, stable within a release series.
  3. A specified format, part of the specification.
- **M01 part decided** by [D0044](decisions/D0044-executables-and-unstable-bytecode.md) on 2026-11-17 (T0009):
  bytecode is internal and unstable (option 1). A build embeds it in a self-contained executable; it can be emitted
  on request, and it loads only in the release that wrote it. Stabilizing it takes a new decision.
- **Notes:**
  - The format must carry enough source locations for a panic to report where it happened.
  - Until native code exists, the host compiler and `qubecc` emit the same format within a release
    ([D0042](decisions/D0042-tree-walker-and-bytecode-vm.md)).

### OQ-010: How is native code generated?

- **Status:** Open
- **Arose in:** T0009 (M01), from [D0043](decisions/D0043-native-code-after-v1.md) (native code after Spec v1.0)
- **To be settled in:** M17, in the post-v1.0 plan
- **Blocked on it:** the native back end of `qubecc` (and of the host compiler, if any;
  [D0047](decisions/D0047-platform-parity.md) does not require one)
- **Options so far:**
  1. Emit C and compile it with `zig cc`, linked against the Zig runtime through its C ABI (the preferred route at
     the time of D0043).
  2. Emit LLVM IR.
  3. A code generator of our own, per architecture.
- **Notes:**
  - Every route must keep `tailcall`'s constant-space guarantee for every callee
    ([D0014](decisions/D0014-tailcall-keyword.md)), growable stacks ([D0012](decisions/D0012-tail-calls-and-stacks.md)),
    precise panic locations, and precise GC roots. Portable C expresses none of the first, which needs trampolines or
    a compiler extension such as Clang's `musttail`.
  - A route that emits C must rule out every C undefined behavior in the code it emits.
  - `qubecc`'s native output links a runtime written in QubeC, not the Zig runtime
    ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); option 1's linking against the Zig runtime would then
    apply only to the host implementation, if it has a native back end.

### OQ-011: How are floating-point math functions and the canonical NaN specified?

- **Status:** Open
- **Arose in:** T0010 (M01), from [D0052](decisions/D0052-bit-identical-floats.md) (bit-identical floats)
- **To be settled in:** M05, with the float types (the library's list of math functions is M14's)
- **Blocked on it:** the results of every math function in the core and standard library; the canonical NaN's bit
  pattern; the float rules of the reference evaluator
- **Options so far:**
  1. Correctly rounded math functions: any correct implementation agrees, such as those of the CORE-MATH project.
  2. One fixed algorithm for each function, such as fdlibm's, which Java's `StrictMath` requires.
  3. A mix: correctly rounded where a practical implementation exists, a fixed algorithm elsewhere.
- **Notes:**
  - The canonical NaN could be the positive quiet NaN `7ff8000000000000`, which WebAssembly's deterministic profile
    produces, or another pattern; our pilot found that arm64 and x86-64 produce different NaNs for `0.0 / 0.0`
    ([R0008](research/R0008-observable-behavior-prior-art-and-pilots.md)).
  - Whichever option is chosen, the Rust interpreter, the Zig VM, and the Lean reference evaluator must compute the
    same results; Lean's `Float.sin` calls C's `sin` and cannot be used as is.

### OQ-013: What exactly is the result form of `main`?

- **Status:** Open
- **Arose in:** T0011 (M01), from [D0057](decisions/D0057-forms-of-main.md) (two forms of `main`) and
  [D0058](decisions/D0058-exit-statuses.md) (status 1 after the error is written)
- **To be settled in:** M08, with M05 (the result type) and M06 (what "can be displayed" means)
- **Blocked on it:** the second form of `main` in
  [spec §1.2.7](../spec/01-introduction.md#127-program-start-and-termination); the text written to standard error for
  an error returned from `main`
- **Options so far:**
  1. The standard result type with the unit success type, and an error type that has a display form (an interface or
     a built-in notion, M06).
  2. As 1, written as `error: <display of e>` on one line.
  3. Generalize the fixed list later, to any return type implementing a library interface (Rust's `Termination`).
- **Notes:** the status stays 1 in every option; extending the list only adds forms.

### OQ-014: What is the exact text of the report line and the backtrace delimiter?

- **Status:** Open
- **Arose in:** T0011 (M01), from [D0059](decisions/D0059-report-line-and-backtrace.md) (one specified report line)
  and [D0061](decisions/D0061-failed-standard-output.md) (the "output failed" kind)
- **To be settled in:** M08, with T0013 and M02 (the location's text) and M05 and M14 (kinds and messages)
- **Blocked on it:** the report line's pieces in
  [spec §1.2.7](../spec/01-introduction.md#127-program-start-and-termination); the conformance suite's expected
  standard error for failing runs
- **Options so far:**
  1. The shape fixed in D0059: `panic: <kind>: <message> at <location>`, `exhausted: stack`, `exhausted: memory`,
     with each kind a short lowercase phrase and the location `<source name>:<line>:<column>`.
  2. As 1, with kinds written as stable identifiers (`index-out-of-bounds`) rather than phrases.
- **Notes:** also open: how a message containing a line break or a control character is written so that the report
  stays one line; the delimiter line's text; how an implementation marks a truncated backtrace.

## Decided

### OQ-012: What is the guaranteed minimum depth of nested calls?

- **Status:** Decided by [D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md) on 2026-11-17 (T0011)
- **Arose in:** T0010 (M01), from [D0053](decisions/D0053-resource-exhaustion.md) (resource exhaustion above a
  guaranteed floor) and [D0012](decisions/D0012-tail-calls-and-stacks.md) (growable stacks with a cap)
- **To be settled in:** M01, in T0011 (the runtime and the program lifecycle)
- **Was blocking:** the value in
  [spec §1.2.6](../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) rule 1; the runtimes' default stack cap
- **Options so far:**
  1. A fixed number of nested calls, for example 100,000 or 1,000,000, whatever the size of their frames.
  2. A number of nested calls whose frames are within a stated size, with larger frames counting as several.
  3. A size of stack in bytes of an abstract machine, which each implementation translates into its own frames.
- **Notes:** marked tail calls ([D0014](decisions/D0014-tailcall-keyword.md)) do not count; the value must be
  reachable by every engine on every Tier 1 and Tier 2 platform ([D0046](decisions/D0046-first-platforms-and-tiers.md)),
  including the tree-walking interpreter, which nests host calls.
- **Resolution:** 100,000 nested calls, each with a frame of at most 256 values, a larger frame counting as several
  calls (option 2); `tailcall`s do not count. Each runtime has a default stack cap at least that large, 1 GiB of stack
  memory in the host implementation, which an input of the run may raise
  ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)).

### OQ-004: What does "functional in style" commit QubeC to?

- **Status:** Decided by [D0008](decisions/D0008-purity.md) on 2026-11-16 (T0003)
- **Arose in:** T0002 (M00), from the initial idea and the dream snippet in [vision.md](vision.md), which assumes a
  pure `func` and an effectful `proc`
- **To be settled in:** framed in T0003 (M00); decided in M04 (mutability) and M08 (purity and effects)
- **Was blocking:** the meaning of `func` and `proc` in the dream snippet (their spelling was already settled by
  [D0007](decisions/D0007-intuitive-names.md))
- **Options so far:**
  1. A declaration-level split: pure `func`, effectful `proc`.
  2. Effect tracking in types (for example effect rows), with no separate keyword.
  3. Immutability by default and first-class functions, but no tracked purity.
- **Notes:** NG-5 ([D0005](decisions/D0005-non-goals.md)) rules out monad-encoded effects, not effect tracking.
- **Resolution:** purity is tracked by a declaration-level split, a pure `func` and an effectful `proc`
  ([D0008](decisions/D0008-purity.md)), with immutable bindings by default
  ([D0009](decisions/D0009-immutable-bindings.md)) and local mutation of created values allowed in functions
  ([D0011](decisions/D0011-local-mutation-in-functions.md)). The mechanics of effects remain M08's.
