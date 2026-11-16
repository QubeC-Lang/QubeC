# D0006: Inspirations and anti-inspirations

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

Which languages do we borrow from on purpose, and what do we take from each? Which designs do we guard against? An
inspiration is not a promise to copy syntax ([D0007](D0007-intuitive-names.md) governs naming). It names a proven
design that later milestones start from. Each anti-inspiration becomes a checkable non-goal in
[D0005](D0005-non-goals.md).

## Options considered: inspirations (multi-select)

The scenario is the same for all: look up `"port"` in a config map, parse it as an integer, and fall back to 8080
when it is missing, with a clear error when it is malformed.

### A. The ML family (OCaml, F#, Standard ML)

ADTs and exhaustive `match`; Hindley–Milner-style inference; expression orientation; persistent data structures.

```ocaml
let port (cfg : string StrMap.t) : (int, string) result =
  match StrMap.find_opt "port" cfg with
  | None   -> Ok 8080
  | Some s -> (match int_of_string_opt s with
               | Some p -> Ok p
               | None   -> Error ("bad port: " ^ s))
```

This is the standard design for compilers. The weak spots are a dated module and functor learning curve, and
limited low-level control.

### B. Rust

`Result` with `?`; expression-oriented blocks; traits instead of inheritance; ownership and borrowing (as the safety
mechanism of the explicit layer, [D0004](D0004-ranked-design-values.md)); Cargo-grade tooling.

```rust
fn port(cfg: &HashMap<String, String>) -> Result<u16, String> {
    match cfg.get("port") {
        None => Ok(8080),
        Some(s) => s.parse().map_err(|_| format!("bad port: {s}")),
    }
}
```

It is widely admired. The borrow checker's learning curve is the known cost; for QubeC it applies only in the
explicit layer.

### C. Kotlin and Scala 3

Null-safety in types; concise and trailing lambdas; extension functions; string templates; data and enum types.

```kotlin
fun port(cfg: Map<String, String>): Result<Int> {
    val s = cfg["port"] ?: return Result.success(8080)
    return s.toIntOrNull()?.let { Result.success(it) }
        ?: Result.failure(IllegalArgumentException("bad port: $s"))
}
```

The ergonomics are loved. Extension functions complicate name resolution (M04, M09), and Scala's power became its
reputation for complexity.

### D. Go's concurrency

Lightweight tasks, channels, and `select`, with no `async` *coloring* (where an async function can only be awaited
from another async function, so the "color" spreads through the call graph). A runtime schedules many lightweight
tasks onto a few OS threads (M:N scheduling).

```go
func port(cfg map[string]string) (int, error) {
    s, ok := cfg["port"]
    if !ok { return 8080, nil }
    p, err := strconv.Atoi(s)
    if err != nil { return 0, fmt.Errorf("bad port: %s", s) }
    return p, nil
}
// go loadAll(files)  — concurrency without changing port's signature
```

- **Costs:** an M:N scheduler and growable stacks in the runtime, which affect M01, the explicit layer, and M12
  interop (cgo's call overhead is the precedent). Go is not data-race-free, so Safety (#1) requires M10 to add race
  freedom, for example by restricting what crosses a channel, as Rust's `Send` does.
- **Prior art for uncolored concurrency (recalled):** Java virtual threads (2023), OCaml 5 effect handlers.

Also mentioned, not selected: Zig (comptime, explicit allocators), Gleam and Elm (friendly errors, small languages),
and Koka (effect rows and handlers, relevant to M08).

Recommendation at the time: **A + B + C now, with D left to M10**, because D is a concurrency-model decision that
forces M01 (scheduler, growable stacks) and M10 (race freedom) before either is designed.

## Options considered: anti-inspirations (multi-select)

The scenario is the same for all: turn user input such as `"42"` into a percentage between 0 and 100.

### A. Undefined behavior and implicit conversions (C, C++)

```c
int pct = atoi(input);          // "abc" -> 0 silently; overflow is UB
unsigned char small = pct * 3;  // implicit narrowing: 300 becomes 44
if (pct < 0u) { ... }           // signed/unsigned mix changes the comparison
```

Guarding against it: conversions are always written out, and no operation in safe code is undefined.

### B. `null` and boilerplate (classic Java)

```java
String raw = form.get("pct");               // may be null; the type doesn't say
int pct = Integer.parseInt(raw.trim());     // NullPointerException if absent
public final class Pct {                    // + constructor, getter, equals, hashCode, toString …
  private final int value; /* 30 lines */ }
```

Guarding against it: absence is in the type, and data types get structural equality and printing for free.

### C. Ignorable errors and error-handling noise (C return codes, Go's `if err != nil`, Java's checked exceptions)

```go
p, err := strconv.Atoi(input)
if err != nil { return 0, err }        // repeated after every call
if p < 0 || p > 100 { return 0, fmt.Errorf("out of range") }
os.Remove(tmp)                         // error silently ignored: it compiles
```

Guarding against it: an error result cannot be silently discarded, and propagation is one token (`?`). There are no
checked-exception signature lists.

### D. Invisible magic (Scala 2 implicits, C++ argument-dependent lookup and implicit constructors, monkey-patching)

```scala
implicit def strToPct(s: String): Pct = Pct(s.toInt)   // conversion inserted silently
def show(p: Pct) = ...
show("42")                    // compiles; where did the Pct come from?
```

Guarding against it: nothing is inserted that a reader cannot find, and every resolution (trait instance, extension
method) is explainable in one diagnostic.

Recommendation at the time: **all four**. Each follows from Safety or Predictability, and none conflicts with the
inspirations; D only constrains how extension functions resolve.

## Choice

**Inspirations: A, B, C, and D.**

| From | What we take | Why |
| --- | --- | --- |
| ML | ADTs and exhaustive `match` | Illegal states are unrepresentable and every case is checked: the backbone of compilers. |
| ML | Type inference, expression orientation, persistent data | Strong types with little ceremony. |
| Rust | `Result` and `?` | Errors are values, explicit in types and cheap to propagate. |
| Rust | Expression-oriented blocks, traits | Everything yields a value; polymorphism without inheritance. |
| Rust | Ownership and borrowing | The safety mechanism of the explicit layer. |
| Rust | Cargo-grade tooling | Build, test, and dependencies built in (M15). |
| Kotlin/Scala 3 | Null-safety in types; concise, trailing lambdas | Readable everyday code. |
| Kotlin/Scala 3 | Extension functions, string templates, data and enum types | Less boilerplate. |
| Go | Lightweight tasks, channels, `select`; no `async` coloring | Concurrency that stays out of function signatures. |

**Anti-inspirations: A, B, C, and D**, restated as NG-8 to NG-11 in D0005.

## Rationale

The ML, Rust, and Kotlin/Scala inspirations match the three user groups of [D0003](D0003-target-users.md) one to
one. We also chose Go's uncolored concurrency, accepting its costs knowingly: it requires a runtime scheduler and
growable stacks, and Safety requires M10 to add data-race freedom on top of it. The anti-inspirations follow from
Safety and Predictability.

## Consequences

- **M10** must reconcile Go-style tasks and channels with data-race freedom, and **M01** must allow a scheduler and
  growable stacks
  ([OQ-001](../open-questions.md#oq-001-how-does-go-style-concurrency-become-data-race-free-and-what-does-it-require-of-the-runtime)).
- **M05:** Kotlin-style `T?` and ML/Rust-style `Option[T]` are two ways to express absence; which one, or how they
  relate, is open
  ([OQ-002](../open-questions.md#oq-002-is-absence-written-optiont-t-or-both)).
- **M04, M09:** extension functions need a lookup rule that NG-11 accepts (explicit import, one-diagnostic
  explanation).
- **M08:** `Result` with `?` is the leading candidate for error propagation; the decision itself is M08's.
- **M15:** Cargo-grade tooling sets the bar.

## Affected artifacts

- Spec: none yet
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md)
