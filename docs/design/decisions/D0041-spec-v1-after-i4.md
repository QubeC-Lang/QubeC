# D0041: Spec v1.0 is published only after I4

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

When may Spec v1.0 be published? v1.0 freezes the specification: after it, a change is a versioned change to a
published specification, with compatibility costs, rather than a revisit. The features hardest to get right (memory
in M07, concurrency in M10, metaprogramming in M11, interop in M12) are designed late. The answer decides whether any
implementation, and any large real program, has exercised them before they freeze. Once QubeC self-hosts, every
release needs both implementations to pass the whole conformance suite
([D0029](D0029-permanent-host-implementation.md)).

## Options considered

The scenario for every option: while `qubecc` is being written, its code generator turns out to need a borrowing
pattern that M07's rules reject. Is that a revisit before v1.0, or a change after it?

### A. After the design milestones

M17 depends on M13, M14, and M15.

- **Easy:** the earliest v1.0, and a frozen target for the implementation.
- **Hard:** M10–M12 freeze before any implementation has them; the scenario's problem is a change after v1.0.
- **Prior art:** Algol 68; C++'s `export` templates, standardized before implementations and later removed
  (recalled, [R0006](../research/R0006-planning-prior-art.md)).

### B. After the host implementation implements the whole specification

M17 depends on M13, M14, M15, and the host implementation passing the whole conformance suite.

- **Easy:** every feature has run in one implementation before it freezes.
- **Hard:** no program the size of a compiler has used the late features yet; the scenario's problem is found by
  `qubecc`, after v1.0.

### C. After I4

Both implementations implement the whole specification, and `qubecc` self-hosts
([D0039](D0039-four-implementation-stages.md)).

- **Easy:** the specification freezes only after two independent implementations and one large real program, the
  compiler itself, have exercised everything; the scenario's problem is a revisit before v1.0. From v1.0 on, D0029's
  release rule holds for every release.
- **Hard:** the latest v1.0; it depends on implementation progress.
- **Prior art:** Python marks a PEP Final only once its reference implementation is complete (verified, R0006);
  Rust 1.0 came four years after rustc first compiled itself (recalled, R0006).

| | A After design | B After the host is complete | C After I4 |
| --- | --- | --- | --- |
| Late features run before freezing | no | in one implementation | in two, and used by `qubecc` |
| The scenario's problem | after v1.0 | after v1.0 | revisit before v1.0 |
| v1.0 timing | earliest | middle | latest |

Recommendation at the time: **C**, because nothing pushes toward an early v1.0 and only C turns the scenario's
problem into a revisit rather than a breaking change.

## Choice

**C.**
1. Spec v1.0 is published only after I4 has exited. M17 (final review and Spec v1.0) depends on M13, M14, M15, and
   I4.
2. Before v1.0, draft versions of the specification may be tagged 0.x. A draft carries no compatibility promise.

## Rationale

The features most likely to need correcting are designed last, and the best test of them is a second implementation
and a large real program. Nothing calls for an early v1.0: no users depend on a frozen specification, and drafts can
be tagged along the way. Waiting until after I4 means a problem `qubecc` finds is still a revisit.

## Consequences

- **M17** depends on I4 and so on implementation progress.
- **Draft tags (0.x)** may be made at any milestone's close; how they are named and announced is left to M17's
  release planning.
- **Revisits** remain the way to change a decision until v1.0 is published; after it, how a published specification
  changes is M17's to plan.

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [vision.md](../vision.md)
