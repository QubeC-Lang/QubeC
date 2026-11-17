# D0070: Compile-time evaluation has a guaranteed number of steps per constant, a raisable cap, and a per-constant raise

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0012 |

## Question

A panic in a constant is a rejection ([D0069](D0069-compile-time-panic-is-a-rejection.md)), and every rejection rule
must be decidable ([D0018](D0018-diagnosis-and-rule-ids.md)). A constant that never finishes never panics, and no
compiler can tell a non-terminating constant from a long one. Stack and memory while compiling are already covered:
exhausting them is reported, not a rejection ([D0053](D0053-resource-exhaustion.md)). How is the number of steps
bounded, and with what values?

## Options considered

The scenario for every option (provisional syntax):

```
func collatz(n: Int) -> Int =
  if n == 1 { 0 } else if n % 2 == 0 { 1 + collatz(n / 2) } else { 1 + collatz(3 * n + 1) };
const STEPS: ImmutableList[Int] = ImmutableList.range(1, 1_000_000).map(collatz);  // big but finite

func spin(n: Int) -> Int = tailcall spin(n + 1);
const NEVER: Int = spin(0);                                                       // never finishes
```

### A. An exact, deterministic budget

The specification defines a step precisely; every implementation counts identically and rejects a constant that
exceeds its budget at the same step; the budget is raised per constant in source.

- **Easy:** acceptance is perfectly portable; the reference's fuel is the same number.
- **Hard:** three implementations and the reference must agree on counts exactly, so any desugaring difference shifts
  them and the suite needs tests one step either side of the budget; authors raise budgets whenever a table grows.
- **Prior art:** Zig counts backward branches with a default quota of 1,000, raised in source with
  `@setEvalBranchQuota`, and its standard library sets quotas in the millions (verified from secondary sources,
  [R0010](../research/R0010-compile-time-evaluation-prior-art-and-pilots.md)); Zig has one implementation.

### B. A guaranteed number of steps, like the guaranteed depth

Every implementation must finish a constant that needs at most a guaranteed number of steps; beyond it, an
implementation may stop at a cap of its own, which an input of the build raises. Stopping is compile-time exhaustion:
reported, not a rejection, and the program is not run, as D0053 says for stack and memory.

- **Easy:** no exact counting, so the unit matters only for the guarantee; one model for every resource at compile
  time and at run time ([D0062](D0062-guaranteed-depth-and-stack-cap.md)).
- **Hard:** whether a constant that costs more than the guarantee builds may differ between implementations.
- **Prior art (verified, R0010):** Clang's default constexpr limit is 2^20 steps (`-fconstexpr-steps`) and GCC's
  2^25 operations, each set by its own compiler; Rust 1.72 removed its fixed limit, which kept breaking legitimate code,
  and now raises a deny-by-default lint after about a million calls and loop back-edges, which a constant may allow.

### C. No bound on steps

Evaluation runs until it finishes, panics, or exhausts stack or memory; `NEVER` hangs the compiler.

- **Hard:** builds and the REPL can freeze; no guarantee for library authors; a diverging constant would be conforming
  but could never run.

Recommendation at the time: **B**, which reuses the model chosen for stack depth and avoids exact agreement between
three implementations and the reference.

### Values

A pilot (R0010) measured a naive Rust tree-walker at about 30 million calls per second in a release build and 7 million
in a debug build; a full evaluator is likely several times slower, and `qubecc`'s evaluator, written in QubeC and run
on the VM, perhaps 0.3 to 3 million steps per second (an estimate). Three pairs were considered: a guarantee of
1,000,000 steps with a host cap of 100,000,000; 10,000,000 with 1,000,000,000; and 100,000,000 with 10,000,000,000.
The middle pair covers a table computed over all 1.1 million Unicode code points at a few calls each, and costs at
most about 3 to 30 seconds on the slowest planned engine.

### A per-constant raise

Writing the raise in the source, on the constant, makes it part of the program, so the guarantee travels with the
code to every implementation; a build flag is local to one machine. It is Zig's quota as a guarantee rather than an
exact budget, and Rust's per-constant `allow` with a stated number rather than no limit. A form with no limit was
considered and not chosen, because one dependency's mistake would then hang every user's build.

## Choice

**B, with a guarantee of 10,000,000 steps, a host cap of 1,000,000,000, and a per-constant raise.**
1. **A step** is one call, of any callable (library functions written in QubeC, pure natives, `tailcall`s, and calls
   of function values), or one iteration of a loop. Steps are counted on the program as written, together with the
   standard library's source, not on an implementation's internal form. Which constructs are loops is stated with
   them (M03).
2. **Per constant.** Each constant is charged only for its own initializer. Reading another constant costs no steps,
   so counts do not depend on the order of evaluation ([D0064](D0064-every-constant-once.md)).
3. **The guaranteed number of steps** of a constant is 10,000,000, or the number given by its raise if that is
   larger. Every conforming implementation MUST finish evaluating a constant that needs no more steps than its
   guarantee, no more nested calls than the guaranteed depth (D0062), and no more memory than is available, and then
   gives the same result as every other: a value, or a rejection.
4. **The raise.** A constant's declaration may carry a raise stating a number of steps; it applies to that constant's
   initializer only. Its syntax is
   *Provisional ([OQ-015](../open-questions.md#oq-015-how-is-the-raise-of-a-constants-guaranteed-steps-written))*;
   attributes are M11's.
5. **The cap.** Each implementation has a step cap of its own for each constant, at least that constant's guarantee.
   In the host implementation it is 1,000,000,000 steps, or the constant's raise if that is larger. An input of the
   build raises it; its name is M15's.
6. **Exhaustion.** An implementation that reaches its cap stops evaluating, reports that compile-time evaluation ran
   out of steps, and does not run the program. That is not a rejection (D0053 rule 5 extended to steps). Above the
   guarantee, where an implementation stops is not specified.
7. **Reporting (non-normative).** While a constant runs long, an implementation may write progress notes; when a
   constant needed more steps than its guarantee, an implementation should say so and suggest a raise. Neither is
   observable.

## Rationale

A guarantee, a raisable cap, and exhaustion that is reported rather than rejected is the model we chose for stack
depth; using it for steps gives one rule for every resource, and it avoids exact agreement on counts between the host
implementation, `qubecc`, and the reference. A step of calls and loop iterations is the unit Rust's compiler uses, and
between two steps the work is bounded by the size of the code. Ten million steps covers ordinary tables, including
Unicode-sized ones, in seconds on the slowest engine we plan. The raise lets the rare heavy constant say what it needs,
in its source, so every implementation honors it; the cap reports a runaway constant within minutes in the host.

## Consequences

- **Spec:** [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rules 11–15;
  [§1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) rule 4 cross-refers.
- **[OQ-015](../open-questions.md#oq-015-how-is-the-raise-of-a-constants-guaranteed-steps-written)** (new): the
  syntax of the raise (M11, with M04 for declarations).
- **M03:** names the loop constructs that count as steps.
- **M15:** the name of the build input that raises the cap; progress notes and the portability warning.
- **D0027's reference:** runs constants with fuel of at least their guarantee; running out of fuel stays inconclusive.
- **I1, I3:** each compile-time evaluator counts steps and enforces a cap at least the guarantee; tests at the
  guarantee must finish on every implementation.

## Affected artifacts

- Spec: [§1.2.8](../../spec/01-introduction.md#128-program-phases-and-compile-time-evaluation) rules 11–15,
  [§1.2.6](../../spec/01-introduction.md#126-resource-exhaustion-and-implementation-limits) rule 4
- Grammar rules: none
- Formal rules: none yet ([dynamic.md](../../spec/formal/dynamic.md) note)
- Examples / tour: [vision.md](../vision.md)
