# D0044: A build produces a self-contained executable; bytecode can be emitted but is unstable

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

What does `build` give users, and is bytecode an **artifact** they see (a file the toolchain hands over)? If it is,
is its format **stable**, meaning that a file written by one release loads in later ones? This is the M01 part of
[OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm); the
format itself is I2's. With a VM ([D0042](D0042-tree-walker-and-bytecode-vm.md)), a **self-contained executable** is a
prebuilt VM binary with the program's bytecode embedded: one file that runs on another machine of the same platform
with nothing installed.

## Options considered

The scenario for every option: build `wc.qbc` and run it on another machine. Commands and flags are provisional
(M15).

### A. Bytecode is a public, distributable artifact

```
$ qubec build wc.qbc            # → wc.qbb   (bytecode, versioned format)
$ scp wc.qbb friend:            # the other machine needs a QubeC VM installed
friend$ qubec exec wc.qbb notes.txt
```

- **Easy:** small files that run on every platform with a VM.
- **Hard:** users must install a VM.
- **For implementers:** a versioned format, loaders for old versions, and a verifier, since a VM must not trust
  bytecode it did not just produce. `qubecc` must emit the same format.
- **Locks in / rules out:** format compatibility for good.
- **Prior art (recalled):** JVM class files (a verifier and decades of compatibility); .NET IL; OCaml's `ocamlc`
  output; Python's `.pyc`, which is deliberately not stable across versions.

### B. Executables only; bytecode stays internal

```
$ qubec build wc.qbc            # → wc  (VM + embedded bytecode, for this platform)
$ scp wc friend:
friend$ ./wc notes.txt
```

- **Easy:** one file, as with Go or Rust, which suits CLI tools ([D0002](D0002-purpose-and-domain.md)).
- **Hard:** nothing to inspect when a compiled program misbehaves.
- **For implementers:** no format promise; but differential tests and the fixpoint check must compare whole
  executables, VM included.

### C. Executables by default; bytecode can be emitted on request and is unstable

```
$ qubec build wc.qbc                    # → wc  (as in B)
$ qubec build --emit=bytecode wc.qbc    # also → wc.qbb
$ qubec disasm wc.qbb                   # a readable listing
#   wc.qbb loads only in the release that wrote it
```

- **Easy:** everything in B, plus bytecode to read when debugging.
- **Hard:** emitted bytecode will be passed around anyway and break on upgrade; the loader's version check makes that
  failure clear.
- **For implementers:** the fixpoint check and differential tests between the host compiler and `qubecc` compare
  bytecode files exactly; no format promise.
- **Locks in / rules out:** nothing beyond B; moving to A later stays possible.
- **Prior art (recalled):** Python's `.pyc` with a magic number per version; GHC's interface files, readable only by
  the same compiler version.

| | A Public bytecode | B Executables only | C Executables + unstable emit |
| --- | --- | --- | --- |
| Format promise | for good | none | none (same release only) |
| Running needs an installed VM | yes | no | no |
| Bytecode to inspect and compare | yes | no | yes |
| Constrains `qubecc`'s back end | yes | no | no |

In every option, artifacts and commands are tool contracts, not language.

Recommendation at the time: **C**, the smallest promise that still gives the release checks something exact to
compare.

## Choice

**C.**
1. By default, a build produces one **self-contained executable** for a target platform: the VM with the program's
   bytecode embedded. After native code arrives ([D0043](D0043-native-code-after-v1.md)), an executable may contain
   native code instead.
2. On request, a build also emits the program's bytecode, for inspection, tests, and the release checks. The driver
   can load and disassemble it.
   - **Same release only:** emitted bytecode is guaranteed to load only in the release of the implementation that
     wrote it, and the loader rejects bytecode from any other release with a clear message.
   - **No compatibility promise** exists across releases.
   - **Stabilizing the format** takes a new decision.
3. **Artifacts and commands are not language.** The specification defines what a program means, not what files a tool
   writes or what its commands are called. Command names and flags stay provisional until M15.

## Rationale

This commits to the least: no format to keep compatible, and no constraint on `qubecc`'s back end. It still gives
users single-file executables, which suit the tools QubeC is for, and gives us exact bytecode to compare in the
fixpoint check and in differential testing between the two compilers, which
[D0029](D0029-permanent-host-implementation.md) makes release steps.

## Consequences

- **OQ-009:** the M01 part is decided (internal, unstable, visible on request); the format stays with I2's opening
  task.
- **I1** has no `build` yet: its driver offers running, checking, and the REPL. `build` arrives with the host
  compiler and VM in I2.
- **I2:** cross-building needs a prebuilt VM per target platform ([D0046](D0046-first-platforms-and-tiers.md)). On
  `macos-arm64`, appending bytecode to a signed VM binary leaves it failing strict code-signature validation, so the
  bytecode is better linked in as data or placed in its own Mach-O section
  ([R0007](../research/R0007-execution-model-prior-art-and-checks.md)).
- **M15:** names the commands and flags.

## Affected artifacts

- Spec: [§1.2.4](../../spec/01-introduction.md#124-means-of-execution)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
