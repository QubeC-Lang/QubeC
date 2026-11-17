# D0029: The host implementation is permanent and leads every feature

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

QubeC aims to self-host ([D0002](D0002-purpose-and-domain.md)): eventually its compiler, the **self-hosted compiler**
(working name `qubecc`), is written in QubeC. Before that, a first implementation must be written in an existing
language: the **host implementation**. Self-hosting is confirmed by the **fixpoint check**: `qubecc` compiled by
itself twice produces identical output. What is the host implementation for once that check passes? The answer
decides how the host language is judged: a scaffold that is discarded is chosen for speed of development, a
codebase maintained for decades for longevity.

## Options considered

The scenario for every option: two years after self-hosting, (1) we add `match` guards, and (2) someone on a fresh
machine builds QubeC 2.3 from source without trusting any binary. Command lines are illustrative.

### A. A throwaway bootstrap

The host exists only to compile `qubecc` the first time. After the fixpoint check passes, it is frozen and archived,
and each release is built by the previous release.

```
# (1) add match guards
edit qubecc/…            # only qubecc changes; the frozen host never learns guards
# (2) build 2.3 from source
build host (frozen) → qubecc 1.0 → 1.1 → … → 2.2 → 2.3   # a chain of releases
```

- **Easy:** no double maintenance; the host may cut corners (slow, few diagnostics).
- **Hard:** a build from source needs the chain of releases; the compiler's own source adopts a feature one release
  late; nothing independently cross-checks the front end any more (the Lean reference,
  [D0027](D0027-executable-reference.md), still checks the core).
- **Locks in / rules out:** the host language is chosen for development speed alone.
- **Prior art:** Rust discarded its OCaml bootstrap, and a build from source needs a long chain, which is why the
  independent C++ implementation `mrustc` exists (recalled). Go 1.5 removed C from its compiler and runtime, and later
  builds need an earlier Go (verified, [R0005](../research/R0005-host-language-prior-art-and-pilots.md)).

### B. A permanent second implementation that leads every feature

The host is maintained forever as a complete implementation. Every feature lands in it first, and both
implementations pass the whole conformance suite at every release.

```
# (1) add match guards
edit host/…   AND   edit qubecc/…       # twice, forever
# (2) build 2.3 from source
build host (current) → qubecc 2.3       # one step, no chain
```

- **Easy:** ambiguous spec rules surface as disagreements between the two implementations; builds from source take
  one step; diverse double-compiling (compiling the compiler with two independent compilers to detect a planted
  backdoor) becomes possible.
- **Hard:** every feature is built twice for the life of the language.
- **Locks in / rules out:** the host language must be one we are content to maintain indefinitely.
- **Prior art (recalled):** Go's two compilers, gc and gccgo, which found spec ambiguities between them.

### C. A kept, limited bootstrap

The host is maintained only as far as building `qubecc` from source needs: `qubecc`'s own source keeps to a
**bootstrap subset** that the host supports, and user-facing work (REPL, diagnostics, new features) moves to
`qubecc`.

```
# (1) add match guards
edit qubecc/…                    # the host learns guards only if qubecc's source starts using them
# (2) build 2.3 from source
build host (current subset) → qubecc 2.3   # one step
```

- **Easy:** one-step builds from source at a bounded cost.
- **Hard:** a subset rule binds `qubecc`'s source, and the host must keep up with that subset.
- **Prior art (recalled):** `mrustc`; GNU Mes for full-source bootstraps; OCaml's checked-in bytecode boot compiler.

### D. Decide in M16

Choose the host language now under the assumption that it may become permanent, and let M16 (which owns
bootstrapping) pick A, B, or C later. In practice the candidates are then judged by B's criteria.

| | A Throwaway | B Permanent, leads | C Kept subset | D Decide in M16 |
| --- | --- | --- | --- | --- |
| Long-term cost | lowest | highest (×2 forever) | bounded | unknown |
| Build from source | release chain | one step | one step | — |
| Independent front-end check | none after freeze | yes | partial | — |
| Language judged on | development speed | longevity | longevity, subset only | longevity |

Recommendation at the time: **C**, on the grounds that the verified reference already cross-checks the core
semantics, so B's extra benefit is a second front end, which seemed not to justify doubling every feature.

## Choice

**B.**
1. The host implementation is **permanent**: it is never frozen or archived, and is maintained for as long as QubeC
   is.
2. It **leads every feature**: a language or library feature is implemented in the host implementation first, and at
   every commit `qubecc` implements no feature that the host implementation lacks. The host implementation may have
   more (such as its tree-walking interpreter and REPL).
3. Once QubeC self-hosts, every release requires both implementations to pass the whole conformance suite for that
   spec version, and checks both the build from source (host implementation → `qubecc`) and the fixpoint.
4. `qubecc`'s own source may use a feature in the same release that adds it, because the host implementation can
   already build that source.

## Rationale

We want QubeC to have two complete, independent implementations of its specification, not one compiler and a
discarded scaffold. The Lean reference checks the core, but nothing formal checks elaboration from surface to core
([D0024](D0024-mechanize-the-core.md) leaves that proof on paper); a second complete front end is the practical
cross-check for exactly that part. Two implementations also flush out ambiguous rules, make diverse double-compiling
possible, and let anyone build `qubecc` from source in one step. "The host leads" is the only rule under which
"`qubecc` has nothing the host lacks" holds at every commit, and it keeps the REPL as the place where every design is
tried first. We accept that every feature is implemented twice, for good.

## Consequences

- **T0006:** the host languages are judged for longevity: maintainability, toolchain stability, and diagnostics
  quality ([D0030](D0030-three-part-host.md)–[D0035](D0035-pinned-toolchains-and-recorded-libraries.md)).
- **M15, M16:** the conformance harness runs every implementation (host, `qubecc`, and the reference for core); M16
  plans the build from source and the fixpoint check as release steps.
- **Every feature milestone** is implemented in the host first; its implementation cost counts twice.
- **T0007:** weighs the implementation load (a permanent host plus `qubecc`) when confirming the milestone plan.
- `qubecc` is a working name, to be fixed when the self-hosted compiler is planned (M16).

## Affected artifacts

- Spec: none (implementation strategy is not normative)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [vision.md](../vision.md) (how QubeC is implemented)
