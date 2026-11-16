# D0001: Repository layout and design-process structure

| Field | Value |
| --- | --- |
| Date | 2026-11-15 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0001 |

## Question

Where does each kind of design artifact live, so that every later task knows where to read and write? The layout
has to hold decisions, open questions, research, a normative spec with a standalone grammar and formal rules, a
tour, a glossary, examples, and later conformance tests and the implementation.

## Options considered

### A. The base layout

- `README.md` and `CLAUDE.md` at the root.
- `docs/agent/` for the workflow and its prompts.
- `docs/design/` for the tracker, roadmap, open questions, `decisions/`, `research/`, and `templates/`.
- `docs/spec/` for numbered chapters, `grammar/qubec.ebnf`, and `formal/`.
- `docs/guide/tour.md` and `docs/glossary.md`.
- `examples/`, and later `tests/conformance/`.

The vision lives only in its separate decision records.

- **Easy:** few files; nothing to keep in step.
- **Hard:** reading the vision means reading several decision records; formal files have no shared notation page.

### B. The base layout plus three small additions

Everything in A, plus:
- `docs/design/vision.md`: one readable summary of purpose, users, values, non-goals, and inspirations, linking each
  part to its decision record;
- `docs/spec/formal/README.md`: one page of shared notation (judgment forms, metavariables, rule naming), with
  `static.md`, `dynamic.md`, and `metatheory.md` started as skeletons;
- `examples/README.md`: the header convention for example programs (which decisions each file exercises).

- **Easy:** later decisions cite the vision in one place; formal files stay consistent from the first rule.
- **Hard:** `vision.md` must be kept in step with its decision records.

### C. A different layout

Any other arrangement, added, renamed, or removed by hand.

Recommendation at the time: **B**. The additions are cheap, every later task uses them, and none of them is a
design decision about the language.

## Choice

**B.** The layout is recorded in [workflow.md, section 2](../../agent/workflow.md#2-repository-layout).
`tools/` is created when the grammar checker is decided (M02), and `tests/conformance/` when conformance tests
start. No license file yet.

## Rationale

We accepted the proposed layout with the three additions, for the reasons in the recommendation.

## Consequences

- `docs/design/tracker.md` is the only authority on design progress.
- Each vision task updates `vision.md` along with its decision records.
- Every formal file follows `docs/spec/formal/README.md`.

## Affected artifacts

- Spec: [`docs/spec/README.md`](../../spec/README.md) (conventions)
- Grammar rules: none
- Formal rules: none ([`formal/README.md`](../../spec/formal/README.md) created)
- Examples / tour: [`examples/README.md`](../../../examples/README.md) created
