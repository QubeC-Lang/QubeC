# Glossary

Every term the specification and design documents define, in alphabetical order, with a link to where it is
defined. A term is added in the same change that defines it.

| Term | Meaning | Defined in |
| --- | --- | --- |
| Algebraic data type (ADT) | A type defined as a choice of variants, each of which may carry data, e.g. `Num(value: Int) \| Var(name: Str)`. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Async colouring | The way an `async` function can be called only from another `async` function, so the "colour" spreads through the call graph. | [D0006](design/decisions/D0006-inspirations.md) |
| Decided | A design state: the matter has an accepted decision record. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Decision record | A file `docs/design/decisions/Dnnnn-<slug>.md` recording one decision: the question, the options, the choice, the rationale, and the consequences. | [workflow.md §3](agent/workflow.md#recording-rules) |
| Default layer | The part of QubeC that everyday code uses, judged by Safety > Simplicity > Ergonomics > Predictability > Performance. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Exhaustive match | A `match` that the compiler checks covers every possible case. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Explicit layer | The opt-in, still safe forms of QubeC (sized integers, borrowed slices and references, explicit casts), judged by Safety > Performance > Predictability. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Intuitive name | A name QubeC provides that most programmers read correctly without context: a widely recognized short form, a familiar acronym, or a whole word. | [D0007](design/decisions/D0007-intuitive-names.md) |
| Milestone | One design area (M00, M01, …) with exit criteria. | [workflow.md §3](agent/workflow.md#milestones-and-tasks) |
| Monad | A type such as `IO a` ("a computation that yields an `a`") with a way to chain such computations; QubeC does not encode effects this way (NG-5). | [D0005](design/decisions/D0005-non-goals.md) |
| Non-goal | A property QubeC deliberately does not have, recorded as NG-n; changing one needs a superseding decision. | [D0005](design/decisions/D0005-non-goals.md) |
| Open | A design state: the matter is not decided and nothing depends on a guess about it. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Open question | An undecided matter that something is waiting on, recorded as OQ-nnn. | [open-questions.md](design/open-questions.md) |
| Persistent data structure | An immutable collection where an update returns a new version that shares structure with the old one. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Provisional | A design state: a rule or example depends on an open question, and is marked with its OQ ID. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Research note | A file `docs/design/research/Rnnnn-<slug>.md` recording verified findings that a decision relies on. | [research/README.md](design/research/README.md) |
| Self-hosting yardstick | The tie-breaking test "could QubeC's own compiler be written comfortably in this?". | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Strict evaluation | Call-by-value: arguments are evaluated before a call, not on demand. | [D0005](design/decisions/D0005-non-goals.md) |
| Task | One bounded sub-topic of one milestone (T0001, …), normally one session. | [workflow.md §3](agent/workflow.md#milestones-and-tasks) |
| Tie-breaking domain | The kind of program whose needs win when design goals conflict; for QubeC, tooling. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Undefined behaviour (UB) | An operation the language gives no meaning, so that anything may happen; QubeC excludes it from safe code. | [D0004](design/decisions/D0004-ranked-design-values.md) |
