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
