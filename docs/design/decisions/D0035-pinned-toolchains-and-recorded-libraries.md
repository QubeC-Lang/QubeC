# D0035: Toolchains are pinned; third-party libraries are allowed when recorded and locked

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

The host implementation is permanent ([D0029](D0029-permanent-host-implementation.md)) and spans Rust, OCaml, and Zig
([D0031](D0031-rust-host-interpreter.md)–[D0033](D0033-zig-host-vm.md)), beside the Lean mechanization
([D0025](D0025-lean-4.md)). How are toolchain versions controlled, and may the host use third-party libraries?

## Options considered

Toolchain pinning was common to every option, following D0025's treatment of Lean. The options differed on
libraries. The scenario: the host interpreter wants source-snippet diagnostics and REPL line editing; the host
compiler wants help parsing the core interchange format. Library names are illustrative.

### A. Standard library only

```toml
# the host interpreter's Cargo.toml
[dependencies]          # empty: diagnostic renderer and line editor written by hand
```

- **Easy:** no supply-chain risk; every line is ours; simple, reproducible builds.
- **Hard:** a hand-written diagnostic renderer (Unicode column widths), line editor (raw terminal modes, per-OS
  code), and parsing helpers; the REPL lags.
- **Prior art (recalled):** the Go and Zig compilers are essentially standard-library-only.

### B. Allowed when recorded and locked

A dependency is allowed when it is listed with its purpose in one place and locked by checksum; adding or upgrading
one is a deliberate, reviewed change, like a toolchain upgrade.

```toml
[dependencies]
ariadne   = "=0.5"      # diagnostics with source snippets   (listed in the host's dependency table)
rustyline = "=15"       # REPL line editing                    (listed in the host's dependency table)
```

- **Easy:** good diagnostics and a usable REPL early ([D0013](D0013-easy-start.md)); every dependency is visible and
  justified.
- **Hard:** a little process per dependency; locked libraries still need occasional upgrades.
- **Prior art (recalled):** rustc vendors and audits its crates.

### C. Free use, locked

Any library may be used; lock files keep builds reproducible.

- **Easy:** the fastest progress.
- **Hard:** dependencies, and their transitive trees, accumulate silently in a codebase kept forever.

| | A Standard library only | B Recorded and locked | C Free, locked |
| --- | --- | --- | --- |
| Diagnostics and REPL quality early | hand-built | ✓✓ | ✓✓ |
| Supply-chain and maintenance risk | none | low, visible | grows silently |
| Process | none | one entry per dependency | none |

Recommendation at the time: **B**, because the host interpreter owns the user-facing diagnostics and the REPL, and a
permanent host argues against silent accumulation.

## Choice

**B.**
1. **Toolchains are pinned** in every part: Rust in `rust-toolchain.toml` (stable channel), OCaml by its compiler
   version, Zig by the minimum version in `build.zig.zon`, and Lean in `lean-toolchain`
   ([D0025](D0025-lean-4.md)). A toolchain upgrade is its own change, with every part's tests re-run in it.
2. **Third-party libraries are allowed** when each is listed, with its purpose, in the host's dependency table, and
   locked by checksum (`Cargo.lock`, an OCaml lock file, `build.zig.zon` hashes). Adding, upgrading, or removing a
   library is a deliberate change that updates the table.
3. The location and form of the dependency table are planned with the implementation layout (M16).

## Rationale

Pinning makes every build reproducible and every upgrade visible, which four toolchains in a permanent codebase
need. Allowing recorded libraries lets the host interpreter offer the good diagnostics and REPL that the easy start
asks for without hand-building terminal and rendering code, while keeping every dependency deliberate and
justified.

## Consequences

- **M16:** defines the dependency table and lock files for each part.
- **M15:** tooling may reuse the host interpreter's recorded libraries.
- Toolchain upgrades are recorded in the change that makes them.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
