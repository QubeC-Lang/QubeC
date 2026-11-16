# D0011: A pure function may mutate values it created, if the mutation is not observable

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0003 |

## Question

[D0008](D0008-purity.md) forbids a `func` to mutate state it did not create, and allows local mutable variables.
What about values a `func` *creates* and then mutates, such as a list it fills before returning ("builders")? With
mutable default collections ([D0010](D0010-mutable-default-collections.md)), the answer decides whether ordinary
collection code can be pure at all. The vision level decides whether; M07 decides how it is checked.

## Options considered

The scenario is the same for all: a pure `tokenize` that builds a list of tokens. Provisional syntax.

### A. Yes, if the mutable value does not stay observable

A `func` may mutate values it created while they are local, and may return them once it is done with them. It may
not mutate the caller's values, stash a value where it outlives the call, or return a closure that still mutates it.

```
func tokenize(src: Str) -> List[Token] = {
  let mut tokens = List.new();         // created here
  for c in src.chars() { tokens.push(classify(c)); }   // mutating what we created: allowed
  tokens                               // handed over when finished
};

func append_to(out: &mut List[Token], t: Token) = out.push(t);   // error: mutates the caller's list
func counter() -> () -> Int = { let mut n = 0; || { n = n + 1; n } };  // the returned closure is effectful
```

- **Easy:** build-then-return stays pure, matching mutable default collections.
- **Hard:** the checker must establish that nothing escapes while mutable (an ownership or uniqueness analysis);
  diagnostics must explain an escape.
- **Prior art:** D's strongly pure functions may modify their local state and return newly allocated memory
  (verified, [R0002](../research/R0002-purity-and-tail-calls.md)). Haskell's `ST` encapsulates local mutable state
  behind `runST`, whose rank-2 type prevents escape (recalled). Koka has a local state effect discharged at its
  boundary (recalled).

### B. No: mutating a collection's contents is always an effect

A `func` may reassign local variables but never change a collection's contents; pure code uses combinators or
immutable collections.

```
func tokenize(src: Str) -> List[Token] = src.chars().map(classify).collect();
proc tokenize_fast(src: Str) -> List[Token] { let mut tokens = List.new(); …; tokens }
```

- **Easy:** the simplest rule and formal model.
- **Hard:** with mutable defaults, collection code drifts into `proc`s or combinators.
- **Prior art (recalled):** Elm; Haskell outside `ST`.

### C. Defer to M07, treating it as an effect meanwhile

- **Easy:** no commitment now.
- **Hard:** examples must avoid the pattern until M07; M07 inherits a decision that shapes how `func` feels.

Recommendation at the time: **A**, since it is what makes mutable defaults compatible with pure functions, and M07
needs ownership machinery for the explicit layer anyway.

## Choice

**A.** A `func` MAY create values, mutate them, and return them, provided that no mutation is observable outside the
call. In particular it MUST NOT:
- mutate values it did not create, including anything reachable from its parameters;
- store a value it created where the value outlives the call while it can still be mutated;
- return a closure that can still mutate such a value (calling that closure is an effect, and its purity says so).

M07 defines the analysis that enforces this.

## Rationale

Purity is about what the caller can observe: a list filled inside a function and handed over finished is
indistinguishable from one built immutably. Allowing it keeps ordinary collection code pure under mutable defaults.

## Consequences

- **M07:** defines the escape or uniqueness check, ideally reusing the explicit layer's ownership machinery. The
  rule itself is decided now, so examples may use the pattern before M07.
- **M05, M13:** the effect judgment and effect soundness must account for locally created mutable values.
- **M15:** diagnostics explain where a mutable value escaped.

## Affected artifacts

- Spec: none yet (effects in M08, memory in M07)
- Grammar rules: none
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md) (combined sample, `tokenize` and `count`)
