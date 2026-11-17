# D0051: The sequential language is deterministic across implementations and platforms, resource exhaustion excepted

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0010 |

## Question

[D0048](D0048-trace-and-outcome.md) defines what is compared, and [D0049](D0049-precise-panics.md) rules out
differences between engines and profiles. May anything differ between **implementations** (the host implementation
and the self-hosted compiler, [D0029](D0029-permanent-host-implementation.md)) or **platforms**
([D0046](D0046-first-platforms-and-tiers.md)), given the same inputs? Floating point is decided separately
([D0052](D0052-bit-identical-floats.md)), and so is resource exhaustion ([D0053](D0053-resource-exhaustion.md)).

The program's inputs are the environment's responses in its trace: standard input, files, arguments, environment
variables, the clock, randomness, and also facts about the platform, such as whether its file system ignores case.
They may differ between runs. The question is whether the language itself may differ.

## Options considered

The scenario for every option (provisional syntax: `Map`, `for`, and `to_string` belong to M03, M05, and M14):

```
proc main() {
  let counts = Map.new();
  for w in ["b", "a", "c", "a"] { counts[w] = counts.get(w, 0) + 1; }
  for (w, n) in counts { print(w + "=" + n.to_string() + " "); }   // in which order?
  print(Int.max.to_string());                                        // sized per platform?
  print(object_id(counts).to_string());                              // an address?
}
```

### A. Fully deterministic, resource exhaustion excepted

The sequential language has no implementation-defined and no unspecified behavior. The same program with the same
inputs has the same observable behavior on every conforming implementation and platform. An implementation may use
nondeterminism internally (such as a random hash seed against hash flooding) only where it cannot be observed.

```
every implementation, every platform:
  b=1 a=2 c=1            (if M14 chooses insertion order)
  9223372036854775807    (if M05 gives Int this range; the same everywhere)
  object_id: absent, or deterministic (M07, M14)
```

- **Easy:** conformance tests compare exact traces; the self-hosted compiler's fixpoint (I3) cannot depend on
  platform quirks; the reference evaluator ([D0027](D0027-executable-reference.md)) is a function.
- **Hard:** M14 must specify the iteration order of maps and sets; M05 and M07 must keep sizes and addresses out of
  sight.
- **Prior art:** Python has guaranteed dict insertion order since 3.7; WebAssembly's nondeterminism is limited to NaN
  bits, resource exhaustion, threads, and relaxed SIMD (both verified,
  [R0008](../research/R0008-observable-behavior-prior-art-and-pilots.md)). Java fixes integer sizes (recalled).

### B. A short listed set of implementation-defined behavior

The specification lists a few items, such as map iteration order, that each implementation documents and keeps fixed.

```
host:    a=2 b=1 c=1
qubecc:  c=1 a=2 b=1          (both conform)
```

- **Easy:** runtimes may use any hash table; back ends may choose sizes.
- **Hard:** tests must avoid or normalize the listed items; the self-hosted compiler must never depend on them, by
  discipline; the semantics is parameterized by each implementation's choices.
- **Prior art (recalled):** C and C++, and their portability bugs.

### C. Unspecified and deliberately varied

Map iteration order is unspecified and randomized from run to run, so that reliance on it fails early; the seed would
have to count as an input to keep [D0023](D0023-claimed-meta-properties.md)'s "at most one outcome".

- **Easy:** accidental reliance on an order surfaces at once.
- **Hard:** runs are not reproducible without the seed; golden-file tests and the self-hosted compiler must sort.
- **Prior art:** the Go specification: "The iteration order over maps is not specified and is not guaranteed to be the
  same from one iteration to the next" (verified, R0008).

| | A Deterministic | B Listed | C Varied |
| --- | --- | --- | --- |
| Same trace across implementations and platforms | yes | except the listed items | no |
| Reference evaluator | a function | parameterized | a function of a seed |
| Cost lands on | the design of M05, M07, M14 | test normalization | every consumer |

Recommendation at the time: **A**, because two permanent implementations, the whole suite on every back end and
platform ([D0047](D0047-platform-parity.md)), and the claimed determinism with an executable reference all work best
with exact traces, and the cost is design work rather than run-time cost.

## Choice

**A.**
1. Apart from resource exhaustion (D0053), the sequential language has no implementation-defined and no unspecified
   behavior.
2. The same program with the same inputs has the same observable behavior (D0048) on every conforming
   implementation, engine, build profile, and platform, in every tier.
3. An implementation may be nondeterministic internally only where this cannot be observed.
4. Differences between platforms reach a program only as inputs: the environment's responses in the trace.
5. This record covers the sequential language. What concurrent programs may vary is decided in M10.

## Rationale

A deterministic language turns every comparison we depend on into an exact one: between the two implementations,
between engines and back ends, across the tiers of D0046, in the fixpoint, and against the reference evaluator.
Reproducible output is also a feature in its own right in the tooling domain
([D0002](D0002-purpose-and-domain.md)), where compilers and code generators are expected to give the same output for
the same input.

## Consequences

- **M05:** every integer type has the same range on every platform; nothing observable depends on the platform's word
  size.
- **M07:** no memory address, and nothing derived from one, is observable.
- **M10:** must state explicitly what concurrent programs may vary (scheduling, the interleaving of events).
- **M14:** maps and sets have a specified iteration order; any hash seed stays unobservable; natives that report
  platform facts are inputs.
- **Formal:** D0023's determinism is stated as "for each sequence of responses, at most one trace and outcome".
- **Conformance suite:** a test's expected trace and outcome are the same on every implementation and platform.

## Affected artifacts

- Spec: [§1.2.5](../../spec/01-introduction.md#125-observable-behavior-and-determinism) (new)
- Grammar rules: none
- Formal rules: property 5 in [metatheory.md](../../spec/formal/metatheory.md)
- Examples / tour: none
