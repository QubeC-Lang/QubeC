# QubeC: Standing Instructions

QubeC is a new programming language, designed here from scratch. It is general-purpose, with some low-level,
systems-programming ability, and it aims to self-host eventually. The starting idea is a language that starts small
and is easy to use like Python, but is more strictly typed, not indentation-sensitive, and functional in style.
Source files use `.qbc`. The repository holds the design (decisions, open questions, research), a normative
specification with an EBNF grammar and formal semantics, a tour, examples, and later the implementation.

## The repo is the memory

Read [`docs/design/tracker.md`](docs/design/tracker.md) first, and never rely on chat history. The tracker is the only
authority on design progress: status, task log, exactly one next action, and a handoff.

## Milestones and tasks

- A **design milestone** (M00, M01, …) is one design area with exit criteria. An **implementation milestone** (I1,
  I2, …) is one stage of the implementation; it trails the design and never makes design wait (D0036, D0039). See
  [`docs/design/roadmap.md`](docs/design/roadmap.md).
- A **task** (T0001, …, numbered in creation order across both tracks) is one bounded sub-topic of one milestone. A
  session normally runs one task. Revisits and audits are tasks too. Statuses: Planned, Active, Done, Dropped. The
  tracker names at most one Active task per track (design, implementation), and one next action, for design
  (D0037). The steps below are for design tasks; I1's opening task decides how implementation tasks run.
- Three states, always kept apart: **Decided** (has a D record), **Provisional** (marked, and points to an open
  question), and **Open**.

## Task steps (condensed; full text in docs/agent/workflow.md, section 3)

1. **Orient:** read this file and the tracker, then only what the task needs. Recap in at most 8 lines.
2. **Frame:** goal, constraints from earlier decisions, in scope, deferred (and to where), what it unblocks.
3. **Explore:** about 5 to 10 questions, ONE at a time. Before each, explain every option in chat: how it works
   (walk-through and analogy, jargon defined), a 5 to 20 line example using the same scenario for every option,
   what it makes easy or hard (for users and for the implementation), what it locks in, prior art, and a
   recommendation (or "no recommendation" and why). Then ask with AskUserQuestion: 2 to 4 options with previews,
   "(Recommended)" first only with a stated reason, and "Explain more" when there are 3 or fewer real options. Never
   decide for the designer. Read the designer's code critically.
4. **Check claims:** verify against primary sources, say what was verified and what is recalled, save R notes, and
   test cheap claims in a scratch directory outside the repo.
5. **Synthesize:** one line per decision, plus one sample program that combines everything decided so far. Confirm
   or amend.
6. **Record:** D records, spec, grammar, formal rules, glossary, examples, tour, tracker (one next action and a
   handoff), roadmap, and the README status block.
7. **Verify:** links, glossary coverage, Provisional marks pointing to OQs, examples against the grammar, and
   milestone exit criteria.
8. **Close:** report the decisions, files, new OQs, and the next task. Ask about the commit. End by saying how to
   start the next task (`continue` here, or a new session + `continue`), recommending one. Then STOP.

Voice: human-oriented docs say "we" (the QubeC developers) and never quote chat verbatim. Only agent-oriented docs
(this file, `docs/agent/`, the tracker, templates) say "the designer" or "the agent".

## Keywords

- **continue:** run the next design task, as [`docs/agent/prompts/continue.md`](docs/agent/prompts/continue.md)
  describes.
- **pause:** stop partway. Save a handoff in the tracker (where we are, what is verified, exactly one next action),
  ask about the commit, and stop.

## Git

- Plain Conventional Commits 1.0.0: `<type>(<scope>): <imperative summary>`, with an optional body and nothing else.
  No task IDs in the header, and no Co-Authored-By or other AI-attribution trailers. Types: docs, feat, fix,
  refactor, test, perf, build, ci, chore. Scopes: spec, grammar, formal, design, examples, agent, or a code area.
- Commit only after the designer confirms, asking separately for each repository. Never push.
- Stage only the files changed for the task, by path. Never `git add -A`, `git add .`, or `git commit -a`. If a
  design task needs a file that has someone else's uncommitted changes, ask first.

## Pointers

- [`docs/agent/workflow.md`](docs/agent/workflow.md): the full workflow, with the design-task diagram.
- [`docs/design/tracker.md`](docs/design/tracker.md): status, task log, next action, handoff.
- [`docs/design/roadmap.md`](docs/design/roadmap.md): milestones, exit criteria, tasks.
- [`docs/spec/README.md`](docs/spec/README.md): specification conventions.
