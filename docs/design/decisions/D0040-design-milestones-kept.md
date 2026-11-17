# D0040: The design milestones are kept as drafted, with corrected dependencies and scopes

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

The design milestones M01–M17 were drafted in T0001, before the vision existed. Since then:
- T0003 decided purity ([D0008](D0008-purity.md)), bindings ([D0009](D0009-immutable-bindings.md)), and tail calls
  ([D0012](D0012-tail-calls-and-stacks.md)) at the vision level, so M08, M04, and M03 now refine rather than decide
  them;
- the explicit layer ([D0004](D0004-ranked-design-values.md),
  [OQ-003](../open-questions.md#oq-003-how-is-the-explicit-layer-marked-and-how-do-default-integers-relate-to-sized-ones))
  spans M05 (numeric model, marking) and M07 (borrowed references);
- the implementation stage I2 needs the core library (M14) before M10 is designed
  ([D0039](D0039-four-implementation-stages.md)), but M14 was drafted to depend on M06–M10;
- M15 (tooling) can run alongside I2 and I3;
- M16 is merged into I1–I3 ([D0038](D0038-m16-merged-into-implementation-milestones.md)).

Do any design milestones move, merge, or drop?

## Options considered

Every option includes these **dependency and scope fixes**: (a) M14 depends on M06–M09; (b) M05 does not wait for
M07; (c) M08's scope reads "errors and effect mechanics"; (d) M15 depends on M09 and M14 and may run alongside I2
and I3. The scenario for every option: the resulting design order.

### A. The fixes only

```
M00 → M01 → M02 → M03 → M04 → M05 → M06 → M07 → M08 → M09 → M14
      → M10 · M11 · M12 · M15 → M13 → M17
```

- **Easy:** every milestone stays one area of bounded size; the drafted numbers and citations stay valid.
- **Hard:** M03 and M04 touch each other (`let` is both a statement and a binding; patterns bind names), so M03 uses
  binding syntax provisionally and M04 decides scoping.

### B. The fixes, and merge M03 and M04

```
M00 → M01 → M02 → M03 (expressions and statements + names, bindings, scope) → M05 → …
M04: Dropped (merged into M03)
```

- **Easy:** no provisional overlap between expressions and bindings.
- **Hard:** one very large milestone, which is also where the Lean package starts
  ([D0028](D0028-mechanization-starts-in-m03.md)); the parser and name resolution in I1 wait longer.

### C. The fixes, and a new explicit-layer milestone after M07

```
… M05 (default numerics only) → M06 → M07 → (new) Explicit layer
      (sized integers, casts, marking, borrowed references: all of OQ-003) → M08 …
```

- **Easy:** the layer of D0004 is designed as one coherent area.
- **Hard:** one more milestone; M05's numeric model stays incomplete, so I1's type checker initially knows only the
  default numeric types.

Recommendation at the time: **A**, because the M03/M04 overlap is small and well understood, and OQ-003 already
splits the explicit layer cleanly between M05 and M07.

## Choice

**A.** No design milestone moves, merges, or drops, other than M16 (D0038). The dependency and scope fixes:
1. **M14** (standard library and prelude) depends on M06–M09, not M06–M10. M10 adds its own library surface when it
   runs.
2. **M05** does not wait for M07. M05 decides the numeric model, including sized integers and how the explicit layer
   is marked (OQ-003's M05 part); M07 decides borrowed references and the unsafe escape hatch.
3. **M08**'s scope is errors and the mechanics of effects, refining [D0008](D0008-purity.md). Likewise M04 refines
   [D0009](D0009-immutable-bindings.md), and M03 refines [D0012](D0012-tail-calls-and-stacks.md) and
   [D0014](D0014-tailcall-keyword.md).
4. **M15** (tooling) depends on M09 and M14, and may run alongside I2 and I3.
5. **M17** depends on M13, M14, M15, and I4 ([D0041](D0041-spec-v1-after-i4.md)).
6. **M13** stays. Continuous mechanization ([D0024](D0024-mechanize-the-core.md)) makes it smaller; it still
   promotes aspects to formally complete and finishes the paper proofs.

## Rationale

Each drafted milestone is one design area of a size a few tasks can cover, and every one of them serves the vision.
The overlaps we found are small and already have homes: M03 uses binding syntax provisionally for M04, and OQ-003
names which part of the explicit layer belongs to M05 and which to M07. A merge or a new milestone would cost more
than the overlap it removes.

## Consequences

- **The roadmap's overview** shows the corrected dependencies, M16 as Dropped, and the implementation milestones.
- **M03:** its first tasks write `let` and patterns in provisional binding syntax, pointing to M04.
- **M05:** decides OQ-003's numeric and marking parts without waiting for M07.

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [workflow.md §3](../../agent/workflow.md#3-design-work)
