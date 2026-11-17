# Roadmap

The design is organized into milestones (one design area each) and tasks (one bounded sub-topic of one milestone).
Task statuses: **Planned**, **Active**, **Done**, **Dropped**. Exactly one task is Active at a time; the
[tracker](tracker.md) names it. The milestone plan below is a proposal, to be confirmed or reordered during M00;
every change to it is recorded as a decision.

Every milestone shares these exit criteria, on top of its own:
- its decisions are recorded;
- its spec sections are written;
- the grammar and formal rules are updated;
- examples are added;
- no open question is left that it was meant to settle.

## Overview

| ID | Milestone | Status | Depends on |
| --- | --- | --- | --- |
| [M00](#m00-vision-and-principles) | Vision and principles | Active | — |
| [M01](#m01-execution-and-compilation-model) | Execution and compilation model | Planned | M00 |
| [M02](#m02-lexical-structure) | Lexical structure | Planned | M00 |
| [M03](#m03-expressions-and-statements) | Expressions and statements | Planned | M02 |
| [M04](#m04-names-bindings-and-scope) | Names, bindings, and scope | Planned | M03 |
| [M05](#m05-core-type-system) | Core type system | Planned | M03, M04 |
| [M06](#m06-abstraction-and-polymorphism) | Abstraction and polymorphism | Planned | M05 |
| [M07](#m07-memory-and-resources) | Memory and resources | Planned | M01, M05 |
| [M08](#m08-errors-and-effects) | Errors and effects | Planned | M05, M06 |
| [M09](#m09-modules-and-packages) | Modules and packages | Planned | M04, M01 |
| [M10](#m10-concurrency) | Concurrency | Planned | M07, M08 |
| [M11](#m11-compile-time-evaluation-and-metaprogramming) | Compile-time evaluation and metaprogramming | Planned | M01, M06 |
| [M12](#m12-interop-and-platform) | Interop and platform | Planned | M07 |
| [M13](#m13-formal-consolidation) | Formal consolidation | Planned | M05–M12 |
| [M14](#m14-standard-library-and-prelude) | Standard library and prelude | Planned | M06–M10 |
| [M15](#m15-tooling) | Tooling | Planned | M09 |
| [M16](#m16-implementation-plan) | Implementation plan | Planned | M00, M01 |
| [M17](#m17-final-review-and-spec-v10) | Final review and Spec v1.0 | Planned | all |

The dependencies are a first estimate; M00's planning task revisits them.

## M00 Vision and principles

- **Scope:** purpose, users, ranked values, non-goals, inspirations; spec audience and formality level; how far to
  formalize, and which proof assistant if mechanized (such as Rocq, Lean 4, Agda, or Isabelle); the host language for
  the bootstrap implementation; confirming this milestone plan.
- **Exit criteria:** the vision ([vision.md](vision.md)) is complete and every part of it has a D record; the spec
  conventions are fixed; the formalization depth and proof assistant (or "no mechanization") are decided, with
  samples shown; the host language is decided, with samples shown and cheap pilots run; the milestone plan is
  confirmed.

| Task | Sub-topic | Status |
| --- | --- | --- |
| T0001 | Repository setup and design workflow | Done |
| T0002 | Vision I: purpose, users, values, non-goals, inspirations, naming, dream snippet | Done |
| T0003 | Vision II: functional style (purity, bindings, collections, local mutation, recursion) and further must-haves | Done |
| T0004 | Spec audience, authority (prose versus formal rules), and formality level | Done |
| T0005 | Formalization depth and proof assistant (samples: a typing rule and a lemma per candidate) | Done |
| T0006 | Host language for the bootstrap implementation (samples: an AST and evaluator per candidate; pilots) | Done |
| T0007 | Confirm or reorder the milestone plan, in light of D0002–D0014; M00 exit review | Planned |
| T0008 | Revisit: the spelling of explicit tail calls (`tailcall`; part of OQ-005) | Done |

Notes for T0007: T0003 decided several matters normally owned by later milestones (purity, D0008, from M08;
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

## M01 Execution and compilation model

- **Scope:** compiled, interpreted, or JIT; targets; how much runtime there is; the compile-time/run-time boundary;
  separate compilation.
- **From T0006:** the host implementation already has a tree-walking interpreter, a typed-core-to-bytecode compiler,
  and a bytecode VM with a C-ABI runtime ([D0030](decisions/D0030-three-part-host.md)). If M01 decides an execution
  model without a bytecode VM, it revisits D0030. M01 also settles whether bytecode is a visible artifact
  ([OQ-009](open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)).
- **Tasks:** to be planned when M00 closes.

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
- **Tasks:** to be planned.

## M04 Names, bindings, and scope

- **Scope:** declarations, mutability, shadowing, name resolution.
- **Tasks:** to be planned.

## M05 Core type system

- **Scope:** primitives, the numeric model, products and sums, inference, subtyping, the core typing judgments.
- **Tasks:** to be planned.

## M06 Abstraction and polymorphism

- **Scope:** functions and closures, generics, traits or typeclasses, coherence, dispatch.
- **Tasks:** to be planned.

## M07 Memory and resources

- **Scope:** values vs references; ownership, GC, reference counting, or regions; an unsafe escape hatch; the
  undefined-behavior policy.
- **Tasks:** to be planned.

## M08 Errors and effects

- **Scope:** results, exceptions, panics, effect tracking, purity.
- **Tasks:** to be planned.

## M09 Modules and packages

- **Scope:** units, imports, visibility, versioning, the build model.
- **Tasks:** to be planned.

## M10 Concurrency

- **Scope:** threads, tasks, async, actors; data-race freedom; the memory model.
- **Tasks:** to be planned.

## M11 Compile-time evaluation and metaprogramming

- **Scope:** constant evaluation, macros, reflection, attributes.
- **Tasks:** to be planned.

## M12 Interop and platform

- **Scope:** FFI, ABI, layout control, embedding.
- **Tasks:** to be planned.

## M13 Formal consolidation

- **Scope:** consolidates the formal semantics of the sequential language: finishes the mechanized core proofs
  (Lean 4) and the paper proofs of elaboration soundness and decidable checking, and may add referential
  transparency ([D0021](decisions/D0021-formal-target-sequential-language.md)–[D0024](decisions/D0024-mechanize-the-core.md)).
- **Tasks:** to be planned.

## M14 Standard library and prelude

- **Scope:** the prelude and the standard library.
- **Tasks:** to be planned.

## M15 Tooling

- **Scope:** diagnostics, formatter, LSP, test framework, package manager, docs.
- **Tasks:** to be planned.

## M16 Implementation plan

- **Scope:** pipeline, IRs, bootstrapping toward self-hosting, the conformance suite.
- **From T0006:** plans the three host parts, their builds, dependency tables, and repository layout
  ([D0030](decisions/D0030-three-part-host.md)–[D0035](decisions/D0035-pinned-toolchains-and-recorded-libraries.md));
  the build from source and the fixpoint check as release steps
  ([D0029](decisions/D0029-permanent-host-implementation.md)); the bytecode format (OQ-009). OQ-008 may be settled
  earlier, when the host compiler starts.
- **Tasks:** to be planned.

## M17 Final review and Spec v1.0

- **Scope:** a consistency audit, a rationale document, a changelog.
- **Tasks:** to be planned.
