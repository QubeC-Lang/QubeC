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
