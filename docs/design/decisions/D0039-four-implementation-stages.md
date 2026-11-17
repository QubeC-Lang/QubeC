# D0039: Four implementation stages, I1–I4, with common exit criteria

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0007 |

## Question

Where does the implementation track ([D0036](D0036-trailing-implementation-track.md),
[D0037](D0037-implementation-milestones-and-tasks.md)) cut into milestones, and what does each one have to show
before it exits? The cuts decide when each host part ([D0030](D0030-three-part-host.md): the Rust host interpreter,
the OCaml host compiler, the Zig host VM) and the self-hosted compiler `qubecc` are built, and which design
milestones each stage waits for. Because the track trails the design, an implementation milestone implements only
closed design milestones.

## Options considered

The scenario for every option: when is the host VM's garbage collector first written, and has M07 (memory) decided
the memory model by then?

### A. Four stages

1. **I1, front end and core interpreter:** implements M01–M05 as they close: scanner, parser, names, types,
   elaboration, the tree-walking interpreter, the REPL, and the driver.
2. **I2, host complete for the core language:** extends the host interpreter through M06–M09 and M14, and builds the
   host compiler and host VM for everything so far.
3. **I3, `qubecc` and the fixpoint.**
4. **I4, the remaining features:** M10–M12 in the host implementation first, then in `qubecc`.

```
design: M01 M02 M03 M04 M05 M06 M07 M08 M09 M14 │ M10 M11 M12 …
I1  ──── scanner … types, interpreter, REPL ──┤ (Rust)
I2                    interpreter → M14; compiler (OCaml)
                      + VM and GC (Zig) ──────────┤
I3                                   qubecc, fixpoint ┤
I4                                        M10–M12 in both
GC: written in I2, after M07
```

- **Easy:** the VM's memory management is written once, after M07 decides it.
- **Hard:** I2 is large (two new codebases plus the interpreter's growth), and the three-part pipeline runs end to end
  only from I2.

### B. Five stages, with an early back end

As A, but a stage after I1 builds the host compiler and host VM for the M03–M05 core (deciding OQ-008 and OQ-009),
before the host is completed through M14.

```
I1  front end + interpreter (M01–M05)
I2  compiler + VM for the M03–M05 core; OQ-008, OQ-009
I3  all three parts through M14
I4  qubecc + fixpoint
I5  M10–M12 in both
GC: provisional in I2, real in I3 (after M07)
```

- **Easy:** the three-part pipeline, the interchange format, and D0030's bytecode-VM assumption are tested early on
  a small core.
- **Hard:** the VM's memory management is written before M07: either a placeholder that M07 likely replaces, or a
  collector M07 has to accommodate.

### C. Three stages

```
I1  host complete: Rust + OCaml + Zig, trailing design M01 … M14
I2  qubecc + fixpoint
I3  M10–M12 in both
```

- **Easy:** the fewest stages.
- **Hard:** I1 spans most of the design track, so its exit says little about progress.

| | A Four | B Five | C Three |
| --- | --- | --- | --- |
| Three-part pipeline first runs end to end | I2 (after M09) | I2 (after M05) | inside I1 |
| GC written before M07 | no | provisionally | no |
| Largest stage | I2 | moderate | I1, very large |

Recommendation at the time: **A**, the only shape that writes the VM's memory management once, after M07; B's early
pipeline test was noted as a real benefit.

## Choice

**A.**
1. **The stages:**

   | ID | Stage | Implements | Builds | Stage target |
   | --- | --- | --- | --- | --- |
   | I1 | Front end and core interpreter | M01–M05 | the host interpreter (Rust): scanner, parser, name resolution, type and purity checking, elaboration into the core, the tree-walking interpreter, the REPL, the driver | `qubec run` and the REPL work for the M01–M05 language; the conformance harness exists |
   | I2 | Host complete for the core language | M06–M09, M14 | the host interpreter extended; the host compiler (OCaml) and the host VM (Zig) for everything so far | the whole conformance suite so far passes on the interpreted path and the compiled path |
   | I3 | `qubecc` and the fixpoint | — | `qubecc`, in QubeC | the fixpoint check and the release checks of [D0029](D0029-permanent-host-implementation.md) pass |
   | I4 | The remaining features | M10–M12 | those features in the host implementation, then in `qubecc` | both implementations pass the whole conformance suite |

2. **Order and dependencies:** I1 starts when M01 and M02 have closed (D0036); I2 starts when I1 has exited and
   trails M06–M09 and M14; I3 starts when I2 has exited; I4 starts when I3 has exited and trails M10–M12.
3. **Common exit criteria** of every implementation milestone:
   - **P1:** every task is Done, or Dropped with a reason.
   - **P2:** the architecture decisions made in the milestone are recorded as decision records.
   - **P3:** the code builds from a clean checkout with the pinned toolchains
     ([D0035](D0035-pinned-toolchains-and-recorded-libraries.md)), and the build is documented.
   - **P4:** its unit tests, and the conformance tests for everything it implements, pass on every execution path it
     has.
   - **P5:** every divergence found between the code and the specification is resolved in the specification (by a
     fix or a revisit task) or recorded as an open question. The specification stays the authority.
   - **P6:** its stage target (item 1) is met. Throughout, `qubecc` implements no feature the host implementation
     lacks ([D0029](D0029-permanent-host-implementation.md)).
4. An implementation milestone cannot exit before every design milestone it implements has closed.

## Rationale

We chose four stages because they are the only shape that writes the VM's memory management once, after M07 has
decided it, and because each stage lines up with the design milestones it implements. I1 ends with the first running
programs and the REPL; I2 ends with the whole host implementation, so that `qubecc` in I3 is written against a host
that already implements the core language.

## Consequences

- **I1** is the first implementation milestone; its opening tasks are those of
  [D0038](D0038-m16-merged-into-implementation-milestones.md).
- **M07** is decided before any GC is written.
- **Which features `qubecc`'s own source uses** (for example whether it uses concurrency before I4) is decided by
  I3's opening task.

## Affected artifacts

- Spec: none (project plan)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none; [roadmap.md](../roadmap.md), [vision.md](../vision.md)
