# R0011: Units, reproducibility, and source names: prior art and pilots

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M01 / T0013 |
| Used by | D0072, D0073, D0074, D0075, D0076, D0077 |

## Question

Do comparable toolchains treat compiled libraries as inputs or as caches? How reproducible are their builds, and what
has to be removed from a build's inputs to make them so? How do they name source files in panic messages and
tracebacks, and does the name depend on where the files are stored? What form does a location take?

## Sources

1. Measurements on macOS 27 (Darwin 27.0.0), arm64, on 2026-11-17, with rustc 1.99.1, Go 1.27.2, Apple Swift 6.4, and
   Zig 0.17.0. The programs were throwaway files outside the repository; each is described below.
2. "Perfectly Reproducible, Verified Go Toolchains", the Go blog, <https://go.dev/blog/rebuild>.
3. Go 1.12 release notes, section "Binary-only packages", <https://go.dev/doc/go1.12>.
4. Swift Evolution proposal SE-0274, "Concise magic file names",
   <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0274-magic-file.md>.

## Findings

### Reproducibility (verified, sources 1 and 2)

- A Go program (module `example.com/tool`, one file that panics on an out-of-range index) was copied into two
  directories and built in each. Without flags, the two executables differed (different SHA-1 hashes), because each
  embeds its build directory: the traceback printed the absolute path of `main.go`. With `-trimpath`, the two
  executables were identical, and the traceback printed `example.com/tool/main.go:3`.
- A Rust program built with `rustc -C opt-level=2 src/main.rs` in two directories gave identical executables.
- The Go blog states that as of Go 1.21 the Go toolchain is perfectly reproducible, its only relevant input being the
  source code. To get there, Go removed or fixed as inputs: the host C toolchain (the toolchain is built with `cgo`
  disabled), ARM floating-point detection, the build directory (`-trimpath`), a Windows path-separator inconsistency,
  the current time (archives take their time from the version file), user and group IDs, and the packaging logic
  (moved into the Go tree as `cmd/distpack`).
- Go's official releases are built on a Linux x86-64 and a Windows x86-64 system, which must produce bit-for-bit
  identical archives before a release proceeds; a toolchain built on a Mac for `linux/amd64` matched Ubuntu's binaries.
- Go's macOS binaries must be signed with an Apple key that cannot be shared, so the verifier compares them only after
  stripping their code signatures. The blog does not say that macOS-built toolchains match Linux-built ones.

### Binary libraries (verified, source 3)

- Go 1.12's release notes state: "Go 1.12 is the last release that will support binary-only packages."

### Build information (verified, source 1)

- `go version -m` on the pilot executable printed the Go version, the module path, and build settings including
  `-buildmode=exe`, `-compiler=gc`, `-trimpath=true`, `CGO_ENABLED`, `GOARCH`, `GOOS`, and `GOARM64`.

### Source names and locations (verified, sources 1 and 4)

- Rust: the panic message names the file as it was given to the compiler: `panicked at src/main.rs:1:93` when built
  with a relative path, the full absolute path when built with one, and `mylib/main.rs:1:93` with
  `--remap-path-prefix`. The location is file, line, and column.
- Go: tracebacks give file and line only (`main.go:3 +0x28`), with an absolute path unless `-trimpath` is used.
- Swift: `print(#fileID, #filePath, #line, #column)` compiled with `-module-name Tool` printed `Tool/main.swift
  main.swift 1 34`; `#fileID` is the module's name followed by the file's name.
- SE-0274 proposed that `#file` take the form `<module-name>/<file-name>` instead of a full path, citing privacy (paths
  reveal user names and build-farm details), binary size (code size reduced by up to 5% in the benchmark suite), and
  reproducibility (different build machines otherwise produce different hashes).
- Zig: `@src()` gave the module `main`, the file `main.zig`, and line and column `2:32`; the file field holds only the
  file's name.

### Recalled, not verified here

- Cargo builds every crate from source; rlibs load only in the compiler version that wrote them. OCaml's `.cmi` and
  `.cmx` files are tied to one compiler version ("inconsistent assumptions over interface").
- Java class files are a stable binary format; Swift's library-evolution mode needs `.swiftinterface` files.
- Rust crates, Go packages, and Swift modules are acyclic graphs of multi-file units; OCaml forbids cycles between
  files; Haskell needs `hs-boot` files for module cycles; Java allows cycles between packages.
- An ad-hoc code signature on `macos-arm64` contains hashes of the code's pages and no timestamp, and can be written
  without Apple's tools (Zig's linker and the `rcodesign` tool do so).
- Go programs can read their build information through `runtime/debug.ReadBuildInfo`; `cargo-auditable` embeds a
  dependency list in Rust executables.
- GCC, Clang, and rustc diagnostics write locations as `file:line:column`.

## Conclusions

- Treating compiled units as caches, with source as the only meaning, matches where Go ended up and how Cargo works
  (D0072).
- Byte-identical builds independent of the building machine are achievable in practice: Go achieves them for its whole
  toolchain. The paths of the build directory are the first thing to remove, which source names do (D0074, D0076).
  Code signatures added with a private key cannot be reproduced and must be outside the promise; an ad-hoc signature
  written by the build can be inside it (D0074).
- Naming files by their module or unit and a relative path is established practice (Swift's `#fileID`, Go's
  `-trimpath`), for the same reasons D0076 gives (D0076).
- `file:line:column` is the common form of a precise location (D0077).
