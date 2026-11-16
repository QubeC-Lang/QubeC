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
  - Uncoloured lightweight tasks need an M:N scheduler and growable stacks, which M01 must allow.
  - A receive from a closed channel cannot return a zero value (NG-8, [D0005](decisions/D0005-non-goals.md)). It
    must return an `Option`, block, or panic, or closing must be designed differently.
  - Directional channel types, if any, cannot convert implicitly (NG-9).
  - `<-` as one token makes `x<-1` a send; M02 must accept or avoid that.

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

### OQ-004: What does "functional in style" commit QubeC to?

- **Status:** Open
- **Arose in:** T0002 (M00), from the initial idea and the dream snippet in [vision.md](vision.md), which assumes a
  pure `func` and an effectful `proc`
- **To be settled in:** framed in T0003 (M00); decided in M04 (mutability) and M08 (purity and effects)
- **Blocked on it:** `func` and `proc` in the dream snippet (their spelling is settled by
  [D0007](decisions/D0007-intuitive-names.md), their meaning is not)
- **Options so far:**
  1. A declaration-level split: pure `func`, effectful `proc`.
  2. Effect tracking in types (for example effect rows), with no separate keyword.
  3. Immutability by default and first-class functions, but no tracked purity.
- **Notes:** NG-5 ([D0005](decisions/D0005-non-goals.md)) rules out monad-encoded effects, not effect tracking.

## Decided

None yet.
