# D0038: M16 is merged into I1–I3; each implementation milestone opens with its own design tasks

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

M16 (Implementation plan) was drafted as one design milestone near the end of the plan: pipeline, IRs,
bootstrapping toward self-hosting, and the conformance suite. With implementation trailing the design from M02
([D0036](D0036-trailing-implementation-track.md)), its contents are needed at very different times:

| M16 item | Needed when |
| --- | --- |
| the host interpreter's architecture, code layout, conformance harness, dependency table ([D0035](D0035-pinned-toolchains-and-recorded-libraries.md)) | as soon as implementation starts |
| the core interchange format ([OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)) | when core first crosses a boundary (to the Lean reference or the host compiler) |
| the bytecode format ([OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)), the host compiler's and host VM's architecture | before the host compiler and VM are built |
| `qubecc`'s pipeline and IRs, the fixpoint procedure, the release checks ([D0029](D0029-permanent-host-implementation.md)) | before `qubecc` is written |
| the plan after Spec v1.0 | at the end |

What happens to M16?

## Options considered

The scenario for every option: where are the core interchange format and `qubecc`'s IR decided? The implementation
stages referred to are those of [D0039](D0039-four-implementation-stages.md).

### A. Merge M16 into the implementation milestones

Each implementation milestone opens with design tasks for what it is about to build. The plan after v1.0 moves to
M17. M16 is dropped, and its number is never reused.

```
I1 opens: host-interpreter architecture, code layout, conformance harness start
I2 opens: OQ-008 core interchange format, OQ-009 bytecode format,
          compiler and VM architecture
I3 opens: qubecc architecture (designed fresh, D0034), fixpoint and release checks
M16: Dropped (merged into I1–I3)      M17: + the plan after v1.0
```

- **Easy:** each architecture is decided just before it is built, with what the previous stage taught. One milestone
  fewer.
- **Hard:** no single milestone holds the whole implementation picture.

### B. Keep M16 as a design milestone, before the host compiler and VM

```
M01 … M05 → M16 → M06 …
  M16: OQ-008, OQ-009, compiler and VM architecture, qubecc pipeline and IRs
I1 decides its own architecture.
```

- **Easy:** one place for the back-end and `qubecc` design.
- **Hard:** `qubecc`'s IRs are designed before M06–M09 (polymorphism, memory, effects, modules) exist, and are
  likely to be revisited.

### C. Keep M16 whole, before implementation starts

```
M01 M02 → M16 → I1 starts, M03 …
```

- **Easy:** the whole architecture is decided up front.
- **Hard:** it delays the trailing track of D0036, and designs `qubecc` before even expressions exist.

| | A Merge into I1–I3 | B M16 before I2 | C M16 before I1 |
| --- | --- | --- | --- |
| Each architecture decided just before building it | yes | partly | no |
| `qubecc` designed after M06–M09 | yes | no | no |
| One place for the implementation plan | no | yes | yes |
| Fits D0036 | yes | yes | delays it |

Recommendation at the time: **A**, for the timing shown in the table.

## Choice

**A.**
1. **M16 is Dropped** (merged), and its number is never reused.
2. **I1 opens** with design tasks for the host interpreter's architecture and the code's repository layout, the
   start of the conformance harness and the dependency table of
   [D0035](D0035-pinned-toolchains-and-recorded-libraries.md), and how implementation tasks are run
   ([D0037](D0037-implementation-milestones-and-tasks.md)).
3. **I2 opens** with design tasks for the core interchange format (OQ-008), the bytecode format (OQ-009, after M01
   settles whether bytecode is visible to users), and the host compiler's and host VM's architecture. OQ-008 is
   decided earlier, in I1, if I1 is the first to send core across a boundary (for example to the Lean reference).
4. **I3 opens** with design tasks for `qubecc`'s architecture (designed fresh,
   [D0034](D0034-idiomatic-code-per-part.md)), which features `qubecc`'s own source uses, and the release procedure
   of [D0029](D0029-permanent-host-implementation.md) (build from source, fixpoint check, both implementations
   passing the conformance suite).
5. **M17** gains the plan for after Spec v1.0.
6. Earlier records that assign work to M16 ([D0002](D0002-purpose-and-domain.md),
   [D0013](D0013-easy-start.md), [D0018](D0018-diagnosis-and-rule-ids.md),
   [D0027](D0027-executable-reference.md), [D0029](D0029-permanent-host-implementation.md)–[D0035](D0035-pinned-toolchains-and-recorded-libraries.md))
   are read through items 2–5: host-interpreter matters go to I1, back-end matters to I2, `qubecc` and release
   matters to I3.

## Rationale

We merged M16 into the implementation milestones because each architecture is best decided just before it is built,
with what the previous stage taught us, and because it removes a milestone. `qubecc` in particular should be
designed after M06–M09 exist, not before.

## Consequences

- **The roadmap:** M16's section is marked Dropped with a pointer here; M17's scope gains the plan after v1.0.
- **OQ-008** moves from M16 to I2's opening task (or I1's, as in item 3). **OQ-009** keeps its M01 part; its format
  part moves from M16 to I2.
- **The conformance harness** starts in I1 (it was M15/M16's); M15 still designs the test framework users see.

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [open-questions.md](../open-questions.md),
  [workflow.md §3](../../agent/workflow.md#3-design-work)
