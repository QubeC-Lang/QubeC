# D0075: Every executable carries a record of its build, which tools can read and programs cannot

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

Should an executable carry a **build record**, a small table listing its build identity
([D0074](D0074-reproducible-artifacts.md)), so that "was this binary built from that source?" becomes a mechanical
check? A record that a program could read is excluded in every option: a program that printed its release or build
settings would behave differently under two builds of the same source, which
[D0051](D0051-deterministic-sequential-language.md) and spec §1.2.5 rule 5 forbid. A program's version text belongs in
its source ([D0068](D0068-only-pure-code-at-compile-time.md)).

## Options considered

The scenario for every option (command names are provisional, M15):

```text
$ qubec build --profile release wc
$ qubec inspect ./wc

// in wc's source:
const VERSION: Str = "1.0";                  // from source
proc main() { print(build_info().release); } // does build_info exist?
```

### A. An embedded record; tools read it, programs cannot

Every executable embeds a record of exactly its build identity: the implementation and release, the target, the
build settings, and every unit with each file's source name ([D0076](D0076-source-names.md)) and content hash. It holds
no paths, times, users, or version-control data. A tool prints it; no library function returns it.

```text
qubec host 0.3.0 · linux-x64 · release
unit wc        main.qbc sha256:1c…  count.qbc sha256:9e…
unit textutil  width.qbc sha256:44…
unit std       (release 0.3.0)
```

- **Easy:** supply-chain checks; bug reports that name the exact release; a place to list embedded files.
- **Hard:** every executable is a few hundred bytes larger.
- **For implementers:** one deterministic table in the bundler; it does not affect byte identity, because it holds only
  the identity.
- **Prior art:** Go embeds build information by default, and `go version -m` prints the module path, the Go version,
  and settings such as `-trimpath`, `GOOS`, and `GOARCH` (verified by a pilot,
  [R0011](../research/R0011-units-reproducibility-and-source-names.md)); Go also lets programs read it through
  `runtime/debug.ReadBuildInfo` (recalled), which this option forbids. Rust embeds none by default; `cargo-auditable`
  adds a dependency list (recalled).

### B. A separate record file, on request

The executable holds nothing; on request, a build writes a record file next to it, as SBOM (software bill of
materials) generators do.

- **Easy:** minimal executables.
- **Hard:** a binary found later cannot say where it came from; the record and the binary can be separated.

### C. No record now

Nothing is decided; M15 may add a record later, which is harmless because artifacts are unstable
([D0044](D0044-executables-and-unstable-bytecode.md)).

Recommendation at the time: **A**, cheap and suited to a language for tool builders
([D0002](D0002-purpose-and-domain.md)).

## Choice

**A.**
1. **The record.** Every executable that our implementations build carries a build record listing exactly its build
   identity (D0074): the implementation and release, the target, the build settings, and every unit of the program
   with each of its files' source names and content hashes, embedded files included once M11 adds them. It holds no
   paths, times, users, or version-control data.
2. **Tools read it.** The record's format is I2's, and the command that shows it is M15's.
3. **Programs cannot.** No part of the language, the core library, or the standard library gives a program access to
   its build record, or to the implementation, release, or build settings that built it.

## Rationale

A record of the identity costs reproducibility nothing and makes every executable verifiable, which suits the tooling
domain; it is also the natural place to record embedded files as build inputs. Keeping it out of programs' reach
follows from determinism: a program that could read its build could behave differently under different builds of the
same source.

## Consequences

- **Spec:** [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rule 9, and its note.
- **I2:** the record's format, written by the bundler of the host implementation.
- **I3:** `qubecc` writes the record too.
- **M14:** no library procedure returns build data.
- **M15:** the command that shows the record.

## Affected artifacts

- Spec: [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rule 9 and a note
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
