# D0071: `dbg` output from compile-time evaluation is shown during the build and never replayed at run time

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

`dbg(e)` writes the source of `e` and its value to standard error and returns the value; its output is not observable
and "may be printed at build time, if at all" ([D0008](D0008-purity.md), [D0048](D0048-trace-and-outcome.md)). Should
we recommend that compilers show `dbg` output produced while evaluating constants?

## Options considered

The scenario for every option (provisional syntax):

```
func area(w: Int, h: Int) -> Int = dbg(w * h);
const N: Int = area(2, 3);                    // evaluated during the build
proc main() { println(area(4, 5).to_str()); }
```

### A. Shown during the build, never replayed at run time

A compiler should write it to its diagnostic output, marked with the constant it came from. A run never repeats it,
since the constant was evaluated once, during the build.

```
$ qubec run geo.qbc
[const N] [geo.qbc:1:36] w * h = 6      (while building)
[geo.qbc:1:36] w * h = 20               (while running, on standard error)
20
```

- **Easy:** constants can be debugged in place. **Hard:** nothing beyond one recommendation.

### B. Dropped

- **Easy:** clean build output. **Hard:** a wrong constant cannot be inspected where it is computed.

### C. Unspecified, as D0008 left it

- **Hard:** users do not know whether to expect output from constants.

- **Prior art (recalled):** Zig's `@compileLog` prints during compilation but makes the compile fail; C++ `constexpr`
  has no compile-time print; Rust's `dbg!` is not usable in constants.

Recommendation at the time: **A**: debugging computed tables is a real need, and A changes no semantics.

## Choice

**A.**
1. A compiler should write the output of `dbg` during compile-time evaluation to its diagnostic output, marking the
   constant being evaluated.
2. That output is never written again when the program runs.
3. It remains not observable: a build that reuses stored constant values (T0013) may write nothing.

## Rationale

Once tables are computed at compile time, their authors need to see inside them, and `dbg` is the tool D0008 already
provides for pure code. A recommendation changes no semantics and no conformance test.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 16.
- **M14, M15:** `dbg`'s spelling and output format
  ([OQ-005](../open-questions.md#oq-005-which-spellings-replace-the-placeholder-keywords-mut-become-and-dbg)), and how a
  compiler marks compile-time output.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 16
- Grammar rules: none
- Formal rules: none
- Examples / tour: [vision.md](../vision.md)
