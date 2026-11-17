# D0036: Implementation is a trailing track that starts once M01 and M02 have closed

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

When does implementation work start relative to the design milestones? A design decision is a hypothesis until
something exercises it. The Lean mechanization ([D0024](D0024-mechanize-the-core.md), from M03 by
[D0028](D0028-mechanization-starts-in-m03.md)) exercises the core semantics. Only a running implementation exercises
the rest: how pleasant the grammar is to parse, whether diagnostics can be good, how a real program feels. The host
implementation is permanent and leads every feature ([D0029](D0029-permanent-host-implementation.md)), so it follows
every design change anyway. The question is how early it starts doing so, and whether design ever waits for it.

## Options considered

The scenario for every option: (1) when does `qubec run hello.qbc` first work, and (2) what happens when M05 (types)
forces a change to an M03 rule? For example, M05 decides that `if` without `else` has type `Unit`, so
`let x = if c { 1 };` becomes a rejection (provisional syntax).

### A. Design first

All design milestones finish, and then the implementation is built from the finished spec.

```
M01 M02 … M16 M17 │ implementation
                  ↑ hello.qbc runs
M05 changes an M03 rule: spec + grammar + Lean only.
Usability problems surface after Spec v1.0.
```

- **Easy:** no code is ever reworked; each design milestone carries only design and Lean work.
- **Hard:** for about seventeen milestones, nothing runs except the core in Lean. Parsing pain and poor ergonomics
  surface after the spec is frozen, when fixing them means revisits. The early REPL of [D0013](D0013-easy-start.md)
  arrives very late in the project.
- **For implementers:** the host architecture is designed against a complete spec.
- **Locks in / rules out:** every usability lesson arrives at once, at the end.
- **Prior art:** Algol 68 was specified first, and its implementations were late and partial (recalled,
  [R0006](../research/R0006-planning-prior-art.md)).

### B. Two tracks; implementation starts after a runnable typed core

Design runs M01–M05. Then an implementation milestone builds the host interpreter and REPL for that subset, while
design continues from M06.

```
M01 … M05 │ M06 M07 M08 …     (design)
          └▶ scanner + parser + names + types + interpreter + REPL
             ↑ hello.qbc runs
M05 changes an M03 rule: spec + grammar + Lean only; no code yet.
From M06 on, changes also touch the interpreter.
```

- **Easy:** programs run about a third of the way through. Later milestones can be tried in the REPL. The
  interpreter is built against a settled front end.
- **Hard:** no code exercises the lexical and expression grammar while M02–M04 are being decided, which is where the
  parsing pitfalls are: string templates may need lexer modes, `<-` is a tokenization hazard, and block statements
  bring an expression-or-statement ambiguity.
- **For implementers:** the interpreter's architecture is chosen before M06–M09 exist.
- **Prior art:** Rust's design evolved for years alongside its implementations, and Gleam and Roc co-evolved design
  and implementation (recalled, R0006).

### C. A trailing implementation track from M02

Implementation starts once M01 (execution model) and M02 (lexical structure) have closed. From then on it trails the
design: each design milestone becomes implementable when it closes, and the implementation catches up at its own
pace. Design never waits for code, and code never runs ahead of the spec.

```
M01 M02 │ M03 M04 M05 M06 …   (design)
        └▶ scanner ─▶ parser ─▶ names ─▶ types ─▶ …
                       + core interpreter (with M03's Lean work)
                                       ↑ hello.qbc runs (~M05)
M05 changes an M03 rule (`if` without `else`):
  spec + grammar + Lean, then the parser and interpreter
  catch up; the existing tests show what breaks.
```

- **Easy:** the front end exercises M02–M04's decisions while they are fresh and cheap to revisit. The spec stays
  the authority, because code implements only closed milestones. Design milestones carry no third workload. The
  pipeline is built in the order that interpreter books teach: scanner, parser, evaluator.
- **Hard:** early code is reworked as later milestones extend it: M03 adds tokens, and M05's typed core changes what
  the interpreter evaluates. Two tracks have to be kept consistent. `hello.qbc` does not run much earlier than in B,
  because it needs `proc main`, strings, and a print function (M03–M05 and a library stub). What C gains is
  front-end feedback, not earlier programs.
- **For implementers:** the front end's architecture is chosen before types exist.
- **Locks in / rules out:** nothing beyond B, except that rework starts earlier.
- **Prior art:** Python accepts a PEP before its reference implementation exists, but marks it Final only once the
  implementation is complete. Rust stabilizes a feature only after it is well tested behind a feature gate and has
  a complete Reference text (both verified, R0006).

### D. Lockstep

From M02 on, a design milestone cannot exit until the host interpreter implements it.

```
M02+scanner │ M03+parser+interpreter+Lean │ M04+names+Lean │ …
  each milestone: design + Lean + Rust before it exits
M05 changes an M03 rule: M05 updates spec + grammar + Lean + Rust before it may close.
```

- **Easy:** the finest-grained feedback; no decision is final without having run.
- **Hard:** from M03 on, each milestone carries design, Lean, and Rust work. Milestones implement pieces that cannot
  run yet. The implementation tends to become the definition, which works against the spec's authority
  ([D0016](D0016-authority-per-section.md)).
- **Locks in / rules out:** design pace equals implementation pace, permanently.
- **Prior art:** Swift requires a working prototype before a language proposal can be reviewed (verified, R0006).

| | A Design first | B After M05 | C Trailing from M02 | D Lockstep |
| --- | --- | --- | --- | --- |
| First front-end feedback | after M17 | after M05 | after M02 | at M02 |
| First `qubec run hello.qbc` | after M17 | ~M05 | ~M05 | ~M05 |
| Per-milestone design load | design + Lean | design + Lean | design + Lean | design + Lean + Rust |
| Does design wait for code? | no | no | no | yes |
| Code rework from design changes | none | from M06 on | from M03 on | from M03 on |

Recommendation at the time: **C**, because it gives front-end feedback while M02–M04 are still cheap to change,
keeps the spec authoritative, and adds no third workload to design milestones, given the implementation load that
[D0029](D0029-permanent-host-implementation.md)–[D0035](D0035-pinned-toolchains-and-recorded-libraries.md) created.

## Choice

**C.**
1. Implementation work is a track of its own, the **implementation track**, alongside the **design track** of
   milestones M00, M01, …. Its milestones are defined in [D0037](D0037-implementation-milestones-and-tasks.md) and
   [D0039](D0039-four-implementation-stages.md).
2. The implementation track starts once M01 and M02 have both closed.
3. The implementation track **trails** the design: it implements only what closed design milestones decided. Code
   never runs ahead of the spec.
4. **Design never waits for code.** A design milestone exits by its own criteria, whether or not its features have
   been implemented yet.
5. When a design change reaches code already written, the implementation catches up. A divergence found in the
   other direction (code shows a rule is ambiguous or unworkable) is resolved in the spec, by a revisit task, or
   recorded as an open question ([D0039](D0039-four-implementation-stages.md), criterion P5).

## Rationale

We want the front end to test the lexical, expression, and naming decisions while they are still cheap to change,
and we do not want design milestones to carry a third workload on top of design and Lean. A trailing track gives both:
the scanner and parser follow M02 and M03 closely, and design moves at its own pace. The cost is that early code is
reworked as later milestones extend it. That cost falls mostly on the scanner and parser, the parts that change least
once M04 has closed.

## Consequences

- **M01, M02:** their closing starts the implementation track. Nothing is implemented before both have closed.
- **Every design milestone from M03 on:** its changes may reach existing code. The milestone records the change; the
  implementation track catches up (it does not block the milestone's exit).
- **The workflow:** the design and implementation tracks run in parallel
  ([D0037](D0037-implementation-milestones-and-tasks.md)).
- **D0013:** the REPL and `qubec run` arrive with I1, around the time M05 closes
  ([D0039](D0039-four-implementation-stages.md)).

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [vision.md](../vision.md),
  [workflow.md §3](../../agent/workflow.md#3-design-work)
