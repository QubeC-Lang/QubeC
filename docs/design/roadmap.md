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
| T0003 | Vision II: what "functional in style" commits us to (frames OQ-004: purity, immutability by default, first-class functions), and any further must-haves | Planned |
| T0004 | Spec audience, authority (prose versus formal rules), and formality level | Planned |
| T0005 | Formalization depth and proof assistant (samples: a typing rule and a lemma per candidate) | Planned |
| T0006 | Host language for the bootstrap implementation (samples: an AST and evaluator per candidate; pilots) | Planned |
| T0007 | Confirm or reorder the milestone plan, in light of D0002–D0007; M00 exit review | Planned |

Notes for T0007: Go-style concurrency ([D0006](decisions/D0006-inspirations.md), OQ-001) makes M01's runtime
decision constrain M10, and the explicit layer ([D0004](decisions/D0004-ranked-design-values.md), OQ-003) makes M07
a dependency of the numeric parts of M05.

## M01 Execution and compilation model

- **Scope:** compiled, interpreted, or JIT; targets; how much runtime there is; the compile-time/run-time boundary;
  separate compilation.
- **Tasks:** to be planned when M00 closes.

## M02 Lexical structure

- **Scope:** encoding, identifiers, keywords, literals, comments, whitespace; the EBNF dialect.
- **Tasks:** to be planned.

## M03 Expressions and statements

- **Scope:** expression orientation, operators and precedence, blocks, control flow, patterns.
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
  undefined-behaviour policy.
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

- **Scope:** complete semantics, soundness statements and proof sketches, and mechanized proofs if chosen.
- **Tasks:** to be planned.

## M14 Standard library and prelude

- **Scope:** the prelude and the standard library.
- **Tasks:** to be planned.

## M15 Tooling

- **Scope:** diagnostics, formatter, LSP, test framework, package manager, docs.
- **Tasks:** to be planned.

## M16 Implementation plan

- **Scope:** pipeline, IRs, bootstrapping toward self-hosting, the conformance suite.
- **Tasks:** to be planned.

## M17 Final review and Spec v1.0

- **Scope:** a consistency audit, a rationale document, a changelog.
- **Tasks:** to be planned.
