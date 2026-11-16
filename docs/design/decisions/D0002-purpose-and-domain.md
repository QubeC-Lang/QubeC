# D0002: Purpose and tie-breaking domain: general-purpose, tooling-first

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

QubeC starts as "mainly general-purpose, with some low-level ability, able to self-host eventually". Every
general-purpose language still needs a **tie-breaking domain**: the kind of program whose needs win when two goals
conflict (a garbage collector or ownership, a large runtime or none). Which domain is it? The answer shapes the
runtime (M01), memory (M07), concurrency (M10), and the standard library (M14).

## Options considered

All examples use the same scenario: parse `key = value` lines into a map, reporting the line number of a bad line.
The tricky cases are a missing `=`, an empty key, and blank lines. All code is provisional syntax.

### A. Tooling-first

The flagship programs are compilers, interpreters, linters, formatters, and CLI tools. What a compiler needs is
first-class from the start:
- algebraic data types (ADTs) and exhaustive matching;
- strings and maps, including persistent ones;
- error values and file IO.

Low-level control is opt-in. The standing yardstick for later questions is "could QubeC's own compiler be written
comfortably in this?".

```
type ConfigError = MissingEquals(line: Int) | EmptyKey(line: Int)

fn parse_line(n: Int, s: Str) -> Result[(Str, Str), ConfigError] =
  match s.split_once("=") {
    None         -> Err(MissingEquals(n)),
    Some((k, v)) -> {
      let key = k.trim()
      if key.is_empty() then Err(EmptyKey(n)) else Ok((key, v.trim()))
    },
  }

fn parse(text: Str) -> Result[Map[Str, Str], ConfigError] =
  text.lines().enumerate()
      .filter(|(_, l)| !l.is_blank())
      .try_fold(Map.empty(), |m, (i, l)| {
        let (k, v) = parse_line(i + 1, l)?
        Ok(m.insert(k, v))                    // persistent map: returns a new map
      })
```

- **Easy:** data modeling, transformation, and error reporting. A GC or reference counting is acceptable by default.
- **Hard:** the last 10–20% of performance, and code with no runtime at all. Both need an opt-in lower layer.
- **For implementers:** the formal rules stay close to well-studied ML-family calculi.
- **Locks in / rules out:**
  - ADTs and matching are core (M03, M05);
  - strings and collections are needed early (M14);
  - this is the most direct self-hosting path.
- **Prior art (recalled):** ML began as the meta-language of the LCF theorem prover. OCaml hosted Rust's first
  compiler, Flow, Hack, and Rocq. OCaml's weak points are its low-level story (boxing, little layout control) and its
  late multicore support (OCaml 5, 2022).

### B. Systems-first

There is no mandatory runtime and no hidden allocation. Layout is controllable, the language can run freestanding,
and a functional surface sits on top. Allocation is explicit, and running out of memory is an error value.

```
fn parse(a: &Allocator, text: []u8) -> Result[Map[[]u8, []u8], ConfigError] {
  var map = Map.init(a)
  errdefer map.deinit()
  var n: usize = 0
  for line in text.split('\n') {
    n += 1
    if trim(line).len == 0 { continue }
    let eq = line.index_of('=') else return Err(MissingEquals(n))
    let key = trim(line[0..eq])            // borrows the input
    if key.len == 0 { return Err(EmptyKey(n)) }
    try map.put(key, trim(line[eq+1..]))   // out-of-memory is an error too
  }
  Ok(map)
}
```

- **Easy:** performance; OS and driver work.
- **Hard:** ergonomics, which conflicts with "easy to start".
- **For implementers:** M07 needs ownership or regions everywhere, and the memory model and its soundness become
  the hardest part of the project.
- **Locks in / rules out:** M01 (freestanding), M07, and M12 move to the front.
- **Prior art (recalled):** Rust (a steep curve), Zig (no memory safety; complex comptime), Odin, C.

### C. Applications-first

A GC, a large runtime, async in the core, and exceptions. Low-level work happens only through FFI.

```
async fn load_config(path: Path) -> Map[Str, Str] throws ConfigError {
  let text = await fs.read_text(path)
  var config = Map[Str, Str]()
  for (i, line) in text.lines().enumerate() where !line.is_blank() {
    let parts = line.split("=", limit: 2)
    if parts.len < 2 { throw MissingEquals(i + 1) }
    let key = parts[0].trim()
    if key.is_empty() { throw EmptyKey(i + 1) }
    config[key] = parts[1].trim()
  }
  return config
}
```

- **Easy:** fast delivery and onboarding.
- **Hard:** anything near the hardware.
- **For implementers:** the runtime and standard library dominate the work, and exceptions and async complicate the
  formal semantics.
- **Locks in / rules out:** "some low-level ability" shrinks to FFI only.
- **Prior art (recalled):** Go (its GC and runtime keep it out of kernels), Kotlin, Swift (ARC costs), F#, Gleam.

### D. No tie-breaking domain

QubeC stays general-purpose with no favored kind of program, and ties are broken by the ranked values alone
([D0004](D0004-ranked-design-values.md)).

- **Easy:** no early commitment.
- **Hard:** many ties that values alone don't settle. "Safety versus ergonomics" doesn't say whether persistent maps
  are needed; "what does a compiler need?" does.
- **Prior art (recalled):** C++ and Scala grew by serving many audiences, and are known for their size.

| | A Tooling | B Systems | C Apps | D None |
| --- | --- | --- | --- | --- |
| Fits "easy to start" | ✓ | ✗ | ✓✓ | ? |
| Fits "some low-level ability" | ✓ (opt-in layer) | ✓✓ | ~ (FFI only) | ? |
| Fits "functional style" | ✓✓ | ~ | ✓ | ? |
| Self-hosting path | ✓✓ | ✓ (verbose) | ✓ | ? |
| Formalization difficulty | low–medium | high | medium–high | depends |

Recommendation at the time: **A**. It is the only option that fits every part of the initial idea, it turns
"eventually self-host" into a yardstick later milestones can apply, and it keeps the formal rules in
well-understood territory.

## Choice

**A, tooling-first.**
- QubeC is general-purpose. Its tie-breaking domain is compilers, interpreters, and CLI and developer tools.
- The **self-hosting yardstick**, "could QubeC's own compiler be written comfortably in this?", breaks ties.
- The yardstick is a tie-breaker, not a requirement: it does not oblige the self-hosted compiler to use every
  language feature.
- Low-level work happens in an opt-in layer ([D0004](D0004-ranked-design-values.md)).

## Rationale

We chose A for the reasons in the recommendation. We limited the yardstick to tie-breaking so that it cannot grow
into a scope requirement ("the compiler must exercise the whole language"), which would tie the implementation
plan (M16) to every feature milestone.

## Consequences

- M01 may assume a runtime (GC or reference counting) for the default layer; a no-runtime default is a non-goal
  ([D0005](D0005-non-goals.md)).
- M03 and M05 treat ADTs and exhaustive matching as core, not advanced, features.
- M14 must provide strings, maps (including persistent ones), file IO, and source-location support early.
- Compile speed weighs heavily in M01 and M16, since a self-hosted compiler rebuilds itself constantly.

## Affected artifacts

- Spec: none yet (the introduction's scope section is written once the spec audience is decided, T0004)
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md) (purpose, dream snippet)
