# Decision Log

One record per decision, made from [the template](../templates/decision.md).
- Records are never deleted. A changed decision gets a new record, and the old one is marked *Superseded by Dnnnn*.
- Status values: **Accepted** · **Superseded by Dnnnn**.

| ID | Title | Status | Milestone / task | Date |
| --- | --- | --- | --- | --- |
| [D0001](D0001-repository-layout.md) | Repository layout and design-process structure | Accepted | M00 / T0001 | 2026-11-15 |
| [D0002](D0002-purpose-and-domain.md) | Purpose and tie-breaking domain: general-purpose, tooling-first | Accepted | M00 / T0002 | 2026-11-16 |
| [D0003](D0003-target-users.md) | Target users: tool builders first, then application developers and systems programmers | Accepted | M00 / T0002 | 2026-11-16 |
| [D0004](D0004-ranked-design-values.md) | Ranked design values, layered: a default layer and an explicit layer | Accepted | M00 / T0002 | 2026-11-16 |
| [D0005](D0005-non-goals.md) | Non-goals | Accepted | M00 / T0002 | 2026-11-16 |
| [D0006](D0006-inspirations.md) | Inspirations and anti-inspirations | Accepted | M00 / T0002 | 2026-11-16 |
| [D0007](D0007-intuitive-names.md) | Names are intuitive: widely recognized short forms, otherwise whole words | Accepted | M00 / T0002 | 2026-11-16 |
| [D0008](D0008-purity.md) | Purity is tracked: pure functions (`func`) and effectful procedures (`proc`) | Accepted | M00 / T0003 | 2026-11-16 |
| [D0009](D0009-immutable-bindings.md) | Bindings are immutable by default; mutable variables are local; no global variables | Accepted | M00 / T0003 | 2026-11-16 |
| [D0010](D0010-mutable-default-collections.md) | The default collections are mutable; immutable collections are in the library | Accepted | M00 / T0003 | 2026-11-16 |
| [D0011](D0011-local-mutation-in-functions.md) | A pure function may mutate values it created, if the mutation is not observable | Accepted | M00 / T0003 | 2026-11-16 |
| [D0012](D0012-tail-calls-and-stacks.md) | Explicit, checked tail calls; growable stacks | Accepted | M00 / T0003 | 2026-11-16 |
| [D0013](D0013-easy-start.md) | Easy start is a must-have: run a file directly, and a REPL | Accepted | M00 / T0003 | 2026-11-16 |
| [D0014](D0014-tailcall-keyword.md) | Explicit tail calls are written `tailcall f(x)` | Accepted | M00 / T0008 | 2026-11-16 |
| [D0015](D0015-spec-audience-and-scope.md) | One specification for programmers and implementers, covering the language and its core library | Accepted | M00 / T0004 | 2026-11-16 |
| [D0016](D0016-authority-per-section.md) | Authority is per section: formal rules govern only where an aspect is formally complete | Accepted | M00 / T0004 | 2026-11-16 |
| [D0017](D0017-rule-style.md) | Static rules are declarative; dynamic behavior is written as numbered steps where order is observable | Accepted | M00 / T0004 | 2026-11-16 |
| [D0018](D0018-diagnosis-and-rule-ids.md) | Every violation is diagnosed; rejection rules have stable mnemonic IDs that must be reported | Accepted | M00 / T0004 | 2026-11-16 |
| [D0019](D0019-extensions-by-source-opt-in.md) | Extensions only with an opt-in in the source file | Accepted | M00 / T0004 | 2026-11-16 |
| [D0020](D0020-us-english-spelling.md) | US English spelling everywhere | Accepted | M00 / T0004 | 2026-11-16 |
| [D0021](D0021-formal-target-sequential-language.md) | The formal target is the whole sequential language | Accepted | M00 / T0005 | 2026-11-16 |
| [D0022](D0022-typed-elaboration-into-core.md) | Static rules on the surface elaborate into an explicitly typed core; dynamic rules are over the core | Accepted | M00 / T0005 | 2026-11-16 |
| [D0023](D0023-claimed-meta-properties.md) | Claimed meta-properties: soundness, purity with a frame property, tail-call space, determinism, decidable checking | Accepted | M00 / T0005 | 2026-11-16 |
| [D0024](D0024-mechanize-the-core.md) | The core is mechanized; the elaboration and inference proofs are on paper | Accepted | M00 / T0005 | 2026-11-16 |
| [D0025](D0025-lean-4.md) | Lean 4 is the proof assistant | Accepted | M00 / T0005 | 2026-11-16 |
| [D0026](D0026-lean-governs-core-rules.md) | For core rules, the Lean definition governs; the Markdown rule mirrors it | Accepted | M00 / T0005 | 2026-11-16 |
| [D0027](D0027-executable-reference.md) | An executable reference: a verified core evaluator and a verified core checker | Accepted | M00 / T0005 | 2026-11-16 |
| [D0028](D0028-mechanization-starts-in-m03.md) | The mechanization starts in M03, as a Lean package in docs/spec/formal/lean/ | Accepted | M00 / T0005 | 2026-11-16 |
| [D0029](D0029-permanent-host-implementation.md) | The host implementation is permanent and leads every feature | Accepted | M00 / T0006 | 2026-11-16 |
| [D0030](D0030-three-part-host.md) | The host implementation has three parts in three languages, connected through the typed core | Accepted | M00 / T0006 | 2026-11-16 |
| [D0031](D0031-rust-host-interpreter.md) | The host interpreter is written in Rust | Accepted | M00 / T0006 | 2026-11-16 |
| [D0032](D0032-ocaml-host-compiler.md) | The host compiler is written in OCaml | Accepted | M00 / T0006 | 2026-11-16 |
| [D0033](D0033-zig-host-vm.md) | The host VM is written in Zig | Accepted | M00 / T0006 | 2026-11-16 |
| [D0034](D0034-idiomatic-code-per-part.md) | Each host part is idiomatic for its language; the self-hosted compiler is designed fresh | Accepted | M00 / T0006 | 2026-11-16 |
| [D0035](D0035-pinned-toolchains-and-recorded-libraries.md) | Toolchains are pinned; third-party libraries are allowed when recorded and locked | Accepted | M00 / T0006 | 2026-11-16 |
| [D0036](D0036-trailing-implementation-track.md) | Implementation is a trailing track that starts once M01 and M02 have closed | Accepted | M00 / T0007 | 2026-11-16 |
| [D0037](D0037-implementation-milestones-and-tasks.md) | Implementation milestones I1, I2, … with tasks in the shared series; one Active task per track | Accepted | M00 / T0007 | 2026-11-16 |
| [D0038](D0038-m16-merged-into-implementation-milestones.md) | M16 is merged into I1–I3; each implementation milestone opens with its own design tasks | Accepted | M00 / T0007 | 2026-11-16 |
| [D0039](D0039-four-implementation-stages.md) | Four implementation stages, I1–I4, with common exit criteria | Accepted | M00 / T0007 | 2026-11-16 |
| [D0040](D0040-design-milestones-kept.md) | The design milestones are kept as drafted, with corrected dependencies and scopes | Accepted | M00 / T0007 | 2026-11-16 |
| [D0041](D0041-spec-v1-after-i4.md) | Spec v1.0 is published only after I4 | Accepted | M00 / T0007 | 2026-11-16 |
| [D0042](D0042-tree-walker-and-bytecode-vm.md) | QubeC runs on a tree-walking interpreter and a bytecode VM; no JIT is planned | Accepted | M01 / T0009 | 2026-11-17 |
| [D0043](D0043-native-code-after-v1.md) | Native code comes after Spec v1.0, and no feature may need a VM at run time | Accepted | M01 / T0009 | 2026-11-17 |
| [D0044](D0044-executables-and-unstable-bytecode.md) | A build produces a self-contained executable; bytecode can be emitted but is unstable | Accepted | M01 / T0009 | 2026-11-17 |
| [D0045](D0045-run-is-a-shortcut.md) | `run` behaves as build-then-execute; the engine is the implementation's choice | Accepted | M01 / T0009 | 2026-11-17 |
| [D0046](D0046-first-platforms-and-tiers.md) | Linux x86-64 and macOS arm64 come first; platforms are supported in three tiers | Accepted | M01 / T0009 | 2026-11-17 |
| [D0047](D0047-platform-parity.md) | Platforms fall under the host-leads rule; back ends do not | Accepted | M01 / T0009 | 2026-11-17 |
| [D0048](D0048-trace-and-outcome.md) | Observable behavior is the trace of interactions with the environment, followed by one outcome | Accepted | M01 / T0010 | 2026-11-17 |
| [D0049](D0049-precise-panics.md) | Panics are precise, and no engine, profile, or optimization changes observable behavior | Accepted | M01 / T0010 | 2026-11-17 |
| [D0050](D0050-panic-contents.md) | A panic's kind, message, and source location are observable; a backtrace is not | Accepted | M01 / T0010 | 2026-11-17 |
| [D0051](D0051-deterministic-sequential-language.md) | The sequential language is deterministic across implementations and platforms, resource exhaustion excepted | Accepted | M01 / T0010 | 2026-11-17 |
| [D0052](D0052-bit-identical-floats.md) | Floating-point results are bit-identical on every implementation and platform | Accepted | M01 / T0010 | 2026-11-17 |
| [D0053](D0053-resource-exhaustion.md) | Resource exhaustion may happen at different points above a guaranteed floor, and truncates the trace | Accepted | M01 / T0010 | 2026-11-17 |
| [D0054](D0054-implementation-limits-as-rules.md) | Structural implementation limits are exact rejection rules; sizes are limited only by resources | Accepted | M01 / T0010 | 2026-11-17 |
| [D0055](D0055-runtime-contract-and-runtimes.md) | One runtime contract, two independent host runtimes, and a runtime in QubeC for native code | Accepted | M01 / T0011 | 2026-11-17 |
| [D0056](D0056-thin-natives.md) | Natives are thin and declared in the standard library's source | Accepted | M01 / T0011 | 2026-11-17 |
| [D0057](D0057-forms-of-main.md) | `main` takes one of two forms, and arguments come from a library procedure | Accepted | M01 / T0011 | 2026-11-17 |
| [D0058](D0058-exit-statuses.md) | Exit statuses are 0, 1, 101 for a panic, and 102 for resource exhaustion | Accepted | M01 / T0011 | 2026-11-17 |
| [D0059](D0059-report-line-and-backtrace.md) | A panic or exhaustion is reported in one specified line on standard error, then an optional backtrace | Accepted | M01 / T0011 | 2026-11-17 |
| [D0060](D0060-termination-by-the-environment.md) | A run ended from outside has the outcome "terminated by the environment," abruptly by default | Accepted | M01 / T0011 | 2026-11-17 |
| [D0061](D0061-failed-standard-output.md) | A closed reader of standard output or error ends the run quietly; any other failed write to them panics | Accepted | M01 / T0011 | 2026-11-17 |
| [D0062](D0062-guaranteed-depth-and-stack-cap.md) | The guaranteed depth is 100,000 nested calls of bounded frames; runtimes have a raisable stack cap | Accepted | M01 / T0011 | 2026-11-17 |
| [D0063](D0063-program-phases.md) | A program is checked, then its constants are evaluated, then it runs; types do not mention constant values | Accepted | M01 / T0012 | 2026-11-17 |
| [D0064](D0064-every-constant-once.md) | Every constant is evaluated exactly once, used or not, in an order that is not observable | Accepted | M01 / T0012 | 2026-11-17 |
| [D0065](D0065-cycles-found-during-evaluation.md) | A cycle between constants is found during evaluation and is a rejection | Accepted | M01 / T0012 | 2026-11-17 |
| [D0066](D0066-constants-independent-of-generic-parameters.md) | A constant does not depend on an enclosing generic parameter | Accepted | M01 / T0012 | 2026-11-17 |
| [D0067](D0067-constant-values-without-mutable-state.md) | A constant may have any type, but its value contains no mutable state | Accepted | M01 / T0012 | 2026-11-17 |
| [D0068](D0068-only-pure-code-at-compile-time.md) | Only pure code runs at compile time, and a constant's value depends on the source alone | Accepted | M01 / T0012 | 2026-11-17 |
| [D0069](D0069-compile-time-panic-is-a-rejection.md) | A panic while evaluating a constant is a rejection | Accepted | M01 / T0012 | 2026-11-17 |
| [D0070](D0070-compile-time-step-floor-and-cap.md) | Compile-time evaluation has a guaranteed number of steps per constant, a raisable cap, and a per-constant raise | Accepted | M01 / T0012 | 2026-11-17 |
| [D0071](D0071-dbg-at-compile-time.md) | `dbg` output from compile-time evaluation is shown during the build and never replayed at run time | Accepted | M01 / T0012 | 2026-11-17 |
| [D0072](D0072-source-only-meaning.md) | A program's meaning comes from source alone; compiled units are caches | Accepted | M01 / T0013 | 2026-11-17 |
| [D0073](D0073-acyclic-multi-file-units.md) | A unit is one or more source files, and units form an acyclic graph | Accepted | M01 / T0013 | 2026-11-17 |
| [D0074](D0074-reproducible-artifacts.md) | A build is identified by its inputs, and our implementations give byte-identical artifacts on any host | Accepted | M01 / T0013 | 2026-11-17 |
| [D0075](D0075-build-record.md) | Every executable carries a record of its build, which tools can read and programs cannot | Accepted | M01 / T0013 | 2026-11-17 |
| [D0076](D0076-source-names.md) | Every source file has a source name, its unit's name followed by its path in the unit | Accepted | M01 / T0013 | 2026-11-17 |
| [D0077](D0077-location-text.md) | A source location is written as source name, line, and column | Accepted | M01 / T0013 | 2026-11-17 |
| [D0078](D0078-w3c-ebnf-notation.md) | The grammar is written in W3C EBNF, with exclusion limited to finite sets in the lexical grammar | Accepted | M02 / T0014 | 2026-11-17 |
| [D0079](D0079-two-grammar-layers.md) | The grammar has a lexical layer and a syntactic layer, told apart by naming, with explicit tokens and trivia | Accepted | M02 / T0014 | 2026-11-17 |
| [D0080](D0080-staged-grammar-checker.md) | The grammar is checked in three stages: structure, a reference lexer, and conflicts | Accepted | M02 / T0014 | 2026-11-17 |
| [D0081](D0081-ocaml-grammar-checker.md) | The grammar checker is an OCaml program in tools/grammar/, independent of both implementations | Accepted | M02 / T0014 | 2026-11-17 |
| [D0082](D0082-grammar-rejection-rules.md) | Lexical failures have named rules with a fallback, and parse failures share one rule | Accepted | M02 / T0014 | 2026-11-17 |
