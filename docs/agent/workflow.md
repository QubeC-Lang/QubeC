# QubeC Design Workflow

This is the full working agreement for designing QubeC. It is an agent-oriented document: "the designer" is the
person who makes every design decision, and "the agent" is the AI assistant that proposes, explains, drafts, and
records. [`CLAUDE.md`](../../CLAUDE.md) is the condensed version, loaded at the start of every session.

Contents:
1. [Project](#1-project)
2. [Repository layout](#2-repository-layout)
3. [Design work](#3-design-work)
4. [Git](#4-git)
5. [What CLAUDE.md must contain](#5-what-claudemd-must-contain)

## 1. Project

- Name: QubeC. Source files use the extension `.qbc`.
- Initial idea: mainly a general-purpose language, with some low-level, systems-programming ability, that can
  eventually self-host. It should start small and be easy to use like Python, but more strictly typed and not
  indentation-sensitive, and it should be functional in style. Everything else, including any further must-haves,
  is open for the Vision tasks.
- By the end, the repository contains:
  - A normative specification: numbered sections, RFC 2119 keywords, and every term defined before it is used.
  - A complete EBNF grammar (lexical and syntactic) in a standalone, machine-checkable file that the spec quotes.
  - Formal models: static semantics (typing judgments as named inference rules), dynamic semantics (operational
    semantics), a memory or concurrency model if needed, and the meta-properties we claim (such as type soundness)
    with proof sketches. Mechanized proofs come too, if we choose them.
  - A decision log, open questions, a glossary, a language tour, example programs, a conformance-test plan, an
    implementation plan, and the implementation itself.

## 2. Repository layout

Approved in T0001 ([D0001](../design/decisions/D0001-repository-layout.md)).

```
README.md                     what QubeC is · a short status block, refreshed after each task · links
CLAUDE.md                     short standing instructions
docs/
  agent/
    workflow.md               this file
    prompts/                  README.md · continue.md · revisit.md · audit.md
  design/
    tracker.md                the ONLY authority on design progress: status, task log, one next action, handoff
    roadmap.md                milestones with scope, dependencies, exit criteria, and their tasks with statuses
    vision.md                 one readable summary of purpose, users, values, non-goals, inspirations
    open-questions.md         OQ-nnn, Open and Decided
    decisions/                README.md (index) · Dnnnn-<slug>.md
    research/                 README.md (index) · Rnnnn-<slug>.md
    templates/                decision · open-question · research-note · spec-section
  spec/
    README.md                 conventions
    NN-<topic>.md             the normative sections
    grammar/qubec.ebnf        the grammar, source of truth
    formal/                   README.md (notation) · static.md · dynamic.md · metatheory.md
      lean/                   the Lean 4 mechanization of the core, a Lake package (from M03, D0028)
  guide/tour.md               the language tour
  glossary.md                 every defined term
examples/                     .qbc programs; README.md gives the header convention
tools/                        README.md (index) · grammar/ (the grammar checker, D0080, D0081)
tests/conformance/            later
```

## 3. Design work

### Milestones and tasks

- A design milestone (M00, M01, …) is one design area with exit criteria: its decisions recorded, its spec sections
  written, the grammar and formal rules updated, examples added, and no open question left that it was meant to
  settle.
- An implementation milestone (I1, I2, …) is one stage of the implementation, with a stage target and the common
  exit criteria P1–P6 listed in the roadmap ([D0039](../design/decisions/D0039-four-implementation-stages.md)). The
  implementation track starts once M01 and M02 have closed, implements only closed design milestones, and never makes
  design wait ([D0036](../design/decisions/D0036-trailing-implementation-track.md)).
- A task (T0001, …, numbered in creation order across both tracks) is ONE bounded sub-topic of ONE milestone. A
  session normally runs one task. Revisits and audits are tasks too.
- The roadmap lists each milestone's tasks with a status (Planned, Active, Done, or Dropped). The tracker names at
  most one Active task per track (design and implementation), and exactly one next action, which is the design
  track's ([D0037](../design/decisions/D0037-implementation-milestones-and-tasks.md)).
- The task steps below are for design tasks, including the design tasks that open each implementation milestone. An
  implementation task states what it builds, the spec sections and decisions it implements, and the tests that must
  pass; how implementation tasks are run in full is decided by I1's opening task.

Milestone plan (confirmed in T0007, D0036–D0041; the roadmap holds the current statuses and dependencies):

| ID | Milestone | Covers |
| --- | --- | --- |
| M00 | Vision and principles | purpose, users, ranked values, non-goals, inspirations, spec audience and formality level, how far to formalize and which proof assistant if mechanized (such as Rocq, Lean 4, Agda, or Isabelle), and the host language for the bootstrap implementation |
| M01 | Execution and compilation model | compiled, interpreted, or JIT; targets; how much runtime there is; the compile-time/run-time boundary; separate compilation |
| M02 | Lexical structure | encoding, identifiers, keywords, literals, comments, whitespace; the EBNF dialect |
| M03 | Expressions and statements | expression orientation, operators and precedence, blocks, control flow, patterns |
| M04 | Names, bindings, and scope | declarations, mutability, shadowing, name resolution |
| M05 | Core type system | primitives, the numeric model, products and sums, inference, subtyping, the core typing judgments |
| M06 | Abstraction and polymorphism | functions and closures, generics, traits or typeclasses, coherence, dispatch |
| M07 | Memory and resources | values vs references; ownership, GC, reference counting, or regions; an unsafe escape hatch; the undefined-behavior policy |
| M08 | Errors and effects | results, exceptions, panics; the mechanics of effects, refining the purity of D0008 |
| M09 | Modules and packages | units, imports, visibility, versioning, the build model |
| M10 | Concurrency | threads, tasks, async, actors; data-race freedom; the memory model |
| M11 | Compile-time evaluation and metaprogramming | constant evaluation, macros, reflection, attributes |
| M12 | Interop and platform | FFI, ABI, layout control, embedding |
| M13 | Formal consolidation | complete semantics, soundness statements and proof sketches, and mechanized proofs if chosen |
| M14 | Standard library and prelude | |
| M15 | Tooling | diagnostics, formatter, LSP, test framework, package manager, docs |
| M16 | Implementation plan | Dropped: merged into I1–I3 (D0038) |
| M17 | Final review and Spec v1.0 | a consistency audit, a rationale document, a changelog, the plan after v1.0; only after I4 (D0041) |

Implementation milestones (D0039):

| ID | Milestone | Covers |
| --- | --- | --- |
| I1 | Front end and core interpreter | the host interpreter (Rust) for M01–M05: scanner, parser, names, types, elaboration, the tree-walking interpreter, the REPL, the driver; opens with its architecture, the code layout, the conformance harness, and how implementation tasks run |
| I2 | Host complete for the core language | the host interpreter through M06–M09 and M14; the host compiler (OCaml) and host VM (Zig); opens with the core interchange and bytecode formats and their architecture |
| I3 | `qubecc` and the fixpoint | the self-hosted compiler, the fixpoint check, and the release checks; opens with `qubecc`'s architecture |
| I4 | The remaining features | M10–M12 in the host implementation, then in `qubecc` |

Formal rules accumulate in every milestone, not only in M13. Drop, merge, or reorder milestones when the vision
calls for it, and record each change as a decision. For the host-language and proof-assistant choices in M00, show
samples (a small AST and evaluator in each candidate host language, and a small typing rule with a lemma in each
candidate proof assistant), run small pilots where they are cheap, and let the designer choose.

### Task steps

1. **Orient.** Read `CLAUDE.md` and the tracker, then only the roadmap entry, decisions, spec sections, and open
   questions relevant to this task. Give the designer a recap of at most 8 lines.
2. **Frame.** State the goal, the earlier decisions that constrain it, what is in scope, what is deferred (and to
   where), and what this task unblocks.
3. **Explore** with the designer, ONE question at a time:
   - Explain before you ask. Never ask a choice question without the full explanation first. Before each choice
     question, write a self-contained explanation in chat (the question dialog may hide earlier text). For each
     option:
     - (a) what it is and how it works, step by step, with a concrete walk-through and an intuitive analogy (e.g.
       "an effect variable is to purity what a type variable is to types"), defining jargon the first time it
       appears. Concepts from functional programming and type theory (typeclasses, higher-kinded types, effect
       systems, monads) get extra concreteness, with comparisons to Rust, Kotlin, or Scala where they help;
     - (b) a code example of 5 to 20 lines, using the same scenario for every option and showing the tricky cases;
     - (c) what it makes easy or hard, for people writing QubeC and for implementing it (parser, type checker, code
       generation, formal rules);
     - (d) what it locks in or rules out later, including self-hosting;
     - (e) prior art, meaning which languages do this and how it went for them.

     End with a short comparison and the agent's recommendation with its reasons, or "no recommendation" and why.
     Remind the designer of any earlier decision the question builds on.
   - Then ask with the AskUserQuestion tool: one question per call, with 2 to 4 options. Each option's preview shows
     the same small example; each description gives a one-line trade-off. Mark "(Recommended)" first only when
     there is a stated reason. Include "Explain more" whenever there are 3 or fewer real options; otherwise, say in
     the question that the designer can type "explain more" under Other. Never decide for the designer.
   - Mix in open requests ("write how you'd express X"), and read the designer's code critically: what it implies,
     any ambiguity, any conflict with earlier decisions. When free text is needed, ask for it in short parts. If the
     designer picks "I'll type it" but no text arrives, ask again.
   - Aim for about 5 to 10 questions. If more are needed, split the rest into a new task.
4. **Check claims.** Verify facts against primary sources (language specs, papers), and say what was verified and
   what is recalled. Save substantial findings as R notes. Test cheap claims before recommending them, for example
   by running a grammar fragment through a parser generator, or a throwaway prototype in a scratch directory outside
   the repo.
5. **Synthesize.** Restate each decision in one line. Show one sample program that combines this task's decisions
   with all earlier ones. Name any tension, then ask once to confirm or amend.
6. **Record,** following the recording rules.
7. **Verify.** Re-read the changed files and check the links. Check that every new term is in the glossary and every
   Provisional mark points to an open question. Check the examples against the grammar where tooling exists. If the
   milestone is finishing, report each exit criterion as met or not met.
8. **Close.** Report the decisions (IDs), the files changed, the new open questions, and the next task. Ask about the
   commit as the final question. End by telling the designer how to start the next task: type `continue` in this
   session, or start a new session and type `continue` (or paste [`prompts/continue.md`](prompts/continue.md)).
   Recommend one; prefer a new session once the current one is long. Then STOP.

### Keywords

- **"continue"** means run the next design task as [`prompts/continue.md`](prompts/continue.md) describes.
- **"pause"** means stop partway: save a handoff in the tracker (where we are, what is verified, exactly one next
  action), ask about the commit, and stop.

### Diagram of a design task

```
 continue
   │
   ▼
 state check ── last task not closed, or design files (docs/, examples/) dirty? ──▶ report and ask
   │ ok (other uncommitted work, e.g. implementation in progress, is left untouched)
   ▼
 1 ORIENT      read CLAUDE.md + tracker + only what this task needs ─▶ recap (≤ 8 lines)
   ▼
 2 FRAME       goal · constraints from earlier decisions · in scope · deferred · unblocks
   ▼
 3 EXPLORE     ┌─▶ explain EVERY option first: how it works (walk-through + analogy) ·
   (5–10 ques- │   example (same scenario for all) · easy/hard · what it locks in · prior art ·
   tions, one  │   recommendation
   at a time)  │      ▼
               │   ask ONE question (options with previews; "Explain more"; "Other" for your own)
               │      ▼
               │   your answer ── "Explain more" ──▶ deeper explanation ──▶ ask again
               │      │ chosen / your own code (read critically: implications, conflicts)
               └──────┘ next question
   ▼
 4 CHECK       facts verified against specs/papers · cheap claims tested (e.g. parser generator)
   ▼
 5 SYNTHESIZE  one line per decision + one combined sample program ─▶ you confirm or amend
   ▼
 6 RECORD      decisions (Dnnnn) · spec · grammar · formal rules · glossary · examples · tour ·
               tracker (one next action + handoff) · roadmap · README status
   ▼
 7 VERIFY      consistency · links · glossary · examples vs grammar · milestone exit criteria
   ▼
 8 CLOSE       report ─▶ commit? (only this task's files, staged by path) ─▶ STOP

 pause (at any point) ─▶ handoff in the tracker ─▶ commit? ─▶ STOP
```

In words: every task starts with a state check and ends with a commit question and a stop. Steps 1–2 bound the
task; step 3 is the loop of explained questions; steps 4–7 turn the answers into checked, recorded documents.

### Interaction rules

- Keep recaps and reports short; option explanations are as long as the choice needs.
- Be a critical partner. Name concrete problems (ambiguity, unsoundness, poor ergonomics, implementation cost) with
  examples and prior art, then respect the designer's decision.
- Decisions must scale to the whole language. Check each one against every later milestone it touches, and say so
  if it forces a later milestone's hand.
- Keep three states apart: **Decided** (has a D record), **Provisional** (depends on an open question, and is marked
  as such), and **Open**. Never present a guess as decided, and never guess the designer's preferences; ask.
- Examples use the decided syntax. Undecided syntax is labeled "provisional syntax".

### Recording rules

- **Decision records** (`docs/design/decisions/Dnnnn-<slug>.md`, from the
  [template](../design/templates/decision.md)) hold: date; status (Accepted, or Superseded by Dnnnn); milestone and
  task; the question; every option with its explanation condensed but complete, and its sample code; the choice;
  the rationale, in the designer's words where they gave them; the consequences; and the affected spec sections,
  grammar rules, and formal rules. Keep the [index](../design/decisions/README.md) current.
- **Spec:** normative text with RFC 2119 keywords and numbered sections, each rule citing its decision IDs. Order
  sections by dependency. Label non-normative notes. Every chapter's status line carries its formal status (D0016);
  every rejection rule starts with its rule ID (D0018); static rules are declarative and dynamic behavior is
  numbered steps where order is observable (D0017); spelling is US English (D0020). The full conventions are in
  [spec §1.3](../spec/01-introduction.md#13-notation-and-conventions).
- **Grammar:** `docs/spec/grammar/qubec.ebnf` is the source of truth. The EBNF dialect is decided in M02; until then,
  use W3C-style EBNF marked provisional.
- **Formal rules:** Markdown with LaTeX math. Name every rule, explain its premises in prose, and list the judgment
  forms and metavariables at the top of each file. Elaboration rules (surface → core) live only in Markdown. Core
  rules are governed by their Lean 4 definitions in `docs/spec/formal/lean/`, and each Markdown core rule names its
  Lean counterpart (D0022, D0026). A milestone that changes core rules updates the mechanization before it exits
  (D0024).
- **Open questions:** OQ-nnn, giving the task where it arose, what is blocked on it, and the options. When decided,
  move it to the Decided section with a link to its D record.
- Keep the **glossary, examples, and tour** current whenever a feature becomes Decided.
- **Tracker:** the status table, a task-log row (ID, date, milestone, sub-topic, decisions, OQs, commit), exactly ONE
  next action, and a handoff that a fresh session can follow without the chat. Update the roadmap statuses and the
  README status block too.
- **Changing a decision:** write a new D record that supersedes the old one, which is kept, and propagate the change
  to every file that refers to it.
- **Voice:** never quote the designer's chat messages verbatim in any file or commit; summarize instead (code the
  designer writes may be kept as code). Human-oriented docs (decisions, vision, research, open questions, roadmap,
  spec, tour, glossary, README, examples, test and tool docs) say "we", as the QubeC developers: "we chose X because
  …", "the recommendation at the time". They never say "the designer chose" or "the agent's recommendation". Only
  agent-oriented docs (`CLAUDE.md`, `docs/agent/`, the tracker, templates) may say "the designer" and "the agent".
  Before committing, search the human-oriented docs for "designer", "agent's", and quoted chat text.

## 4. Git

- Commit messages: plain Conventional Commits 1.0.0, `<type>(<scope>): <imperative summary>`, with an optional body
  and nothing else. No task IDs in the header, and NO Co-Authored-By or other AI-attribution trailers. Types: `docs`
  (design and spec), `feat`, `fix`, `refactor`, `test`, `perf`, `build`, `ci`, `chore`. Scopes: `spec`, `grammar`,
  `formal`, `design`, `examples`, `agent`, or a code area.
- Commit only after the designer confirms, asking separately for each repository. Never push.
- Stage only the files changed for this task, by path. Never use `git add -A`, `git add .`, or `git commit -a`, so
  that other uncommitted work in the tree (such as implementation in progress) never ends up in a design commit. If
  a design task needs to edit a file that already has someone else's uncommitted changes, ask first.

## 5. What CLAUDE.md must contain

Under about 120 lines: a one-paragraph summary of QubeC; "the repo is the memory: read the tracker first, and never
rely on chat history"; milestones and tasks in brief; a condensed version of the task steps; the keywords
"continue" and "pause"; the public Git rules; and pointers to this file, the tracker, the roadmap, and
`docs/spec/README.md`.
