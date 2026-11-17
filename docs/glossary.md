# Glossary

Every term the specification and design documents define, in alphabetical order, with a link to where it is
defined. A term is added in the same change that defines it.

| Term | Meaning | Defined in |
| --- | --- | --- |
| Abstract machine | A small-step dynamic semantics whose states carry an explicit stack (continuation), so that stack use can be stated and bounded; the style of QubeC's core dynamics. | [D0023](design/decisions/D0023-claimed-meta-properties.md) |
| Algebraic data type (ADT) | A type defined as a choice of variants, each of which may carry data, e.g. `Num(value: Int) \| Var(name: Str)`. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Async coloring | The way an `async` function can be called only from another `async` function, so the "color" spreads through the call graph. | [D0006](design/decisions/D0006-inspirations.md) |
| Binding | A name for a value, introduced by `let`; immutable unless declared mutable. | [D0009](design/decisions/D0009-immutable-bindings.md) |
| Bytecode | The instruction format that the host compiler produces and the host VM runs (format open, OQ-009). | [D0030](design/decisions/D0030-three-part-host.md) |
| C ABI | The calling convention and data layout of C on a platform, which almost every language can call and be called through. | [D0033](design/decisions/D0033-zig-host-vm.md) |
| Callable | A function or a procedure. | [D0008](design/decisions/D0008-purity.md) |
| Conforming implementation | An implementation that meets every requirement the specification places on implementations. | [§1.2](spec/01-introduction.md#12-conformance) |
| Conforming program | A program that violates no rejection rule and uses no extension. | [§1.2](spec/01-introduction.md#12-conformance) |
| Constant | A top-level or local `const` with a required type, evaluated at compile time; it may call only functions. | [D0009](design/decisions/D0009-immutable-bindings.md) |
| Core | The explicitly typed internal language into which elaboration translates every accepted program; the dynamic semantics is defined over it. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0022](design/decisions/D0022-typed-elaboration-into-core.md) |
| Core library | The types, values, and functions on which a rule of the language depends (such as the type `?` requires); specified normatively, unlike the rest of the standard library. | [§1.1](spec/01-introduction.md#11-scope), [D0015](design/decisions/D0015-spec-audience-and-scope.md) |
| Core rule | A formal rule of the core's typing or dynamics; its Lean definition governs it. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0026](design/decisions/D0026-lean-governs-core-rules.md) |
| De Bruijn index | A way to represent a bound variable by the number of binders between it and its own binder, instead of by name. | [D0028](design/decisions/D0028-mechanization-starts-in-m03.md), [OQ-007](design/open-questions.md#oq-007-how-does-the-mechanized-core-represent-binders) |
| Decided | A design state: the matter has an accepted decision record. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Decision record | A file `docs/design/decisions/Dnnnn-<slug>.md` recording one decision: the question, the options, the choice, the rationale, and the consequences. | [workflow.md §3](agent/workflow.md#recording-rules) |
| Default layer | The part of QubeC that everyday code uses, judged by Safety > Simplicity > Ergonomics > Predictability > Performance. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Definitional interpreter | An ordinary, runnable function together with a proof that it agrees with a semantics given as rules; running it is running the specification. | [D0027](design/decisions/D0027-executable-reference.md) |
| Design track | The sequence of design milestones (M00, M01, …), which decide the language and write the specification. | [D0036](design/decisions/D0036-trailing-implementation-track.md) |
| Differential testing | Running the same program through two implementations (such as the reference and a compiler) and comparing their answers. | [D0027](design/decisions/D0027-executable-reference.md) |
| Diverse double-compiling | Compiling a compiler's source with two independent compilers and comparing the results, to detect a backdoor planted in a compiler binary. | [D0029](design/decisions/D0029-permanent-host-implementation.md) |
| Dynamic semantics | What an accepted program does when it runs. | [§1.1](spec/01-introduction.md#11-scope) |
| Effect | Anything a pure function may not do: IO, mutation of state it did not create, nondeterminism, spawning or using channels, calling a procedure. | [D0008](design/decisions/D0008-purity.md) |
| Elaboration | The translation of a surface program into the core, performed by the elaboration rules while checking legality. | [D0022](design/decisions/D0022-typed-elaboration-into-core.md) |
| Elaboration rule | A formal rule over the surface language, of the form Γ ⊢ e : τ ⇝ c, that states a legality condition and produces a core term. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0022](design/decisions/D0022-typed-elaboration-into-core.md) |
| Exhaustive match | A `match` that the compiler checks covers every possible case. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Explicit layer | The opt-in, still safe forms of QubeC (sized integers, borrowed slices and references, explicit casts), judged by Safety > Performance > Predictability. | [D0004](design/decisions/D0004-ranked-design-values.md) |
| Explicitly typed | Of a language such as the core: every binder, type instantiation, and purity instantiation is written in the term, so checking needs no inference. | [D0022](design/decisions/D0022-typed-elaboration-into-core.md) |
| Extension | A feature an implementation provides that the specification does not define; it takes effect only in a file with an extension opt-in. | [§1.2.3](spec/01-introduction.md#123-extensions), [D0019](design/decisions/D0019-extensions-by-source-opt-in.md) |
| Extension opt-in | A declaration in a source file that names an extension (syntax open, OQ-006). | [§1.2.3](spec/01-introduction.md#123-extensions) |
| Fixpoint check | The test that self-hosting works: the self-hosted compiler, compiled by itself twice in succession, produces identical output. | [D0029](design/decisions/D0029-permanent-host-implementation.md) |
| Formal status | A chapter's statement, for its static and for its dynamic semantics, of how far the formal rules cover it: complete, partial, or none. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0016](design/decisions/D0016-authority-per-section.md) |
| Formal target | The part of QubeC that the formal rules and theorems cover, and so the only part that can be formally complete: the whole sequential language. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0021](design/decisions/D0021-formal-target-sequential-language.md) |
| Formally complete | Of an aspect of a chapter: its formal status is complete, so the formal rules govern it. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority) |
| Frame property | Of a `func` call: every value that existed before the call is unchanged after it. | [D0023](design/decisions/D0023-claimed-meta-properties.md) |
| Fuel | A step budget given to the reference evaluator; running out of fuel means the run is inconclusive, never that it is wrong. | [D0027](design/decisions/D0027-executable-reference.md) |
| Function | A callable declared with `func`; it is pure. | [D0008](design/decisions/D0008-purity.md) |
| Growable stack | A call stack that is enlarged on demand up to a large cap, instead of having a small fixed size. | [D0012](design/decisions/D0012-tail-calls-and-stacks.md) |
| Host compiler | The part of the host implementation, written in OCaml, that lowers the typed core to bytecode; it makes no rejections. | [D0030](design/decisions/D0030-three-part-host.md), [D0032](design/decisions/D0032-ocaml-host-compiler.md) |
| Host implementation | The permanent implementation of QubeC written in existing languages; it leads every feature. Its parts are the host interpreter, the host compiler, and the host VM. | [D0029](design/decisions/D0029-permanent-host-implementation.md), [D0030](design/decisions/D0030-three-part-host.md) |
| Host interpreter | The part of the host implementation, written in Rust, that holds the front end, a tree-walking interpreter of the core, the REPL, and the driver; it makes every rejection. | [D0030](design/decisions/D0030-three-part-host.md), [D0031](design/decisions/D0031-rust-host-interpreter.md) |
| Host VM | The part of the host implementation, written in Zig, that runs bytecode: the interpreter loop, heap and garbage collector, stacks, panics, and native library functions, as a C-ABI library. | [D0030](design/decisions/D0030-three-part-host.md), [D0033](design/decisions/D0033-zig-host-vm.md) |
| Immutable collection | A collection that never changes; an update returns a new version sharing structure with the old one (also called persistent). | [D0010](design/decisions/D0010-mutable-default-collections.md) |
| Implementation milestone | One stage of the implementation (I1, I2, …), with a stage target and the common exit criteria P1–P6. | [D0037](design/decisions/D0037-implementation-milestones-and-tasks.md), [D0039](design/decisions/D0039-four-implementation-stages.md) |
| Implementation track | The sequence of implementation milestones; it trails the design track, implementing only closed design milestones, and never makes design wait. | [D0036](design/decisions/D0036-trailing-implementation-track.md) |
| Intuitive name | A name QubeC provides that most programmers read correctly without context: a widely recognized short form, a familiar acronym, or a whole word. | [D0007](design/decisions/D0007-intuitive-names.md) |
| Logical relation | A family of relations, defined type by type, stating when two values or programs behave the same; the usual tool for proving relational properties such as referential transparency. | [D0023](design/decisions/D0023-claimed-meta-properties.md) |
| Mechanization | The core's rules and proofs written in a proof assistant (Lean 4), in `docs/spec/formal/lean/`. | [D0024](design/decisions/D0024-mechanize-the-core.md), [D0025](design/decisions/D0025-lean-4.md) |
| Meta-property | A theorem about the language rather than in it, such as type soundness. | [D0023](design/decisions/D0023-claimed-meta-properties.md) |
| Milestone | One design area (a design milestone, M00, M01, …) or one stage of the implementation (an implementation milestone, I1, I2, …), with exit criteria. | [workflow.md §3](agent/workflow.md#milestones-and-tasks), [D0037](design/decisions/D0037-implementation-milestones-and-tasks.md) |
| Monad | A type such as `IO a` ("a computation that yields an `a`") with a way to chain such computations; QubeC does not encode effects this way (NG-5). | [D0005](design/decisions/D0005-non-goals.md) |
| Non-goal | A property QubeC deliberately does not have, recorded as NG-n; changing one needs a superseding decision. | [D0005](design/decisions/D0005-non-goals.md) |
| Open | A design state: the matter is not decided and nothing depends on a guess about it. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Open question | An undecided matter that something is waiting on, recorded as OQ-nnn. | [open-questions.md](design/open-questions.md) |
| Persistent data structure | An immutable collection where an update returns a new version that shares structure with the old one. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Pinned toolchain | A compiler or prover version fixed in a file in the repository and changed only by a deliberate, separate change. | [D0035](design/decisions/D0035-pinned-toolchains-and-recorded-libraries.md) |
| Procedure | A callable declared with `proc`; it may have effects. | [D0008](design/decisions/D0008-purity.md) |
| Promotion | The recorded decision that makes an aspect of a chapter formally complete, after a checklist is met. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0016](design/decisions/D0016-authority-per-section.md) |
| Proof assistant | A program that checks proofs, in which rules are written as definitions and a theorem is accepted only when every case is handled. | [D0024](design/decisions/D0024-mechanize-the-core.md) |
| Provisional | A design state: a rule or example depends on an open question, and is marked with its OQ ID. | [workflow.md §3](agent/workflow.md#interaction-rules) |
| Pure | Of a function: calling it does nothing observable besides returning a value (debug output excepted). | [D0008](design/decisions/D0008-purity.md) |
| Purity parameter | A variable standing for "pure or effectful" in a function type, so that a higher-order function takes the purity of its function arguments. | [D0008](design/decisions/D0008-purity.md) |
| Reference checker | The core type-and-purity checker in the mechanization, proved sound and complete against the core typing rules; it reports rule IDs. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0027](design/decisions/D0027-executable-reference.md) |
| Reference evaluator | The fuel-indexed runner of the core's abstract machine in the mechanization, proved sound against the machine rules. | [§1.3.3](spec/01-introduction.md#133-formal-status-and-authority), [D0027](design/decisions/D0027-executable-reference.md) |
| Rejection rule | A rule stating a condition under which a program must be rejected; it carries a rule ID. | [§1.2](spec/01-introduction.md#12-conformance), [D0018](design/decisions/D0018-diagnosis-and-rule-ids.md) |
| REPL | A read-eval-print loop: an interactive prompt that evaluates declarations and expressions one at a time. | [D0013](design/decisions/D0013-easy-start.md) |
| Research note | A file `docs/design/research/Rnnnn-<slug>.md` recording verified findings that a decision relies on. | [research/README.md](design/research/README.md) |
| Rule ID | The permanent name of a rejection rule, such as `R-func-calls-proc`; a rejecting implementation reports at least one. | [§1.3.5](spec/01-introduction.md#135-rejection-rules-and-rule-ids), [D0018](design/decisions/D0018-diagnosis-and-rule-ids.md) |
| Self-hosted compiler | The QubeC compiler written in QubeC, working name `qubecc`; it never implements a feature the host implementation lacks. | [D0029](design/decisions/D0029-permanent-host-implementation.md) |
| Self-hosting yardstick | The tie-breaking test "could QubeC's own compiler be written comfortably in this?". | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Stage target | What an implementation milestone must show before it exits, such as "`qubec run` and the REPL work for the M01–M05 language" for I1. | [D0039](design/decisions/D0039-four-implementation-stages.md) |
| Static semantics | The conditions a program must meet to be accepted (legality, typing, purity). | [§1.1](spec/01-introduction.md#11-scope) |
| Strict evaluation | Call-by-value: arguments are evaluated before a call, not on demand. | [D0005](design/decisions/D0005-non-goals.md) |
| Tail call | A call that is the last action of a function; a call marked `tailcall` replaces the caller's frame and runs in constant stack. | [D0012](design/decisions/D0012-tail-calls-and-stacks.md), [D0014](design/decisions/D0014-tailcall-keyword.md) |
| Task | One bounded sub-topic or piece of one milestone, design or implementation (T0001, …, numbered in creation order across both tracks), normally one session. | [workflow.md §3](agent/workflow.md#milestones-and-tasks) |
| Tie-breaking domain | The kind of program whose needs win when design goals conflict; for QubeC, tooling. | [D0002](design/decisions/D0002-purpose-and-domain.md) |
| Tree-walking interpreter | An interpreter that runs a program by recursively evaluating its syntax tree (here, the core), without compiling it first. | [D0030](design/decisions/D0030-three-part-host.md) |
| Type soundness | The property that a well-typed program never gets stuck: it finishes with a value, panics in a defined way, or runs forever (progress and preservation). | [D0023](design/decisions/D0023-claimed-meta-properties.md) |
| Undefined behavior (UB) | An operation the language gives no meaning, so that anything may happen; QubeC excludes it from safe code. | [D0004](design/decisions/D0004-ranked-design-values.md) |
