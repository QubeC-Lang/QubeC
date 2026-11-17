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
- **To be settled in:** M01, task T0009 (whether bytecode is an artifact users see, and its stability), and I2's
  opening task (the format itself; [D0038](decisions/D0038-m16-merged-into-implementation-milestones.md))
- **Blocked on it:** the interface between the host compiler ([D0032](decisions/D0032-ocaml-host-compiler.md)) and
  the host VM ([D0033](decisions/D0033-zig-host-vm.md))
- **Options so far:**
  1. An internal, unversioned format that changes freely between releases.
  2. A versioned, documented format, stable within a release series.
  3. A specified format, part of the specification.
- **Notes:** the format must carry enough source locations for a panic to report where it happened.

## Decided

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
