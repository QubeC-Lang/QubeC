# QubeC

QubeC is a new programming language, being designed in the open. The aim is a general-purpose language with some
low-level, systems-programming ability, able to self-host eventually: small and easy to start with, like Python,
but more strictly typed, not indentation-sensitive, and functional in style. Source files use the extension `.qbc`.

The design comes first: decisions are recorded one at a time, and they feed a normative specification with a
standalone EBNF grammar and formal semantics. The implementation follows the specification.

<!-- status:begin -->
## Status

- **Phase:** design, milestone M02 (Lexical structure). M00 (Vision and principles) and M01 (Execution and
  compilation model) are complete.
- **Last task:** T0014, the grammar machinery, which planned M02.
- **Decided so far:** 82 decisions.
  - QubeC is general-purpose and tooling-first, with a safe default layer and an opt-in explicit layer for
    low-level work.
  - Purity is checked: pure functions (`func`) and effectful procedures (`proc`).
  - Bindings are immutable by default, the default collections are mutable, tail calls are explicit
    (`tailcall f(x)`), and a single file runs directly.
  - One specification serves programmers and implementers. Every violation is diagnosed, and every rejection rule
    has a stable ID that compilers report. See the [introduction](docs/spec/01-introduction.md).
  - The whole sequential language gets formal semantics: surface rules elaborate into an explicitly typed core,
    which is mechanized in Lean 4, with soundness, purity, determinism, and tail-call space theorems, and a verified
    reference evaluator and checker. See the [formal rules](docs/spec/formal/README.md).
  - The first implementation is permanent and leads every feature: a Rust front end, interpreter, and REPL; an OCaml
    compiler from the typed core to bytecode; and a Zig VM and runtime.
  - Implementation trails the design in four stages, starting once M01 and M02 are decided, and Spec v1.0 waits
    until both implementations, including the self-hosted compiler, implement the whole language. See the
    [roadmap](docs/design/roadmap.md).
  - Programs run on a tree-walking interpreter and a bytecode VM; a build is one self-contained executable, and
    native code comes after Spec v1.0. Linux x86-64 and macOS arm64 are supported first.
  - What a program does is its trace of interactions and its outcome, and it is the same on every implementation,
    engine, and platform, floating point included. Panics are precise; the only exception is running out of stack
    or memory, above a guaranteed depth of 100,000 nested calls.
  - `main` is `proc main()` or returns a result; exit statuses are 0, 1 (an error from `main`), 101 (a panic), and
    102 (resource exhaustion), and a failure is reported in one specified line. Interrupts and closed pipes end a
    run quietly. Each runtime supplies only thin natives; the rest of the library is QubeC source.
  - A program is checked, then every constant is evaluated exactly once, then it runs. Constants run only pure code,
    hold no mutable state, and fail the build if they panic; every implementation completes 10,000,000 steps per
    constant, or more if the constant says so.
  - A program means what its source says: compiled units are only caches. Units are sets of files that depend on
    each other without cycles. Builds are byte-identical on any machine, and panics name files by unit and path, as
    in `wc/src/count.qbc:12:24`.
  - The grammar is one file in W3C EBNF, with a lexical layer over characters and a syntactic layer over tokens. An
    independent checker in [tools/grammar/](tools/grammar/README.md) also runs the lexical grammar on text. Each
    lexical failure has its own rule ID, and every parse failure is `R-syntax`.
  - See the [vision](docs/design/vision.md).
- **Open questions:** 14.
- **Next:** T0015, source text and layout (encoding, line ends, whitespace, columns, how statements end); closing
  M02 starts the implementation.
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
| Tools | [tools/](tools/README.md) |
| How the design work is run | [docs/agent/workflow.md](docs/agent/workflow.md) |
