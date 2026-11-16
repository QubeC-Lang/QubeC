# Glossary

Every term the specification and design documents define, in alphabetical order, with a link to where it is
defined. A term is added in the same change that defines it.

| Term | Meaning | Defined in |
| --- | --- | --- |
| Algebraic data type (ADT) | A type defined as a choice of variants, each of which may carry data, e.g. `Num(value: Int) \| Var(name: Str)`. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Async colouring | The way an `async` function can be called only from another `async` function, so the "colour" spreads through the call graph. | [D0006](design/decisions/D0006-inspirations.md) |
| Binding | A name for a value, introduced by `let`; immutable unless declared mutable. | [D0009](design/decisions/D0009-immutable-bindings.md) |
| Callable | A function or a procedure. | [D0008](design/decisions/D0008-purity.md) |
| Constant | A top-level or local `const` with a required type, evaluated at compile time; it may call only functions. | [D0009](design/decisions/D0009-immutable-bindings.md) |
| Decided | A design state: the matter has an accepted decision record. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Decision record | A file `docs/design/decisions/Dnnnn-<slug>.md` recording one decision: the question, the options, the choice, the rationale, and the consequences. | [workflow.md §3](agent/workflow.md#recording-rules) |
| Default layer | The part of QubeC that everyday code uses, judged by Safety > Simplicity > Ergonomics > Predictability > Performance. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Effect | Anything a pure function may not do: IO, mutation of state it did not create, nondeterminism, spawning or using channels, calling a procedure. | [D0008](design/decisions/D0008-purity.md) |
| Exhaustive match | A `match` that the compiler checks covers every possible case. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Explicit layer | The opt-in, still safe forms of QubeC (sized integers, borrowed slices and references, explicit casts), judged by Safety > Performance > Predictability. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Function | A callable declared with `func`; it is pure. | [D0008](design/decisions/D0008-purity.md) |
| Growable stack | A call stack that is enlarged on demand up to a large cap, instead of having a small fixed size. | [D0012](design/decisions/D0012-tail-calls-and-stacks.md) |
| Immutable collection | A collection that never changes; an update returns a new version sharing structure with the old one (also called persistent). | [D0010](design/decisions/D0010-mutable-default-collections.md) |
| Intuitive name | A name QubeC provides that most programmers read correctly without context: a widely recognized short form, a familiar acronym, or a whole word. | [D0007](design/decisions/D0007-intuitive-names.md) |
| Milestone | One design area (M00, M01, …) with exit criteria. | [workflow.md §3](agent/workflow.md#milestones-and-tasks) |
| Monad | A type such as `IO a` ("a computation that yields an `a`") with a way to chain such computations; QubeC does not encode effects this way (NG-5). | [D0005](design/decisions/D0005-non-goals.md) |
| Non-goal | A property QubeC deliberately does not have, recorded as NG-n; changing one needs a superseding decision. | [D0005](design/decisions/D0005-non-goals.md) |
| Open | A design state: the matter is not decided and nothing depends on a guess about it. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Open question | An undecided matter that something is waiting on, recorded as OQ-nnn. | [open-questions.md](design/open-questions.md) |
| Persistent data structure | An immutable collection where an update returns a new version that shares structure with the old one. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Procedure | A callable declared with `proc`; it may have effects. | [D0008](design/decisions/D0008-purity.md) |
| Provisional | A design state: a rule or example depends on an open question, and is marked with its OQ ID. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Pure | Of a function: calling it does nothing observable besides returning a value (debug output excepted). | [D0008](design/decisions/D0008-purity.md) |
| Purity parameter | A variable standing for "pure or effectful" in a function type, so that a higher-order function takes the purity of its function arguments. | [D0008](design/decisions/D0008-purity.md) |
| REPL | A read-eval-print loop: an interactive prompt that evaluates declarations and expressions one at a time. | [D0013](design/decisions/D0013-easy-start.md) |
| Research note | A file `docs/design/research/Rnnnn-<slug>.md` recording verified findings that a decision relies on. | [research/README.md](design/research/README.md) |
| Self-hosting yardstick | The tie-breaking test "could QubeC's own compiler be written comfortably in this?". | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Strict evaluation | Call-by-value: arguments are evaluated before a call, not on demand. | [D0005](design/decisions/D0005-non-goals.md) |
| Tail call | A call that is the last action of a function; a call marked `tailcall` replaces the caller's frame and runs in constant stack. | [D0012](design/decisions/D0012-tail-calls-and-stacks.md), [D0014](design/decisions/D0014-tailcall-keyword.md) |
| Task | One bounded sub-topic of one milestone (T0001, …), normally one session. | [workflow.md §3](agent/workflow.md#milestones-and-tasks) |
| Tie-breaking domain | The kind of program whose needs win when design goals conflict; for QubeC, tooling. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Undefined behaviour (UB) | An operation the language gives no meaning, so that anything may happen; QubeC excludes it from safe code. | [D0004](design/decisions/D0004-ranked-design-values.md) |
