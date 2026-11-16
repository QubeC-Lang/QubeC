# D0010: The default collections are mutable; immutable collections are in the library

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

What do `List`, `Map`, and `Set` mean when written without qualification: **persistent** (immutable, where an
update returns a new version sharing structure with the old one) or **mutable** (changed in place)? This interacts
with purity ([D0008](D0008-purity.md)) and with the self-hosting yardstick ([D0002](D0002-purpose-and-domain.md)),
whose classic case is a compiler's scoped symbol table.

## Options considered

The scenario is the same for all: a scoped symbol table, where entering a block adds names and leaving it restores
the outer scope. Provisional syntax.

### A. Persistent by default; mutable collections opt-in

`List`, `Map`, and `Set` are persistent (for example hash-array-mapped tries); mutable arrays and buffers are
separate, explicitly named types.

```
func check_block(env: Map[Str, Type], stmts: List[Stmt]) -> Result[Unit, TypeError] = {
  let mut scope = env;                         // a local name; env itself never changes
  for s in stmts {
    match s {
      Let(name, init) -> { let t = type_of(scope, init)?; scope = scope.insert(name, t); },
      Expr(e)         -> { type_of(scope, e)?; },
    }
  }
  Ok(())                                       // the caller's env is untouched
};
```

- **Easy:** scopes are free; sharing across tasks is safe; pure code never needs builders.
- **Hard:** constant-factor costs and pressure on the memory manager; bulk construction wants builders.
- **For implementers:** a good persistent map early in M14; no heap mutation in the formal model of collections.
- **Prior art (recalled):** Clojure, Scala's default imports, OCaml's `Map` and `Set`, Elm; Lean 4 and Koka reuse
  uniquely referenced values in place.

### B. Mutable by default; persistent collections in the library

`List` is a growable array and `Map` a hash map, both mutated in place.

```
proc check_block(env: &mut Map[Str, Type], stmts: List[Stmt]) -> Result[Unit, TypeError] {
  let saved = env.clone();                     // or record which names to remove later
  for s in stmts {
    match s {
      Let(name, init) -> { let t = type_of(env, init)?; env.insert(name, t); },
      Expr(e)         -> { type_of(env, e)?; },
    }
  }
  *env = saved;                                // restore the outer scope by hand
  Ok(())
}
```

- **Easy:** the fastest by default; familiar to Python, Go, and Rust users.
- **Hard:** collection-building code in a `func` needs a rule for mutating locally created values (answered by
  [D0011](D0011-local-mutation-in-functions.md)); mutable collections shared between tasks need a race-freedom rule
  (OQ-001).
- **Prior art (recalled):** Rust, Python, Go, Java.

### C. Read-only views over mutable implementations

As in Kotlin: `List` is an interface without mutating methods, and adding an element copies.

```
scope = scope + (name to t);                   // O(n) copy per update
```

- **Easy:** simple to implement; familiar to Kotlin users.
- **Hard:** O(n) updates; read-only is not immutable, since a holder of the mutable reference can still change it.
- **Prior art (recalled):** Kotlin's read-only collections; Java's `Collections.unmodifiableList`.

Recommendation at the time: **A**, because it makes the yardstick case trivial and fits pure functions without
builders.

## Choice

**B.**
- The unqualified `List`, `Map`, and `Set` are **mutable** collections.
- Immutable (persistent) collections are provided by the standard library. Their names are provisional; the vision
  uses `ImmutableMap` (with `ImmutableList` and `ImmutableSet` to match), and M14 decides the final names under
  [D0007](D0007-intuitive-names.md).
- Pure functions may build mutable collections they create themselves
  ([D0011](D0011-local-mutation-in-functions.md)).

## Rationale

We chose B over the recommendation at the time. B's advantages carry the decision: it is the fastest default, and
it is what programmers from Python, Go, and Rust expect. Its costs are addressed separately. The yardstick's scoped
tables are served by the library's immutable maps, and D0011 keeps locally built collections pure.

## Consequences

- **D0011 is required:** without it, most collection-building `func`s would have to be `proc`s.
- **M07:** must provide the check that makes D0011 sound, and decides how collections are passed (by reference,
  borrowed, moved).
- **M10:** mutable collections crossing a channel or captured by a task must be moved (the sender loses access) or
  forbidden ([OQ-001](../open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)).
- **M14:** provides both families early: mutable `List`, `Map`, `Set`, and their immutable counterparts.
- The dream snippet's evaluator uses `ImmutableMap`, because it relies on `insert` returning a new map.

## Affected artifacts

- Spec: none yet (the standard library in M14)
- Grammar rules: none
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md) (dream snippet uses `ImmutableMap`)
