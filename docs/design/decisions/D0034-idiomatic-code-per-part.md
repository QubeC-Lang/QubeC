# D0034: Each host part is idiomatic for its language; the self-hosted compiler is designed fresh

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

With a permanent host that leads every feature ([D0029](D0029-permanent-host-implementation.md)) and three parts in
three languages ([D0030](D0030-three-part-host.md)), each feature is written in up to four codebases: the host
interpreter (Rust), the host compiler (OCaml), the host VM (Zig), and later `qubecc`. Should that code look alike?

## Options considered

The scenario: the core's conditional form, and the rule ID for a condition that is not `Bool`, across the parts. The
rule ID is illustrative.

### A. Idiomatic per language, nothing shared

Each part is written the way its language's community writes it; `qubecc` is designed fresh in QubeC idioms.

```
Rust   CoreKind::Cond { test, then_br, else_br }        err(RuleId::CondNotBool, …)
OCaml  | Branch (c, t, e) -> …
Zig    .jif => …
qubecc Core.Conditional(…)                              // designed fresh later
```

- **Easy:** each part is pleasant to write; no cross-part rules.
- **Hard:** reading one part to fix another means translating names; a search across parts finds nothing in common.

### B. QubeC-shaped everywhere

The Rust and OCaml parts are written in a style QubeC will support (ADTs, mostly pure functions, no host-specific
cleverness), so that `qubecc` is close to a transliteration.

```rust
fn elaborate(env: &Env, e: &Expr) -> Result<(Core, Purity), Reject> {
    match e { Expr::If(c, t, f) => { let (cc, _) = elaborate(env, c)?; … } … }
}
```

- **Easy:** a cheap port to `qubecc`.
- **Hard:** each language is used against its grain; QubeC's idioms are not designed yet (M03–M08); it cannot apply
  to the VM.

### C. Spec-aligned names, idiomatic otherwise

Structure is idiomatic, but every name the specification defines (core forms, passes, rule IDs, opcodes) is spelled
the same in every part, changing only the case convention; and a missing case is an error in every part.

```
Rust   Core::If { cond, then, else_ }    reject(Rule::IfConditionNotBool, …)
OCaml  | If (cond, then_, else_) -> …
Zig    .jump_if_false => …
qubecc Core.If(…)
```

- **Easy:** a search finds a construct in every part; reviewing against the spec is direct.
- **Hard:** some friction with keywords and conventions; spec renames ripple through every part.

| | A Idiomatic | B QubeC-shaped | C Spec-aligned names |
| --- | --- | --- | --- |
| Pleasant per language | ✓✓ | ✗ | ✓ |
| Cross-reading the parts | ✗ | ✓ | ✓✓ |
| Port to `qubecc` | rewrite | near-transliteration | rewrite with a map |
| Depends on undesigned idioms | no | yes | no |

Recommendation at the time: **C**, because every feature touches several codebases forever and shared names pay off
with each one.

## Choice

**A.**
1. Each host part is idiomatic for its language. There are no shared style rules and no shared code between the
   parts.
2. `qubecc` is designed fresh in QubeC idioms, not ported from the host.
3. What binds every part, whatever its style, is conformance: every rejection reports its rule ID
   ([D0018](D0018-diagnosis-and-rule-ids.md)); the core the host interpreter emits passes the reference checker
   ([D0027](D0027-executable-reference.md)); and the shared contract between the parts, `qubecc`, and the reference is
   the specification, its conformance suite, the core interchange format, and the bytecode format.

## Rationale

Each part should be pleasant to write and to maintain in its own language, which matters most for code kept
indefinitely. The parts communicate only through specified formats, so their internals need not agree, and
conformance, not style, is what keeps them consistent. Designing `qubecc` fresh lets it show what idiomatic QubeC
looks like rather than reflect three other languages. We accept that the parts name the same things differently.

## Consequences

- **M16:** each part's conventions (formatting, linting, warning levels, including whether OCaml's non-exhaustive
  match warning is fatal) are set per part.
- **M15:** the conformance suite is the cross-part check.
- Self-hosting is a rewrite, with the specification and formats as its map.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
