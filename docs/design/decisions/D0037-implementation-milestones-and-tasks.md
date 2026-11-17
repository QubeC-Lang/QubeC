# D0037: Implementation milestones I1, I2, … with tasks in the shared series; one Active task per track

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

How does implementation work appear in the roadmap and the tracker? The workflow so far is built for design: a task
is one bounded sub-topic, run by explaining options, asking, and recording, and the tracker names exactly one Active
task. Implementation work runs **in parallel** with design ([D0036](D0036-trailing-implementation-track.md)), and
has a different shape: tests, code, and conformance results. This record decides how implementation milestones are
identified, whether their work is planned as tasks, and how the "one Active task" rule applies to two tracks.

## Options considered

The scenario for every option: M03 is being designed while the scanner (implementing M02) is being written. What do
the roadmap and the tracker say?

### A. Implementation milestones `I1`, `I2`, … with tasks in the shared T series

Implementation milestones get their own prefix, their own exit criteria, and tasks numbered in the same series as
design tasks.

```
roadmap.md
  I1 Front end and core interpreter
     T0020 scanner        Active
     T0021 parser         Planned
tracker.md
  | Active task | T0020 (I1): scanner |
```

- **Easy:** one uniform system: every piece of work, design or implementation, has a task number, a log row, and a
  roadmap status.
- **Hard:** with "exactly one Active task", the scanner task and M03's design task cannot be Active at the same time,
  which contradicts D0036's parallel tracks unless the rule changes. Coding work does not fit the design task steps.
- **Prior art:** none checked; the option is about our own records rather than the language.

### B. Implementation milestones with scope and exit criteria, but no tasks for coding

Implementation milestones are listed with what they build and their exit criteria. The step-by-step work is tracked
by the code itself (commits, tests, conformance results). Only design questions that implementation raises
(architecture, formats) become tasks.

```
roadmap.md
  I1 Front end and core interpreter
     implements: M01 M02 M03 M04 M05
tracker.md
  | Active task    | T0012 (M03): operators |
  | Implementation | I1: M02 implemented; M03 not yet |
```

- **Easy:** design and implementation never compete for the Active slot; no bookkeeping duplicates the code
  history.
- **Hard:** implementation progress is coarse in the design documents.

### C. Continue the M series (M18, M19, …) with a "Kind" field

```
order: M01 M02 → M18 (Kind: implementation) → M03 M04 …
```

- **Easy:** no new kind of ID.
- **Hard:** M-numbers stop following the order of the work, and every citation needs the Kind field to be read.

Recommendation at the time: **B**, because coding overlaps design under D0036, and B is the only option that leaves
the one-Active-task rule unchanged.

### Follow-up: how the tracks share the "one Active task" rule

With A chosen, the rule had to change. The options, in the same scenario:

- **One Active task per track:** the tracker names one Active design task and one Active implementation task, and
  its single next action is the design track's.
- **One Active task overall:** the tracks take turns, and design waits while a coding task is Active. This reverses
  D0036's "design never waits".
- **Implementation tasks logged but never Active:** they have numbers, log rows, and roadmap statuses, but the
  tracker's Active field always means design. A fresh session sees the coding task only in the roadmap.

Recommendation at the time: **one Active task per track**, the only option that keeps both D0036 and A, and shows the
coding task in the tracker's status table.

## Choice

**A, with one Active task per track.**
1. **Identifiers.** Implementation milestones use the prefix `I` and are numbered in creation order (`I1`, `I2`, …).
   An `I` number is never reused. Design milestones keep their `M` numbers.
2. **Tasks.** Implementation work is planned as tasks in the same series as design tasks (`T0001`, … in creation
   order), each one bounded piece of one implementation milestone. Task statuses are the same: Planned, Active,
   Done, Dropped.
3. **One Active task per track.** The tracker names at most one Active design task and at most one Active
   implementation task. The tracker's single next action names the next design step.
4. **Implementation tasks** state what they build, the spec sections and decisions they implement, and the tests
   that must pass. A task is Done when those tests pass and every divergence it found is resolved or logged
   ([D0039](D0039-four-implementation-stages.md), P5). How implementation tasks are run in full is decided by I1's
   opening task ([D0038](D0038-m16-merged-into-implementation-milestones.md)).
5. Design questions that implementation raises (an architecture, a format) are design tasks, run with the design
   task steps, inside the implementation milestone that needs them.

## Rationale

We want every piece of work to have a task number, a log row, and a roadmap status, so that the project's history
reads in one place whether the work was design or implementation. That uniformity is worth changing the
one-Active-task rule to one per track. Doing so keeps the parallel tracks of D0036, and a fresh session sees both
the design task and the coding task in the tracker's status table.

## Consequences

- **The workflow** ([workflow.md §3](../../agent/workflow.md#3-design-work), `CLAUDE.md`, the roadmap's header, the
  tracker's status table): "exactly one Active task" becomes "at most one Active task per track", and milestones
  include implementation milestones.
- **Task numbers interleave** across the tracks (for example T0015 for M03, T0016 for I1). They remain in creation
  order.
- **I1's opening task** decides how implementation tasks are run: their steps, their records, and their tests.

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [tracker.md](../tracker.md),
  [workflow.md §3](../../agent/workflow.md#3-design-work), [`CLAUDE.md`](../../../CLAUDE.md)
