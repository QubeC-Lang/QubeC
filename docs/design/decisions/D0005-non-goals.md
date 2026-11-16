# D0005: Non-goals

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0002 |

## Question

What will QubeC deliberately *not* be? A non-goal is a pre-decided "no" that saves a debate in every later
milestone. It can be revisited only by a superseding decision.

Three non-goals follow from earlier choices and were recorded without a separate vote:
- indentation-sensitive syntax (from the initial idea);
- dynamic or gradual typing (from "strictly typed");
- a systems-first, no-runtime default (from [D0002](D0002-purpose-and-domain.md) and
  [D0004](D0004-ranked-design-values.md)).

The question was which of four further candidates to add.

## Options considered (multi-select)

Each candidate shows the style it would exclude. The scenario is the same for all: count the lines of a file that
contain `TODO`.

### A. Lazy evaluation by default

An expression is evaluated only when its value is demanded; until then it is a *thunk* (a suspended computation).
Excluding this makes QubeC strict (call-by-value). Lazy sequences remain a library feature.

```haskell
main = do
  text <- readFile "notes.txt"            -- lazy IO: read on demand
  let todos = filter ("TODO" `isInfixOf`) (lines text)
  print (length todos)
-- foldl over big lists builds thunks (space leaks); lazy readFile can hold the handle open
```

- **If excluded:** costs stay predictable, and the dynamic semantics has no thunks or sharing to model.
- **Prior art (recalled):** Haskell's space leaks. OCaml, F#, Rust, Scala, and Gleam are strict, with opt-in
  laziness.

### B. Effects encoded as monads (`IO`-style enforced purity)

A function that does IO returns `IO Int` rather than `Int`. A monad is a type such as `IO a` ("a recipe that, when
run, yields an `a`") with a way to chain recipes. Combining effects needs monad-transformer stacks.

```haskell
countTodos :: FilePath -> IO Int
countTodos p = do
  text <- readFile p
  pure (length (filter ("TODO" `isInfixOf`) (lines text)))
-- adding a debug print in a pure helper changes its type and all its callers
```

- **If excluded:** effects are not encoded as monads. This does **not** decide effect tracking: M08 may still choose
  a purity marker or effect rows (a row lists what a function may do, and a row variable lets a higher-order
  function say "whatever my callback does").
- **Prior art (recalled):** Haskell's transformer stacks. Koka, OCaml 5 effect handlers, and Unison's abilities
  track effects without them.

### C. Class-based implementation inheritance

A subclass inherits fields and method bodies and may override them. Excluding it means polymorphism comes from
generics and traits (M06). Interfaces without inherited implementation remain possible.

```kotlin
abstract class Tool { abstract fun run(path: String): Int }
class TodoCounter : Tool() {
  override fun run(path: String) = File(path).readLines().count { "TODO" in it }
}
```

- **If excluded:** M05 leans toward no subtyping, which keeps inference and the soundness proof simpler. Known
  unsoundness in Java and Scala arises from `null` combined with subtyping constraints
  ([R0001](../research/R0001-vision-prior-art.md)).
- **Prior art (recalled):** Rust, Go, Haskell, and Gleam manage without inheritance; Kotlin and Scala carry two
  paradigms.

### D. Dependent types and in-program proofs

Types may mention values (`Vect n String`), and functions may return proofs. Type checking may then evaluate
arbitrary code.

```
countTodos : (xs : Vect n String) -> (k : Nat ** LTE k n)
-- callers juggle proofs; checking may evaluate arbitrary terms
```

- **If excluded:** QubeC is proved sound *about* the language (M13), and programs carry no proofs. Const generics
  and light refinements stay open for M05 and M06. Type checking stays decidable and fast.
- **Prior art (recalled):** Idris and Agda are brilliant but niche. Lean 4 succeeds because its users want proofs.

Recommendation at the time: **all four**. Strictness and the absence of inheritance simplify the formal semantics
considerably. Excluding monads keeps effect tracking open for M08. Excluding dependent types keeps checking decidable
while leaving room for light refinements.

## Choice

| ID | Non-goal | Source |
| --- | --- | --- |
| NG-1 | Indentation-sensitive syntax | initial idea |
| NG-2 | Dynamic or gradual typing | initial idea ("strictly typed") |
| NG-3 | A systems-first, no-runtime default. Freestanding work is reached through the explicit layer and later milestones (M01, M07, M12), never by making it the default. | D0002, D0004 |
| NG-4 | Lazy evaluation by default | candidate A |
| NG-5 | Encoding effects as monads (`IO`-style enforced purity) | candidate B |
| NG-6 | Class-based implementation inheritance | candidate C |
| NG-7 | Dependent types and in-program proofs | candidate D |
| NG-8 | `null` as a value of ordinary types | anti-inspiration, [D0006](D0006-inspirations.md) |
| NG-9 | Implicit conversions between types, especially lossy ones, and undefined behaviour in safe code | anti-inspiration, D0006 |
| NG-10 | Errors that can be silently ignored, and error-handling noise (repeated checks, checked-exception lists) | anti-inspiration, D0006 |
| NG-11 | Invisible inserted code: implicit conversions, resolutions that cannot be explained in one diagnostic, hidden control flow | anti-inspiration, D0006 |

## Rationale

We adopted all four candidates, for the reasons in the recommendation, together with the three implied non-goals.
NG-8 to NG-11 restate the anti-inspirations chosen in D0006 as checkable non-goals.

## Consequences

- **M01:** strict evaluation; the default layer may have a runtime.
- **M05:** no inheritance subtyping, no `null`, and no implicit conversions (integer literals may still be typed
  flexibly).
- **M06:** dispatch through generics and traits only; every resolution must be explainable in one diagnostic.
- **M08:** effect tracking stays open, but not via monads.
- **M13:** proofs live in the metatheory, not in user programs.

## Affected artifacts

- Spec: none yet
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md)
