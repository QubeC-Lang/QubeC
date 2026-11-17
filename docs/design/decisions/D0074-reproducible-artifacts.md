# D0074: A build is identified by its inputs, and our implementations give byte-identical artifacts on any host

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

What identifies a build, and how reproducible must its output be? Same observable behavior for the same program is
already guaranteed ([D0045](D0045-run-is-a-shortcut.md), [D0051](D0051-deterministic-sequential-language.md)); what
remains is whether the bytes of artifacts must match as well, and where that promise lives. Artifacts are not language
([D0044](D0044-executables-and-unstable-bytecode.md)), so a byte-level promise can bind only our own implementations,
checked at release ([D0029](D0029-permanent-host-implementation.md)). The fixpoint check already needs `qubecc`'s
emitted bytecode to be deterministic.

## Options considered

**What identifies a build** is the same in every option: the contents of its build inputs (the source files of the
program's units, the standard library's included, and embedded files if M11 adds them,
[D0068](D0068-only-pure-code-at-compile-time.md)); the implementation and its release, including its prebuilt VM for
each target and any caches shipped with it; the target platform; and the build settings. Paths, times, users, the
directory, environment variables, the locale, the order in which the file system lists files, the number of threads,
and the state of caches are not part of it.

The scenario for every option (command names are provisional, M15):

```text
# machine 1: macOS arm64, in ~/dev/wc, warm cache, 10 threads
$ qubec build --target linux-x64 wc        # → wc   sha256: 9f3a…
# machine 2: Linux x64 CI, in /build/xyz, clean cache, 2 threads
$ qubec build --target linux-x64 wc        # → wc   sha256: ?
# machine 1 again: edit count.qbc, revert it, incremental rebuild
$ qubec build --target linux-x64 wc        # → wc   sha256: ?
# release check: compare the bytecode of stage 2 and stage 3
```

### A. Byte-identical on any host

For each of our two implementations, the same build identity gives byte-identical artifacts on every line: a
cross-build equals a native build, and an incremental build equals a clean one. The release check builds sample
programs on two hosts, in two directories, with warm and cold caches, and compares. Signatures that an operating
system's tools add after a build are outside the promise.

- **Easy:** anyone can rebuild a released tool, or `qubecc`, on any machine and compare hashes.
- **Hard:** nothing for users.
- **For implementers:** sorted traversals, no hash-ordered tables in output, no paths or times in artifacts
  ([D0076](D0076-source-names.md)), constant values serialized in a fixed order; the bundler that joins the prebuilt VM
  and the program is our own deterministic code, and on `macos-arm64` it writes the mandatory ad-hoc code signature
  itself, also when building from another host.
- **Locks in / rules out:** caches keyed by content, never by file times.
- **Prior art:** since Go 1.21 the Go toolchain is perfectly reproducible, built on Linux and Windows hosts that must
  produce bit-for-bit identical archives, with macOS binaries compared after their signatures are stripped (verified,
  [R0011](../research/R0011-units-reproducibility-and-source-names.md)); a Go user build embeds the build directory
  unless `-trimpath` is given (verified by a pilot, R0011); the Reproducible Builds project and `SOURCE_DATE_EPOCH`
  (recalled).

### B. Byte-identical on the same host platform only

As A, except that builds on different kinds of host may differ for the same target.

- **Easy:** verifying a release needs only the same kind of host as the one that built it.
- **Hard:** a build on another kind of host cannot be checked by hash.
- **For implementers:** no cross-host signing or linking work.
- **Prior art (recalled):** the usual state for C, C++, and Rust today.

### C. Same behavior; only emitted bytecode deterministic

Executables may differ between builds; only the bytecode emitted on request must be byte-identical for the same
identity, because the fixpoint and differential tests compare it.

- **Easy:** the cheapest.
- **Hard:** whether a binary was built from a given source can be checked only by extracting and comparing its
  bytecode.
- **Prior art (recalled):** where most toolchains were before the Reproducible Builds effort.

The promise is not offered as a rule for every conforming implementation: that would reverse D0044 choice 3, and
conformance tests, which observe only behavior, could not check it.

Recommendation at the time: **A**, held loosely, matching the strength of D0051 and
[D0052](D0052-bit-identical-floats.md) and making `qubecc` and released tools verifiable by anyone; B is the fallback
if cross-host signing proves too costly.

## Choice

**A.**
1. **Build identity.** A build is identified by:
   - the contents of its build inputs: the source files of the program's units, the standard library's included, and
     embedded files if M11 adds them;
   - the implementation and its release, including its prebuilt VM for each target and any caches shipped with it;
   - the target platform;
   - the build settings.

   Only the contents of files count, never their paths, times, or permissions.
2. **Byte-identical artifacts on any host.** For each of our two implementations, the same build identity gives
   byte-identical artifacts: executables, emitted bytecode, and anything else a build writes for distribution. Nothing
   else may affect them: not the building machine's operating system or architecture, the directory, the clock, the
   user, environment variables, the locale, the order in which files are listed, the number of threads, or the state
   of caches.
   - A cross-build equals a native build.
   - An incremental build equals a clean one.
   - Signatures that an operating system's tools add after a build (for example a developer signature or
     notarization) are outside the promise; a signature that the build itself must write, such as the ad-hoc
     signature of `macos-arm64`, is inside it.
3. **Where it lives.** This is a requirement on the host implementation and `qubecc`, checked at every release, not a
   rule of the language. The specification carries a non-normative note; other implementations are encouraged to
   follow it.

## Rationale

D0051 has already removed nondeterminism from the language, so what remains is engineering discipline in two
implementations, concentrated in one place, the bundler. In return the build from source and the fixpoint become
checkable by anyone on any machine, and released tools can be verified by hash, which suits a language for tool
builders. The cost is known: the main risk is producing executables, and the `macos-arm64` signature, identically from
every host; if that proves too costly, a new decision can fall back to identity on the same kind of host.

## Consequences

- **Spec:** a note in [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names).
- **I1:** the front end's caches are keyed by content.
- **I2:** the bundler, the emitted bytecode, and the serialization of constant values are deterministic; the bundler
  writes the `macos-arm64` ad-hoc signature itself; the release check compares builds from two hosts, two directories,
  and warm and cold caches. Producing identical executables from every host is the main risk.
- **I3:** `qubecc` meets the same requirement, and the fixpoint compares its bytes.
- **M11:** embedded files are build inputs (choice 1).
- **M15:** names the build settings and the commands.

## Affected artifacts

- Spec: a note in [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names)
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
