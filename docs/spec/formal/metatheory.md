# Metatheory

Status: skeleton. This file states the meta-properties we claim about QubeC, each with its proof or proof sketch and
a link to the mechanized proof where there is one. No proofs exist yet; the first mechanized ones come in M03
([D0028](../../design/decisions/D0028-mechanization-starts-in-m03.md)).

A mechanized proof (for core properties) or a proof sketch here (for elaboration properties) is one of the
requirements for promoting a chapter's aspect to formally complete
([D0016](../../design/decisions/D0016-authority-per-section.md), [D0024](../../design/decisions/D0024-mechanize-the-core.md)).

## Claimed properties

All of them are claimed for the formal target, the whole sequential language
([D0021](../../design/decisions/D0021-formal-target-sequential-language.md),
[D0023](../../design/decisions/D0023-claimed-meta-properties.md)). Property 7 was added by
[D0053](../../design/decisions/D0053-resource-exhaustion.md) and extended to termination by the environment by
[D0060](../../design/decisions/D0060-termination-by-the-environment.md).

| # | Property | Statement | Proof | Status |
| --- | --- | --- | --- | --- |
| 1 | Core type soundness | A well-typed core program finishes with a value, panics in a defined way, or runs forever; it never gets stuck (progress and preservation). | mechanized (Lean) | not started (M05) |
| 2 | Elaboration soundness | If $\Gamma \vdash e : \tau \rightsquigarrow c$, then $c$ is a well-typed core term of the elaborated type. | paper sketch | not started |
| 3 | Purity soundness | Evaluating a call of a `func` performs no observable effect, and every value that existed before the call is unchanged after it (the frame property; [D0008](../../design/decisions/D0008-purity.md), [D0011](../../design/decisions/D0011-local-mutation-in-functions.md)). | mechanized (Lean) | not started (M05–M07) |
| 4 | Tail-call space bound | A call marked `tailcall` does not grow the abstract machine's stack ([D0012](../../design/decisions/D0012-tail-calls-and-stacks.md), [D0014](../../design/decisions/D0014-tailcall-keyword.md)). | mechanized (Lean) | not started (M03) |
| 5 | Determinism | For every sequence of responses from the environment, a sequential program has at most one trace and one outcome ([D0048](../../design/decisions/D0048-trace-and-outcome.md), [D0051](../../design/decisions/D0051-deterministic-sequential-language.md)). | mechanized (Lean) | not started (M03) |
| 6 | Decidable checking | The inference algorithm is sound and complete with respect to the elaboration rules, and on rejection names the rule ID of a violated rule ([D0018](../../design/decisions/D0018-diagnosis-and-rule-ids.md)). | paper sketch | not started (M05–M06) |
| 7 | Exhaustion and termination truncate the trace | A run that exhausts a resource, or that the environment ends, has, as its trace, a prefix of the trace that the abstract machine gives the same program for the same responses, and no other outcome than resource exhaustion or termination by the environment, respectively ([D0053](../../design/decisions/D0053-resource-exhaustion.md), [D0060](../../design/decisions/D0060-termination-by-the-environment.md)). | paper sketch | not started (M03) |

The reference evaluator and the reference checker are proved to agree with the core rules
([D0027](../../design/decisions/D0027-executable-reference.md)). Those agreement proofs are part of the mechanization,
not claimed properties of the language.

Referential transparency (two calls of a `func` with equal arguments give interchangeable results) is not claimed. M07
or M13 may add it by a new decision.
