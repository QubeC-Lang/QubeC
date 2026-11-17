# D0045: `run` behaves as build-then-execute; the engine is the implementation's choice

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

[D0013](D0013-easy-start.md) requires running a source file in one step (`qubec run file.qbc`). The host
implementation has the tree-walking interpreter from I1 and the VM from I2
([D0042](D0042-tree-walker-and-bytecode-vm.md)); `qubecc` will most likely have only a compiler and the VM. Is `run`
defined by what the program does, or by which engine runs it? In every option the whole program is checked first and
nothing runs if it is rejected ([§1.2.1](../../spec/01-introduction.md#121-diagnosis-of-violations)).

## Options considered

The scenario for every option: `qubec run wc.qbc notes.txt` in I1, in I2, and with `qubecc`.

### A. `run` is a shortcut for build-then-execute

```
$ qubec run wc.qbc notes.txt
# observably the same as:  qubec build wc.qbc && ./wc notes.txt
#   I1 host:   check → tree-walk the typed core
#   I2 host:   may still tree-walk, or compile to the VM
#   qubecc:    check → compile to bytecode (perhaps cached) → VM
```

- **Easy:** works in I1, before any VM exists, and in `qubecc`, which has no tree-walker; an implementation can switch
  engines without any change to the specification.
- **Hard:** the promise is only as precise as the definition of observable behavior (T0010).
- **For implementers:** every engine of an implementation must agree observably, which differential testing checks.
  Debugging extras, such as a richer backtrace, are not observable and may differ.
- **Prior art (recalled):** `go run` builds to a temporary binary and runs it; `cargo run` builds and runs; Kotlin
  scripts compile in memory.

### B. `run` means the tree-walking interpreter, by contract

```
$ qubec run wc.qbc notes.txt
#   every implementation: check → tree-walk
#   qubecc therefore needs a tree-walker as well
```

- **Easy:** `run` (development) and `build` (shipping) are distinct tools, and `run` shares its engine with the
  REPL.
- **Hard:** `run` stays slow even where a compiled engine exists.
- **For implementers:** `qubecc` must carry a second engine for good, only to meet the contract.
- **Locks in / rules out:** a tree-walker in every implementation; ties a command to an engine, although commands are
  not language ([D0044](D0044-executables-and-unstable-bytecode.md)).

Not offered: no `run` at all, which D0013 rules out.

Recommendation at the time: **A**, the only option that works across I1, I2, and `qubecc` without an extra engine.

## Choice

**A.**
1. Running a program with given arguments and input has the same observable behavior as building it and executing the
   result with the same arguments and input. What is observable is defined in T0010.
2. Which engine `run` uses is each implementation's choice, and may change between releases.
3. Behavior that is not observable, such as the detail of debugging output beyond what T0010 defines, may differ
   between engines.

## Rationale

The host implementation starts with only an interpreter, and `qubecc` will likely never have one; defining `run` by
behavior is what lets both offer it. It also keeps the specification free of engines: an implementation may make
`run` faster or more debuggable without changing what any program means.

## Consequences

- **I1:** `run` is check-then-tree-walk.
- **T0010** must define observable behavior precisely enough for this equivalence to be tested, between engines of one
  implementation and between implementations.
- **M15:** decides `run`'s name, flags, and any caching.

## Affected artifacts

- Spec: [§1.2.4](../../spec/01-introduction.md#124-means-of-execution)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
