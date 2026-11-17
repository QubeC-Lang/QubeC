# R0007: Execution model: prior art, platform support, and executable embedding

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Milestone / task | M01 / T0009 |
| Used by | D0042–D0047, OQ-010 |

## Question

What do comparable languages do about engines, native code, and visible bytecode; how do established projects define
platform tiers; do our three toolchains support the candidate platforms; and can a self-contained executable be made
by embedding bytecode in a prebuilt VM binary on every Tier 1 platform?

## Sources

1. The rustc book, "Platform Support": <https://doc.rust-lang.org/rustc/platform-support.html>
2. OCaml 5.1.0 release announcement (RISC-V native code restored):
   <https://discuss.ocaml.org/t/ocaml-5-1-0-released/13021>
3. Erlang/OTP mailing list, "HiPE to be removed in OTP 24?" (June 2020):
   <https://erlang.org/pipermail/erlang-questions/2020-June/099646.html>; the BeamAsm pull request:
   <https://github.com/erlang/otp/pull/2745>
4. Local toolchains: Zig 0.17.0, OCaml 5.5.2, rustc 1.99.1, on `macos-arm64`.

## Findings

- **Verified:** Rust defines Tier 1 as "guaranteed to work" (official binaries, tests after each change), Tier 2 as
  "guaranteed to build" (automated builds, tests not always run), and Tier 3 as supported in the code base but not
  built or tested automatically. "With host tools" means the compiler itself runs there [1].
- **Verified:** `x86_64-unknown-linux-gnu`, `aarch64-apple-darwin`, `aarch64-unknown-linux-gnu`, and
  `x86_64-pc-windows-msvc` are Tier 1 with host tools in Rust; `riscv64gc-unknown-linux-gnu` is Tier 2 with host
  tools [1].
- **Verified:** OCaml 5.1.0 restored native code generation on RISC-V (RV64G), which OCaml 4.11 had first added; 32-bit
  native code was not restored [2].
- **Verified:** the OTP team planned HiPE's removal for OTP 24, and the BeamAsm loader, a JIT from BEAM instructions
  to x86-64 at load time, does not load HiPE code [3]. (The final OTP 24 release notes were not checked.)
- **Verified (experiment):** Zig 0.17.0 cross-compiles a program to `x86_64-linux`, `aarch64-linux`, `riscv64-linux`,
  `aarch64-macos`, and `x86_64-windows` from `macos-arm64` [4].
- **Verified (experiment):** OCaml 5.5.2's `ocamlc` has `-output-complete-exe`, which writes a self-contained
  executable with the bytecode runtime included [4].
- **Verified (experiment):** on `macos-arm64`, bytecode appended to the end of a linker-signed executable is still
  read and run, but the result fails `codesign` strict validation, and re-signing does not repair it [4].
- **Recalled:** Lua, CPython, and BEAM stayed bytecode-based for decades; LuaJIT and PyPy are separate projects;
  CPython's JIT is recent and experimental.
- **Recalled:** Nim, Chicken Scheme, and Gambit emit C; GHC's C back end was retired, with tail calls and GC roots
  among the reasons.
- **Recalled:** Java had no mainstream ahead-of-time compiler until GraalVM `native-image`; Kotlin/Native came years
  after Kotlin/JVM.
- **Recalled:** `go run` builds a temporary binary and runs it; `cargo run` builds and runs.
- **Recalled:** Python's `.pyc` files carry a magic number per version and are not stable across versions; GHC's
  interface files load only in the compiler version that wrote them.
- **Recalled:** Go's first public release ran on Linux and macOS, and Windows support followed; gc and gccgo support
  different platform sets.

## Experiments

Run in a scratch directory outside the repository.

```
$ zig build-exe hello.zig -target riscv64-linux -femit-bin=hello-riscv64-linux
$ file hello-riscv64-linux
hello-riscv64-linux: ELF 64-bit LSB executable, UCB RISC-V, RVC, double-float ABI, … statically linked
  (likewise for x86_64-linux, aarch64-linux, aarch64-macos; x86_64-windows gives a PE32+ executable)

$ ocamlc -help | grep complete-exe
  -output-complete-exe  Output a self-contained executable, including runtime and C stubs

$ zig cc -O2 vm.c -o vm          # reads a trailer "QBCTRAIL" + length from the end of its own file
$ cp vm prog && <append payload + trailer to prog>
$ ./prog
payload: BYTECODE: sum_to ...
$ codesign -v prog
prog: main executable failed strict validation
$ codesign -f -s - prog-resigned && codesign -v prog-resigned
prog-resigned: main executable failed strict validation
```

## Conclusions

The bytecode VM is the conventional, low-cost compiled path, and native code is commonly added years later. All three
host toolchains support the Tier 1 and Tier 2 platforms we chose, so RISC-V costs little. A self-contained executable
works on `macos-arm64`, but for distributed binaries the bytecode should be linked into the VM binary or placed in its
own Mach-O section rather than appended; I2 decides how.
