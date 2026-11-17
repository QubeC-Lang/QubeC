# Static Semantics

Status: skeleton. Notation follows [README.md](README.md). This file will hold two kinds of rules
([D0022](../../design/decisions/D0022-typed-elaboration-into-core.md)): **elaboration rules**, of the form
$\Gamma \vdash e : \tau \rightsquigarrow c$, over the surface language, which carry the rule IDs of rejections; and
**core typing rules** over the explicitly typed core, each naming its governing Lean definition
([D0026](../../design/decisions/D0026-lean-governs-core-rules.md)). The first rules come in M03.

No typing judgment contains evaluation, and no type mentions a constant's value
([D0063](../../design/decisions/D0063-program-phases.md)). The rules for constant declarations (`R-const-generic`,
and the static part of `R-const-mutable`) are written with declarations
([D0066](../../design/decisions/D0066-constants-independent-of-generic-parameters.md),
[D0067](../../design/decisions/D0067-constant-values-without-mutable-state.md)).

## Judgment forms

| Judgment | Reading |
| --- | --- |
| — | none yet |

## Metavariables

| Metavariable | Ranges over |
| --- | --- |
| — | none yet |

## Rules

None yet.
