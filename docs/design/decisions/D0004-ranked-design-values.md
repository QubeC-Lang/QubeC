# D0004: Ranked design values, layered: a default layer and an explicit layer

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

Which 3 to 5 design values come first, and in what order? Later records cite the ranking as their tie-breaker, for
example "checked arithmetic, because Safety (#1) > Performance". A ranking is a lexicographic order over trade-offs:
a lower value matters only when the higher ones are tied. This builds on [D0002](D0002-purpose-and-domain.md) and
[D0003](D0003-target-users.md). Because the users include both application developers and systems programmers, one
ranking may not serve them both.

## Values defined

| Value | Meaning |
| --- | --- |
| Safety | Well-typed code cannot corrupt memory or hit undefined behaviour (UB). Failures are defined: an error or a panic, never silent garbage. |
| Rigor | A precise spec, a sound type system, and provable properties. Features that resist formalization lose ties. |
| Simplicity | Few concepts that compose well; a small spec; one obvious way to do common things. |
| Expressiveness | Abstraction power: generics, traits, higher-order functions, effects, metaprogramming. |
| Predictability | What you see is what runs: no hidden allocation or control flow, and visible costs. |
| Performance | Run-time speed and memory use; zero-cost abstractions. |
| Ergonomics | Low ceremony: inference, defaults, sugar. |
| Compile speed | Fast builds; doubly important for a self-hosted compiler. |
| Tooling | Diagnostics, formatter, language server, and docs, designed in. |
| Interop | Calls to and from C and other ecosystems; ABI control. |

**The layering idea.** A *default layer*, which everyday code uses, is judged by one ranking. An opt-in
*explicit layer* is judged by another. The explicit layer is a set of forms in the same language, not a dialect:
sized integers, borrowed slices and references, explicit casts. It stays safe; only its cost model changes.
Unchecked operations would be a separate escape hatch (M07).

## Options considered

Each option writes `average` of a list of integers. The tricky cases are the empty list and an overflowing sum.
Provisional syntax.

### 1. Layered: safe and simple by default, safe and fast when explicit

- **Default layer:** Safety > Simplicity > Ergonomics > Predictability > Performance.
- **Explicit layer:** Safety > Performance > Predictability.

```
fn average(xs: List[Int]) -> Option[Int] =          // default layer
  if xs.is_empty() then None else Some(xs.sum() / xs.len())
  // Int: one checked integer type; overflow is a defined panic

fn average_fast(xs: &[i64]) -> Option[i64] {        // explicit layer: opt-in, still safe
  if xs.is_empty() { return None }
  let mut sum: i64 = 0
  for x in xs { sum = sum.checked_add(*x)? }
  Some(sum / xs.len() as i64)
}
```

- **Easy:** each user group gets its own judge; beginners never see `&[i64]`.
- **Hard:** M07 must make borrowed references safe in the explicit layer, which needs a restricted borrow checker.
- **Prior art (recalled):** C# layers `Span<T>` and `ref struct` under a GC, as safe code with compiler-checked
  escape rules. Swift layers `borrowing`/`consuming` over ARC. Both show it is feasible; both arrived late, with
  many rules.

### 2. Layered, with Rigor ranked second

- **Default layer:** Safety > Rigor > Simplicity > Ergonomics > Performance.
- **Explicit layer:** as in option 1.

The code is the same as option 1. The difference shows in later ties: a feature that cannot be specified formally
(say, a powerful macro system or an unusual inference feature) loses to a plainer one.

- **Easy:** the formal models stay complete, and the proof work is protected from feature creep.
- **Hard:** some convenient features are rejected or delayed.
- **Prior art (recalled):** Standard ML has a full formal definition; it is very rigorous, and stayed small and slow
  to evolve. WebAssembly is mechanized and successful, because its domain wants rigor.

### 3. One ranking, safe and simple

Safety > Simplicity > Ergonomics > Predictability > Performance, everywhere.

```
fn average(xs: List[Int]) -> Option[Int] =
  if xs.is_empty() then None else Some(xs.sum() / xs.len())
  // no sized integers in the language, or only as library types judged the same way
```

- **Easy:** the smallest spec and the easiest formalization.
- **Hard:** systems programmers are poorly served, against D0003.
- **Prior art (recalled):** Gleam and Elm, loved for simplicity; Elm hit the limits of what it refused to provide.
  OCaml's single 63-bit `int` is a known wart for low-level work.

### 4. One ranking, safe and fast

Safety > Performance > Predictability > Expressiveness > Ergonomics, everywhere.

```
fn average(xs: &[i64]) -> Option[i64] {
  if xs.is_empty() { return None }
  let mut sum: i64 = 0
  for x in xs { sum = sum.checked_add(*x)? }
  Some(sum / xs.len() as i64)
}
```

- **Easy:** performance is predictable everywhere.
- **Hard:** application developers and "easy to start" lose almost every tie.
- **Prior art (recalled):** Rust, where features are argued against zero-cost for years.

| | 1 Layered | 2 Layered + Rigor | 3 Safe and simple | 4 Safe and fast |
| --- | --- | --- | --- | --- |
| Serves all three user groups | ✓✓ | ✓✓ | ✗ (systems) | ✗ (apps) |
| "Easy to start" | ✓ | ✓ | ✓✓ | ✗ |
| Formalization effort | high (borrowing) | high, but protected | lowest | medium–high |
| Formal tractability as a tie-breaker | no | yes | no | no |

Recommendation at the time: **1 or 2**, since options 3 and 4 each abandon a user group. We leaned slightly toward 2
because of the formal deliverables, but treated the choice between 1 and 2 as a preference and marked neither.

## Choice

**Option 1.**
- **Default layer:** **Safety > Simplicity > Ergonomics > Predictability > Performance.**
- **Explicit layer:** **Safety > Performance > Predictability.**
- The explicit layer is the opt-in set of forms in the same language: sized integers, borrowed slices and
  references, explicit casts. These forms appear only where written, and they remain safe.
- Unchecked operations belong to a separate escape hatch, decided in M07. Safety is first in both layers.
- Rigor is not ranked. The formal models remain deliverables of the project, but formal tractability is not by
  itself a tie-breaker.

## Rationale

No single ranking serves all three user groups of D0003. The layered rule gives application developers a simple,
safe default and gives systems programmers an explicit layer judged by performance, without a separate dialect. We
did not rank Rigor: formalization should describe the language we want, rather than veto features in advance.

## Consequences

- **M05:** decides how the explicit layer is marked and how `Int` relates to sized integers
  ([OQ-003](../open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones)).
- **M06:** the standard library needs generics over numeric types, to avoid one function per width.
- **M07:** must provide safe borrowed references for the explicit layer. This is the hardest formalization item.
- **All later decisions:** they cite this ranking. A decision that ranks Performance above Simplicity in the default
  layer needs an explicit justification.

How the ranking is meant to argue, illustratively (each actual rule is decided in its milestone):

| Conflict | Ranking says |
| --- | --- |
| Integer overflow | Safety wins in both layers: checked by default; wrapping only when written, e.g. `wrapping_add` |
| `1 + 2.5` silently becoming a float | Safety and Predictability over Ergonomics: write the conversion |
| Array bounds checks | Safety in both layers; unchecked access only through M07's escape hatch |
| One `Int` or many widths | Default layer: Simplicity (one `Int`); explicit layer: Performance (sized types) |

## Affected artifacts

- Spec: none yet (the numeric model in M05; memory in M07)
- Grammar rules: none
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md)
