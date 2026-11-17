# D0047: Platforms fall under the host-leads rule; back ends do not

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

[D0029](D0029-permanent-host-implementation.md) says that every feature lands in the host implementation first, that
`qubecc` never has a feature the host lacks, and that the build from source (host implementation → `qubecc`) is a
release step. It does not say whether a **back end** (bytecode, or native code after
[D0043](D0043-native-code-after-v1.md)) or a **platform** ([D0046](D0046-first-platforms-and-tiers.md)) counts as a
feature. What D0029 protects is the build from source: anyone can build `qubecc` without trusting a binary.

## Options considered

The scenario for every option: after v1.0, `qubecc` gains a native back end, and `linux-riscv64` moves to Tier 1.

```
$ qubecc build --native --target linux-riscv64 wc.qbc    # provisional flags (M15)
# Must the host implementation already have (a) a native back end? (b) linux-riscv64?
```

### A. Both outside the rule

Each implementation picks its own back ends and platforms; every target it has passes the whole suite.

- **Easy:** the least work.
- **Hard:** on a platform only `qubecc` supports, building `qubecc` needs a trusted binary, which weakens the build
  from source.
- **Prior art (recalled):** Go's gc and gccgo support different platform sets.

### B. Both under the rule

The host implementation gets every back end and platform first.

- **Easy:** the plainest reading of D0029.
- **Hard:** every back end is written twice; the host's native back end would exist only for the rule, since the host
  VM already builds `qubecc`.

### C. Platforms under the rule, back ends not

For every platform `qubecc` supports, the host implementation can build `qubecc` for that platform, and gains that
ability first; cross-building counts. `qubecc` may have back ends the host lacks.

- **Easy:** the build from source holds on every supported platform; native code is written once.
- **Hard:** the host VM must be ported to every platform `qubecc` supports, which is cheap because the Zig VM
  cross-compiles.
- **Prior art (recalled):** Rust's bootstrap guarantees depend on a platform's tier; Guix's full-source bootstrap is
  per architecture.

| | A Outside | B Both under | C Platforms only |
| --- | --- | --- | --- |
| Build from source on every platform | no | yes | yes |
| Back ends written | once | twice | once |
| Cost | lowest | highest | low |

Recommendation at the time: **C**, because it gives D0029's build from source on every platform at the lowest cost.

## Choice

**C.** This clarifies the scope of D0029.
1. **Platforms** fall under the rule: for every platform `qubecc` supports, the host implementation can build `qubecc`
   for that platform, and gains that ability first. Cross-building counts.
2. **Back ends** are not features under D0029: either implementation may have a back end the other lacks.
3. **Every back end passes:** every back end of either implementation passes the whole conformance suite on each
   platform it supports, at the tier's frequency (D0046).

## Rationale

D0029's release rule exists so that `qubecc` can always be built from source without a trusted binary. Platform
parity keeps that true everywhere at little cost. Back-end parity would double every back end without protecting the
build from source, and the shared suite already checks every back end against the same specification.

## Consequences

- **Before v1.0** the rule's back-end half has no effect: both compilers target the host VM
  ([D0042](D0042-tree-walker-and-bytecode-vm.md)).
- **I3:** the platform half binds from the first fixpoint: `qubecc`'s platforms are a subset of what the host can
  build for.
- **M17:** the post-v1.0 plan may give native code to `qubecc` alone.
- **D0039's common exit criteria** are unchanged: I1–I4 add no back end beyond bytecode.

## Affected artifacts

- Spec: none (implementation strategy)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
