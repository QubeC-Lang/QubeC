# Roadmap

The work is organized into two tracks ([D0036](decisions/D0036-trailing-implementation-track.md),
[D0037](decisions/D0037-implementation-milestones-and-tasks.md)):
- the **design track**: design milestones M00, M01, …, one design area each;
- the **implementation track**: implementation milestones I1, I2, …, one stage of the implementation each. It starts
  once M01 and M02 have closed, implements only closed design milestones, and never makes design wait.

A task (T0001, …, numbered in creation order across both tracks) is one bounded piece of one milestone. Task
statuses: **Planned**, **Active**, **Done**, **Dropped**. At most one task per track is Active at a time; the
[tracker](tracker.md) names them. The plan was confirmed in T0007
([D0036](decisions/D0036-trailing-implementation-track.md)–[D0041](decisions/D0041-spec-v1-after-i4.md)); every
change to it is recorded as a decision.

Every design milestone shares these exit criteria, on top of its own:
- its decisions are recorded;
- its spec sections are written;
- the grammar and formal rules are updated;
- examples are added;
- no open question is left that it was meant to settle.

Every implementation milestone shares these exit criteria, on top of its stage target
([D0039](decisions/D0039-four-implementation-stages.md)):
- **P1:** every task is Done, or Dropped with a reason;
- **P2:** the architecture decisions made in it are recorded as decision records;
- **P3:** the code builds from a clean checkout with the pinned toolchains, and the build is documented;
- **P4:** its unit tests, and the conformance tests for everything it implements, pass on every execution path it
  has;
- **P5:** every divergence found between the code and the specification is resolved in the specification or
  recorded as an open question; the specification stays the authority;
- **P6:** its stage target is met.

An implementation milestone cannot exit before every design milestone it implements has closed.

## Overview

Design track:

| ID | Milestone | Status | Depends on |
| --- | --- | --- | --- |
| [M00](#m00-vision-and-principles) | Vision and principles | Done | — |
| [M01](#m01-execution-and-compilation-model) | Execution and compilation model | Active | M00 |
| [M02](#m02-lexical-structure) | Lexical structure | Planned | M00 |
| [M03](#m03-expressions-and-statements) | Expressions and statements | Planned | M02 |
| [M04](#m04-names-bindings-and-scope) | Names, bindings, and scope | Planned | M03 |
| [M05](#m05-core-type-system) | Core type system | Planned | M03, M04 (not M07) |
| [M06](#m06-abstraction-and-polymorphism) | Abstraction and polymorphism | Planned | M05 |
| [M07](#m07-memory-and-resources) | Memory and resources | Planned | M01, M05 |
| [M08](#m08-errors-and-effects) | Errors and effects | Planned | M05, M06 |
| [M09](#m09-modules-and-packages) | Modules and packages | Planned | M04, M01 |
| [M10](#m10-concurrency) | Concurrency | Planned | M07, M08 |
| [M11](#m11-compile-time-evaluation-and-metaprogramming) | Compile-time evaluation and metaprogramming | Planned | M01, M06 |
| [M12](#m12-interop-and-platform) | Interop and platform | Planned | M07 |
| [M13](#m13-formal-consolidation) | Formal consolidation | Planned | M05–M12 |
| [M14](#m14-standard-library-and-prelude) | Standard library and prelude | Planned | M06–M09 |
| [M15](#m15-tooling) | Tooling | Planned | M09, M14 |
| [M16](#m16-implementation-plan) | Implementation plan | Dropped (merged into I1–I3, [D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)) | — |
| [M17](#m17-final-review-and-spec-v10) | Final review and Spec v1.0 | Planned | M13, M14, M15, I4 |

Implementation track ([D0039](decisions/D0039-four-implementation-stages.md)):

| ID | Milestone | Status | Implements | Depends on |
| --- | --- | --- | --- | --- |
| [I1](#i1-front-end-and-core-interpreter) | Front end and core interpreter | Planned | M01–M05 | M01, M02 |
| [I2](#i2-host-complete-for-the-core-language) | Host complete for the core language | Planned | M06–M09, M14 | I1 |
| [I3](#i3-qubecc-and-the-fixpoint) | `qubecc` and the fixpoint | Planned | — | I2 |
| [I4](#i4-the-remaining-features) | The remaining features | Planned | M10–M12 | I3 |

The order of both tracks, as confirmed in T0007 ([D0040](decisions/D0040-design-milestones-kept.md)):

```
design: M00 → M01 → M02 → M03 → M04 → M05 → M06 → M07 → M08 → M09 → M14 ─┬→ M10 · M11 · M12 · M15 → M13 ─┬→ M17
impl:                 └→ I1 (trails M01–M05) ─→ I2 (M06–M09, M14) ───────└→ I3 ─→ I4 ────────────────────┘
```

I1 starts once M01 and M02 have closed. M15 may run alongside I2 and I3. An implementation milestone trails the design
milestones it implements and exits only after they have closed.

## M00 Vision and principles

- **Scope:** purpose, users, ranked values, non-goals, inspirations; spec audience and formality level; how far to
  formalize, and which proof assistant if mechanized (such as Rocq, Lean 4, Agda, or Isabelle); the host language for
  the bootstrap implementation; confirming this milestone plan.
- **Exit criteria:** the vision ([vision.md](vision.md)) is complete and every part of it has a D record; the spec
  conventions are fixed; the formalization depth and proof assistant (or "no mechanization") are decided, with
  samples shown; the host language is decided, with samples shown and cheap pilots run; the milestone plan is
  confirmed.
- **Exit review (T0007, 2026-11-16):**

  | Criterion | Result |
  | --- | --- |
  | The vision is complete, and every part has a D record | Met: D0002–D0014, [vision.md](vision.md) |
  | The spec conventions are fixed | Met: D0015–D0020, [spec §1.3](../spec/01-introduction.md#13-notation-and-conventions) (the EBNF dialect is M02's) |
  | The formalization depth and proof assistant are decided, with samples | Met: D0021–D0028, [R0004](research/R0004-formalization-prior-art-and-pilots.md) |
  | The host language is decided, with samples and pilots | Met: D0029–D0035, [R0005](research/R0005-host-language-prior-art-and-pilots.md) |
  | The milestone plan is confirmed | Met: D0036–D0041 |
  | Common: decisions recorded | Met: D0001–D0041 |
  | Common: spec sections written | Met: §1 Introduction (Draft) |
  | Common: grammar and formal rules updated | Met as far as M00 reaches: the grammar file is a provisional placeholder; the formal files are skeletons with the claimed properties fixed |
  | Common: examples added | Not met, waived: M00 decided no syntax, and its provisional snippets live in [vision.md](vision.md); `examples/` starts once M02 and M03 decide syntax |
  | Common: no open question left that M00 was to settle | Met: OQ-001–OQ-003 and OQ-005–OQ-009 all target later milestones |

  M00 closed on 2026-11-16.

| Task | Sub-topic | Status |
| --- | --- | --- |
| T0001 | Repository setup and design workflow | Done |
| T0002 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | Done |
| T0003 | Vision II: functional style (purity, bindings, collections, local mutation, recursion) and further must-haves | Done |
| T0004 | Spec audience, authority (prose versus formal rules), and formality level | Done |
| T0005 | Formalization depth and proof assistant (samples: a typing rule and a lemma per candidate) | Done |
| T0006 | Host language for the bootstrap implementation (samples: an AST and evaluator per candidate; pilots) | Done |
| T0007 | Confirm or reorder the milestone plan; when implementation starts; M00 exit review | Done |
| T0008 | Revisit: the spelling of explicit tail calls (`tailcall`; part of OQ-005) | Done |

Notes for T0007 (all handled in T0007, D0036–D0041): T0003 decided several matters normally owned by later milestones (purity, D0008, from M08;
bindings, D0009, from M04; tail calls, D0012, from M01/M03), at the vision level; those milestones now refine
rather than decide them. Go-style concurrency ([D0006](decisions/D0006-inspirations.md), OQ-001) makes M01's runtime
decision constrain M10, and the explicit layer ([D0004](decisions/D0004-ranked-design-values.md), OQ-003) makes M07
a dependency of the numeric parts of M05. T0004 added: every violation is diagnosed
([D0018](decisions/D0018-diagnosis-and-rule-ids.md)), so M07, M08, and M10 must state their rules (local mutation,
effects, race freedom) as checkable disciplines; the extension opt-in's syntax
([OQ-006](open-questions.md#oq-006-how-is-an-extension-opt-in-written-and-where-may-it-appear)) belongs to M09 or
M11; M14 draws the core library's list ([D0015](decisions/D0015-spec-audience-and-scope.md)).

T0005 added: the formal target is the whole sequential language, with a revisit trigger if M07's mutation or
borrow design is not syntactically provable ([D0021](decisions/D0021-formal-target-sequential-language.md)); M03
starts the Lean mechanization ([D0028](decisions/D0028-mechanization-starts-in-m03.md)), and every later milestone
that changes core rules keeps it current before exiting ([D0024](decisions/D0024-mechanize-the-core.md)); decidable
checking constrains M05/M06's inference ([D0023](decisions/D0023-claimed-meta-properties.md)); M16 owns the core
interchange format ([OQ-008](open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)).

T0006 added: the host implementation is permanent and leads every feature
([D0029](decisions/D0029-permanent-host-implementation.md)), in three parts and languages (Rust host interpreter,
OCaml host compiler, Zig host VM, [D0030](decisions/D0030-three-part-host.md)). So every feature milestone is
implemented twice once QubeC self-hosts, and the project carries four pinned toolchains with the Lean mechanization
([D0035](decisions/D0035-pinned-toolchains-and-recorded-libraries.md)); T0007 should weigh this load and when
implementation work starts. D0030 presumes a bytecode VM, which constrains M01 (with a revisit trigger), and it needs
OQ-008 before the host compiler is built, earlier than M16; it also opens
[OQ-009](open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm) (the
bytecode format, M01/M16).

T0007 dropped M16 by merging it into I1–I3, so the M16 items above now belong to I1 and I2
([D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)).

## M01 Execution and compilation model

- **Scope:** compiled, interpreted, or JIT; targets; how much runtime there is; the compile-time/run-time boundary;
  separate compilation.
- **From T0006:** the host implementation already has a tree-walking interpreter, a typed-core-to-bytecode compiler,
  and a bytecode VM with a C-ABI runtime ([D0030](decisions/D0030-three-part-host.md)). If M01 decides an execution
  model without a bytecode VM, it revisits D0030. M01 also settles whether bytecode is a visible artifact
  ([OQ-009](open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)).
- **Also targets:** the M01 part of OQ-009 (whether bytecode is an artifact users see, and its stability); the
  conformance requirements for observable behavior and implementation limits that spec §1.2 leaves to M01; the
  run mode of [D0013](decisions/D0013-easy-start.md).
- **From T0009:** a tree-walking interpreter and a bytecode VM, with no JIT, so D0030 stands
  ([D0042](decisions/D0042-tree-walker-and-bytecode-vm.md)); native code after Spec v1.0 under the native-compatible
  rule ([D0043](decisions/D0043-native-code-after-v1.md)); self-contained executables with unstable emitted bytecode
  ([D0044](decisions/D0044-executables-and-unstable-bytecode.md)), which settles OQ-009's M01 part; `run` as
  build-then-execute ([D0045](decisions/D0045-run-is-a-shortcut.md)); platforms in three tiers
  ([D0046](decisions/D0046-first-platforms-and-tiers.md)) under the host-leads rule
  ([D0047](decisions/D0047-platform-parity.md)). T0010 must define the observable behavior that D0045's equivalence
  rests on.
- **From T0010:** observable behavior is a trace of events and an outcome
  ([D0048](decisions/D0048-trace-and-outcome.md)); panics are precise and carry their kind, message, and location
  ([D0049](decisions/D0049-precise-panics.md), [D0050](decisions/D0050-panic-contents.md)); the sequential language,
  floats included, is deterministic across implementations and platforms
  ([D0051](decisions/D0051-deterministic-sequential-language.md), [D0052](decisions/D0052-bit-identical-floats.md));
  resource exhaustion is the one exception, above a guaranteed depth ([D0053](decisions/D0053-resource-exhaustion.md));
  structural limits are rejection rules ([D0054](decisions/D0054-implementation-limits-as-rules.md)). T0011 must settle
  [OQ-012](open-questions.md#oq-012-what-is-the-guaranteed-minimum-depth-of-nested-calls) (the guaranteed depth);
  [OQ-011](open-questions.md#oq-011-how-are-floating-point-math-functions-and-the-canonical-nan-specified) goes to M05.
- **From T0011:** one runtime contract with two independent host runtimes, and a runtime in QubeC for native code
  ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); thin natives declared in the standard library's source ([D0056](decisions/D0056-thin-natives.md)); two forms of `main` ([D0057](decisions/D0057-forms-of-main.md), the result form
  provisional, [OQ-013](open-questions.md#oq-013-what-exactly-is-the-result-form-of-main)); exit statuses 0, 1, 101, 102 ([D0058](decisions/D0058-exit-statuses.md)); one report line on standard error with an optional,
  non-observable backtrace ([D0059](decisions/D0059-report-line-and-backtrace.md), its text provisional, [OQ-014](open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter)); termination by the environment as a fifth outcome,
  abrupt by default ([D0060](decisions/D0060-termination-by-the-environment.md)), which also covers a closed reader of standard output or error ([D0061](decisions/D0061-failed-standard-output.md)); a guaranteed depth
  of 100,000 nested calls and a raisable stack cap ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)), which settles OQ-012.
- **Closing it, together with M02, starts the implementation track** (I1,
  [D0036](decisions/D0036-trailing-implementation-track.md)).

| Task | Sub-topic | Status |
| --- | --- | --- |
| T0009 | Execution model and artifacts: interpreter, bytecode VM, native code (which, and when); what `run` and `build` produce; the M01 part of OQ-009; first targets and platforms; confirming or revisiting D0030's bytecode VM | Done |
| T0010 | Observable behavior and determinism: what is observable (output, exit status, panics); what may differ between implementations, execution paths, and platforms (for example floats, iteration order, resource limits); implementation limits; the conformance additions to spec §1.2 | Done |
| T0011 | The runtime and the program lifecycle: the runtime's responsibilities (hooks for M07's memory management and M10's scheduler, D0012's stacks, native functions); the forms of `main` and the exit status; panics and their report; resource exhaustion; output at exit | Done |
| T0012 | The compile-time/run-time boundary: program phases; constant evaluation; what may run at compile time, and how `func` purity relates to it; what a compile-time failure means | Planned |
| T0013 | Units, separate compilation, and reproducibility: what a compiled unit is; whether build output is reproducible; how source locations are named | Planned |

## M02 Lexical structure

- **Scope:** encoding, identifiers, keywords, literals, comments, whitespace; the EBNF dialect.
- **Tasks:** to be planned.

## M03 Expressions and statements

- **Scope:** expression orientation, operators and precedence, blocks, control flow, patterns.
- **Formal work (from T0005):** the first formal rules. M03's first formal task creates the Lean package
  `docs/spec/formal/lean/`, mechanizes the core's syntax and abstract-machine dynamics so far, proves determinism and
  the tail-call space bound, and settles the binder representation
  ([OQ-007](open-questions.md#oq-007-how-does-the-mechanized-core-represent-binders))
  ([D0023](decisions/D0023-claimed-meta-properties.md), [D0028](decisions/D0028-mechanization-starts-in-m03.md)).
  An added exit criterion: the mechanization covers M03's core rules, or each gap is an open question.
- **From T0011:** defines frames and restates the guaranteed depth's 256-value frame bound in their terms; may set
  D0054's nesting limit well below the guaranteed depth ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)).
- **Tasks:** to be planned.

## M04 Names, bindings, and scope

- **Scope:** declarations, mutability, shadowing, name resolution.
- **From T0011:** states the entry-point rule, with its rule ID, for the two forms of `main` ([D0057](decisions/D0057-forms-of-main.md)).
- **Tasks:** to be planned.

## M05 Core type system

- **Scope:** primitives, the numeric model, products and sums, inference, subtyping, the core typing judgments.
- **From T0007:** M05 does not wait for M07. It decides the numeric model, including sized integers and how the
  explicit layer is marked (OQ-003's M05 part); M07 decides borrowed references
  ([D0040](decisions/D0040-design-milestones-kept.md)).
- **From T0010:** floats are bit-identical everywhere, with canonical NaN observations, specified text conversions,
  and specified math functions ([D0052](decisions/D0052-bit-identical-floats.md),
  [OQ-011](open-questions.md#oq-011-how-are-floating-point-math-functions-and-the-canonical-nan-specified)); integer
  ranges are the same on every platform ([D0051](decisions/D0051-deterministic-sequential-language.md)); overflow is
  checked and wrapping is written ([D0049](decisions/D0049-precise-panics.md)).
- **From T0011:** float formatting, parsing, and correctly rounded math are library code in QubeC, not natives
  ([D0056](decisions/D0056-thin-natives.md)); the result type of `main`'s second form ([OQ-013](open-questions.md#oq-013-what-exactly-is-the-result-form-of-main)).
- **Tasks:** to be planned.

## M06 Abstraction and polymorphism

- **Scope:** functions and closures, generics, traits or typeclasses, coherence, dispatch.
- **From T0011:** what "can be displayed" means for the error type of `main`'s second form ([OQ-013](open-questions.md#oq-013-what-exactly-is-the-result-form-of-main)).
- **Tasks:** to be planned.

## M07 Memory and resources

- **Scope:** values vs references; ownership, GC, reference counting, or regions; an unsafe escape hatch; the
  undefined-behavior policy.
- **From T0010:** no memory address, or anything derived from one, is observable
  ([D0051](decisions/D0051-deterministic-sequential-language.md)).
- **From T0011:** the explicit layer and the unsafe escape hatch must be able to express a runtime: a garbage
  collector or reference counting, and stack management, written in QubeC ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); whether `exit` runs cleanup
  ([D0058](decisions/D0058-exit-statuses.md)); cleanup does not run on termination by the environment ([D0060](decisions/D0060-termination-by-the-environment.md)).
- **Tasks:** to be planned.

## M08 Errors and effects

- **Scope:** errors (results, exceptions, panics) and the mechanics of effects, refining the purity of
  [D0008](decisions/D0008-purity.md) ([D0040](decisions/D0040-design-milestones-kept.md)).
- **From T0011:** settles [OQ-013](open-questions.md#oq-013-what-exactly-is-the-result-form-of-main) (the result form of `main`) and [OQ-014](open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter) (the report line's text), and names panic
  kinds and messages ([D0059](decisions/D0059-report-line-and-backtrace.md)).
- **Tasks:** to be planned.

## M09 Modules and packages

- **Scope:** units, imports, visibility, versioning, the build model.
- **From T0011:** which unit's `main` is the entry point ([D0057](decisions/D0057-forms-of-main.md)); how the standard library, the only place
  natives are declared, is identified ([D0056](decisions/D0056-thin-natives.md)).
- **Tasks:** to be planned.

## M10 Concurrency

- **Scope:** threads, tasks, async, actors; data-race freedom; the memory model.
- **From T0010:** must state what concurrent programs may vary, since the determinism of
  [D0051](decisions/D0051-deterministic-sequential-language.md) covers the sequential language only, and how the
  events of concurrent tasks interleave in the trace ([D0048](decisions/D0048-trace-and-outcome.md)).
- **From T0011:** the scheduler is a runtime-contract responsibility ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); each task's stack follows the cap and
  guaranteed depth ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)); the API to receive interrupts and termination requests, with M14 ([D0060](decisions/D0060-termination-by-the-environment.md)).
- **Tasks:** to be planned.

## M11 Compile-time evaluation and metaprogramming

- **Scope:** constant evaluation, macros, reflection, attributes.
- **Tasks:** to be planned.

## M12 Interop and platform

- **Scope:** FFI, ABI, layout control, embedding.
- **From T0011:** layout control and the C ABI must let a runtime written in QubeC call the operating system
  ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)).
- **Tasks:** to be planned.

## M13 Formal consolidation

- **Scope:** consolidates the formal semantics of the sequential language: finishes the mechanized core proofs
  (Lean 4) and the paper proofs of elaboration soundness and decidable checking, and may add referential
  transparency ([D0021](decisions/D0021-formal-target-sequential-language.md)–[D0024](decisions/D0024-mechanize-the-core.md)).
- **Tasks:** to be planned.

## M14 Standard library and prelude

- **Scope:** the prelude and the standard library. Depends on M06–M09 (not M10), because I2 needs the core library
  before M10 runs; M10 adds its own library surface ([D0040](decisions/D0040-design-milestones-kept.md)).
- **From T0010:** maps and sets have a specified iteration order, and hash seeds stay unobservable
  ([D0051](decisions/D0051-deterministic-sequential-language.md)); natives are specified as events
  ([D0048](decisions/D0048-trace-and-outcome.md)); the math functions have the specified results of
  [D0052](decisions/D0052-bit-identical-floats.md).
- **From T0011:** the list of natives, their declaration marker, and the library around them ([D0056](decisions/D0056-thin-natives.md)); `args()`, the
  environment, and `exit` ([D0057](decisions/D0057-forms-of-main.md), [D0058](decisions/D0058-exit-statuses.md)); standard-output procedures and explicit writers with results, and a way
  to receive interrupts ([D0060](decisions/D0060-termination-by-the-environment.md), [D0061](decisions/D0061-failed-standard-output.md)); collection functions avoid non-tail recursion over their length ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)).
- **Tasks:** to be planned.

## M15 Tooling

- **Scope:** diagnostics, formatter, LSP, test framework, package manager, docs. Depends on M09 and M14, and may run
  alongside I2 and I3 ([D0040](decisions/D0040-design-milestones-kept.md)). The conformance harness itself starts in
  I1 ([D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)). Names the commands and flags, which
  are provisional until then ([D0044](decisions/D0044-executables-and-unstable-bytecode.md),
  [D0045](decisions/D0045-run-is-a-shortcut.md)); plans CI per platform tier
  ([D0046](decisions/D0046-first-platforms-and-tiers.md)).
- **From T0011:** names the input that requests a backtrace and the one that raises the stack cap ([D0059](decisions/D0059-report-line-and-backtrace.md),
  [D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)).
- **Tasks:** to be planned.

## M16 Implementation plan

- **Status:** Dropped on 2026-11-16 (T0007): merged into I1–I3
  ([D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)). Its number is not reused. Its former scope
  is now planned as follows: the host interpreter's architecture, code layout, and conformance harness in I1; the core
  interchange format (OQ-008), the bytecode format (OQ-009), and the host compiler's and VM's architecture in I2;
  `qubecc`'s pipeline and IRs, the fixpoint check, and the release checks in I3; the plan after v1.0 in M17.

## M17 Final review and Spec v1.0

- **Scope:** a consistency audit, a rationale document, a changelog; the plan after Spec v1.0
  ([D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)), and how a published specification
  changes. The post-v1.0 plan includes native code and its route
  ([D0043](decisions/D0043-native-code-after-v1.md), [OQ-010](open-questions.md#oq-010-how-is-native-code-generated)).
- **Depends on:** M13, M14, M15, and I4. Spec v1.0 is published only after I4 has exited; drafts may be tagged 0.x
  before then ([D0041](decisions/D0041-spec-v1-after-i4.md)).
- **From T0011:** the post-v1.0 plan includes the runtime written in QubeC that native code links ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)).
- **Tasks:** to be planned.

## I1 Front end and core interpreter

- **Implements:** M01–M05, each as it closes. Starts once M01 and M02 have closed
  ([D0036](decisions/D0036-trailing-implementation-track.md)).
- **Builds:** the host interpreter in Rust ([D0031](decisions/D0031-rust-host-interpreter.md)): scanner, parser, name
  resolution, type and purity checking, elaboration into the core, the tree-walking interpreter, the REPL, and the
  driver.
- **Opens with** design tasks for the host interpreter's architecture and the code's repository layout, the start of
  the conformance harness and the dependency table ([D0035](decisions/D0035-pinned-toolchains-and-recorded-libraries.md)),
  and how implementation tasks are run ([D0037](decisions/D0037-implementation-milestones-and-tasks.md),
  [D0038](decisions/D0038-m16-merged-into-implementation-milestones.md)). OQ-008 is decided here if I1 is the first to
  send core across a boundary.
- **Stage target:** `qubec run` and the REPL work for the M01–M05 language; the conformance harness exists.
- **From T0011:** the host interpreter's runtime is written in Rust and meets the runtime contract; I1's opening task
  decides where the contract is kept ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)); the first natives and a minimal library are needed early ([D0056](decisions/D0056-thin-natives.md));
  the tree-walker reaches the guaranteed depth in release builds on every Tier 1 and Tier 2 platform ([D0062](decisions/D0062-guaranteed-depth-and-stack-cap.md)).
- **Tasks:** to be planned when I1 starts.

## I2 Host complete for the core language

- **Implements:** M06–M09 and M14, each as it closes. Starts once I1 has exited.
- **Builds:** the host interpreter extended; the host compiler in OCaml ([D0032](decisions/D0032-ocaml-host-compiler.md))
  and the host VM in Zig ([D0033](decisions/D0033-zig-host-vm.md)), with its memory management written after M07.
- **Opens with** design tasks for the core interchange format
  ([OQ-008](open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)), the
  bytecode format ([OQ-009](open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)),
  and the host compiler's and host VM's architecture.
- **Stage target:** the whole conformance suite so far passes on the interpreted path and the compiled path.
- **From T0011:** the host VM's runtime, in Zig, meets the same contract independently ([D0055](decisions/D0055-runtime-contract-and-runtimes.md)).
- **Tasks:** to be planned when I2 starts.

## I3 `qubecc` and the fixpoint

- **Starts** once I2 has exited.
- **Builds:** `qubecc`, the self-hosted compiler, in QubeC.
- **Opens with** design tasks for `qubecc`'s architecture (designed fresh,
  [D0034](decisions/D0034-idiomatic-code-per-part.md)), which features its own source uses, and the release procedure
  of [D0029](decisions/D0029-permanent-host-implementation.md).
- **Stage target:** the fixpoint check and the release checks pass (build from source, fixpoint, both
  implementations passing the conformance suite).
- **Tasks:** to be planned when I3 starts.

## I4 The remaining features

- **Implements:** M10–M12, each as it closes. Starts once I3 has exited.
- **Builds:** each feature in the host implementation first, then in `qubecc`
  ([D0029](decisions/D0029-permanent-host-implementation.md)).
- **Stage target:** both implementations pass the whole conformance suite. Its exit allows M17 to publish Spec v1.0
  ([D0041](decisions/D0041-spec-v1-after-i4.md)).
- **Tasks:** to be planned when I4 starts.
