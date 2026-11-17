# D0046: Linux x86-64 and macOS arm64 come first; platforms are supported in three tiers

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0009 |

## Question

Which platforms does QubeC support first, and how strong is the promise for each? A **platform** is an operating
system and a CPU architecture, such as `linux-x86_64`. A **host platform** is one the QubeC toolchain runs on (it needs
Rust, OCaml, and Zig there, [D0031](D0031-rust-host-interpreter.md)–[D0033](D0033-zig-host-vm.md)); a **target
platform** is one that built executables run on (it needs only a prebuilt VM,
[D0044](D0044-executables-and-unstable-bytecode.md)). The specification names no platforms, but the list shapes what
T0010 must say about differences between platforms, and the IO design of M09 and M14.

## Options considered

Every option uses the same three tiers, modeled on Rust's (verified,
[R0007](../research/R0007-execution-model-prior-art-and-checks.md)):
- **Tier 1:** the whole conformance suite runs in continuous integration on every change, and a failure blocks a
  release; a host and a target platform.
- **Tier 2:** built and cross-built in continuous integration; the whole suite runs at least before each release,
  possibly under an emulator; a target platform, and a host platform where the toolchains allow.
- **Tier 3:** builds are expected to work, with no testing promise.

The scenario for every option: `wc.qbc` reads a file and prints counts. What changes when a platform joins Tier 1:

```
                          linux / macos           windows
path syntax               /home/u/notes.txt       C:\Users\u\notes.txt
line ending in output     "\n"                    "\n" or "\r\n"?
exit status range         0–255                   32-bit
file name case            linux: sensitive        insensitive
                          macos: insensitive (default APFS)
interrupts                SIGINT, SIGPIPE         console events, no SIGPIPE
```

### A. The Unix pair first

Tier 1 `linux-x86_64` and `macos-arm64`; Tier 2 `linux-arm64` and `linux-riscv64` (the suite under QEMU); Windows in
Tier 3 until a decision promotes it.

- **Easy:** both are POSIX, so the IO surface is designed once at first; both case-sensitive and case-insensitive file
  systems are tested from the start.
- **Hard:** Windows users wait; a later Windows port may expose Unix assumptions.
- **For implementers:** RISC-V costs little: Zig cross-compiles to it, Rust ships it as a Tier 2 target with host
  tools, and OCaml 5 has a native RISC-V back end (all verified, R0007). A third architecture keeps the VM free of
  assumptions specific to x86 or Arm.
- **Prior art (recalled):** Go launched on Linux and macOS, with Windows following.

### B. Linux, macOS, and Windows in Tier 1

Tier 1 `linux-x86_64`, `macos-arm64`, and `windows-x86_64`; Tier 2 `linux-arm64`.

- **Easy:** most users are covered from the first executable; the IO design accounts for Windows from the start.
- **Hard:** every question about platform differences in T0010 needs a Windows answer now (line endings, exit codes,
  console encoding).
- **For implementers:** slower CI and each toolchain's Windows quirks, permanently, under
  [D0029](D0029-permanent-host-implementation.md).
- **Prior art:** Rust puts `x86_64-pc-windows-msvc` in Tier 1 (verified, R0007); Zig supports Windows (recalled).

### C. The development machine only, until the release checks exist

Tier 1 `macos-arm64` alone until I3; the others join with the conformance CI before the first fixpoint.

- **Easy:** the least setup now.
- **Hard:** no portability check during I1 and I2; a case-insensitive file system hides unit-to-file naming bugs.

Recommendation at the time: **A**, because it tests both kinds of file system early, keeps the first IO design to
POSIX, and adds RISC-V nearly for free.

## Choice

**A.**
1. Platforms are supported in three tiers, defined as above.
2. **Tier 1:** `linux-x86_64` and `macos-arm64`.
3. **Tier 2:** `linux-arm64` and `linux-riscv64`; the whole suite for `linux-riscv64` may run under an emulator.
4. **Tier 3:** `windows-x86_64`. Promoting a platform to Tier 1 or 2 takes a new decision.
5. The tiers apply from I2, when the first executables exist. In I1, the host interpreter runs on the Tier 1
   platforms.

## Rationale

The two Tier 1 platforms cover the development machine and the usual server and CI platform, and between them both
kinds of file-name case handling. Starting with POSIX keeps the first IO design smaller, and RISC-V costs little
because all three toolchains support it.

## Consequences

- **T0010:** states what may and may not differ between platforms, with Tier 1 and 2 in view and Windows not yet.
- **M09:** the mapping from units to files must behave the same on case-sensitive and case-insensitive file systems.
- **M14:** the first IO design is POSIX-based; promoting Windows later may require revising it.
- **M15:** the CI plan runs the suite on Tier 1 for every change, and on Tier 2 before each release.
- **[D0047](D0047-platform-parity.md):** the host implementation must build `qubecc` for every platform `qubecc`
  supports.

## Affected artifacts

- Spec: none (platforms are not language)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
