# QubeC

QubeC is a new programming language, being designed in the open. The aim is a general-purpose language with some
low-level, systems-programming ability, able to self-host eventually: small and easy to start with, like Python,
but more strictly typed, not indentation-sensitive, and functional in style. Source files use the extension `.qbc`.

The design comes first: decisions are recorded one at a time, and they feed a normative specification with a
standalone EBNF grammar and formal semantics. The implementation follows the specification.

<!-- status:begin -->
## Status

- **Phase:** design, milestone M00 (Vision and principles).
- **Last task:** T0004, how the specification is written: audience, authority, rule style, and diagnostics.
- **Decided so far:** 20 decisions.
  - QubeC is general-purpose and tooling-first, with a safe default layer and an opt-in explicit layer for
    low-level work.
  - Purity is checked: pure functions (`func`) and effectful procedures (`proc`).
  - Bindings are immutable by default, the default collections are mutable, tail calls are explicit
    (`tailcall f(x)`), and a single file runs directly.
  - One specification serves programmers and implementers. Every violation is diagnosed, and every rejection rule
    has a stable ID that compilers report. See the [introduction](docs/spec/01-introduction.md).
  - See the [vision](docs/design/vision.md).
- **Open questions:** 5.
- **Next:** T0005, how far to formalize, and which proof assistant, if any.
<!-- status:end -->

## Where to look

| What | Where |
| --- | --- |
| Progress and the next step | [docs/design/tracker.md](docs/design/tracker.md) |
| Milestones | [docs/design/roadmap.md](docs/design/roadmap.md) |
| Vision | [docs/design/vision.md](docs/design/vision.md) |
| Decisions | [docs/design/decisions/](docs/design/decisions/README.md) |
| Open questions | [docs/design/open-questions.md](docs/design/open-questions.md) |
| Specification | [docs/spec/](docs/spec/README.md) |
| Grammar | [docs/spec/grammar/qubec.ebnf](docs/spec/grammar/qubec.ebnf) |
| Language tour | [docs/guide/tour.md](docs/guide/tour.md) |
| Glossary | [docs/glossary.md](docs/glossary.md) |
| Examples | [examples/](examples/README.md) |
| How the design work is run | [docs/agent/workflow.md](docs/agent/workflow.md) |
