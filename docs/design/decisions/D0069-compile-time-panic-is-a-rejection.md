# D0069: A panic while evaluating a constant is a rejection

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

Every constant is evaluated before the program runs ([D0064](D0064-every-constant-once.md)). What does it mean when
that evaluation panics ([D0049](D0049-precise-panics.md))? Exhausting a resource while compiling is reported and is not
a rejection ([D0053](D0053-resource-exhaustion.md)), because exhaustion is a property of the machine. A panic is
deterministic ([D0051](D0051-deterministic-sequential-language.md)), so every implementation sees the same one.

## Options considered

The scenario for every option (provisional syntax):

```
const TABLE: ImmutableList[Int] = ImmutableList.of([10, 20, 30]);
const FOURTH: Int = TABLE[3];                 // index out of bounds while being evaluated

proc main() {
  println("start");
  println(FOURTH.to_str());
}
```

### A. A rejection

The program is not conforming and is never run; the diagnostic carries the rule ID and should show the panic's kind,
message, and location ([D0050](D0050-panic-contents.md)).

- **Easy:** "the program compiled" means every constant has a value; the error appears where the author is.
- **Hard:** a rejection rule must be decidable ([D0018](D0018-diagnosis-and-rule-ids.md)), and a constant that never
  finishes never panics; the bound of [D0070](D0070-compile-time-step-floor-and-cap.md) settles this.
- **Prior art:** Rust rejects the program (error E0080, verified by running it,
  [R0010](../research/R0010-compile-time-evaluation-prior-art-and-pilots.md)); C++ and Zig make it a compile error
  (recalled).

### B. A panic at the start of every run

The program builds; every run panics before `main`, with an empty trace, the report line, and status 101.

- **Hard:** an artifact that can never run is produced on purpose; a run gains a new way to start.
- **Prior art (recalled):** Go's package-level variable initializers panic at program start (those are run-time
  variables, not constants).

### C. A panic at the first use

The run prints `start`, then panics where `FOURTH` is first used.

- **Hard:** acceptance depends on use, against D0064; every use of a constant becomes a possible panic point; artifacts
  carry a "poisoned" marker.
- **Prior art (recalled):** Java's static initializers (`ExceptionInInitializerError`), Kotlin's `by lazy`.

Recommendation at the time: **A**, with D0070 making the rule decidable.

## Choice

**A.**
1. **[R-const-panic]** If evaluating a constant panics, the program is rejected.
2. A diagnostic for this rule should give the panic's kind, message, and source location, as a run's report line
   would; [spec §1.2.2](../../spec/01-introduction.md#122-reporting) still requires only the rule ID.
3. Resource exhaustion while evaluating a constant is not a panic: it is reported, not a rejection (D0053, D0070).

## Rationale

A panic in a constant is a fault of the program that every implementation detects identically, so it belongs with
the rejections. Shipping it to the run would produce artifacts known to fail and would make the start or the uses of a
program fail in ways §1.2.7 does not describe. Exhaustion stays separate, as the one thing that depends on the
machine.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 10.
- **M15:** the diagnostic shows the panic in the same terms as a run's report line
  ([OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter)), with
  the chain of constants being evaluated.
- **Conformance suite:** a program whose constant panics within the guarantee of D0070 is a rejection test
  (`expect: reject R-const-panic`).

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rule 10
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
