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

A program is checked as a set of units in dependency order: the typing context of a unit holds the declarations of
all of its own files and the interfaces of the units it depends on, so the rules range over one unit at a time
([D0073](../../design/decisions/D0073-acyclic-multi-file-units.md)). `R-unit-cycle` is a condition on the dependency
graph, stated in prose in [spec §1.2.9](../01-introduction.md#129-units-builds-and-source-names); the form of a unit's
interface is fixed in M09.

Elaboration rules range over parsed source files: a file that does not tokenize, or whose token sequence does not
derive from `SourceFile`, is rejected by `R-token-invalid`, a named lexical rule, or `R-syntax` before any rule here
applies. These grammar rules are stated in prose and in the grammar file
([spec §1.3.8](../01-introduction.md#138-rejection-by-the-grammar),
[D0082](../../design/decisions/D0082-grammar-rejection-rules.md)); lexing and parsing have no formal rules here.

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
