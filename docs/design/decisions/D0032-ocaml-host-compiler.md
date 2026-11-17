# D0032: The host compiler is written in OCaml

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

Which language is the host compiler ([D0030](D0030-three-part-host.md)) written in? It reads the typed core that the
host interpreter emits and lowers it to bytecode: closure conversion, compilation of `match` into decision trees, and
jump layout. It makes no rejections, so it needs no user-facing diagnostics or REPL; it needs comfortable
tree-to-tree transformation. The three parts use distinct languages, and Rust and Zig are taken by the other two
([D0031](D0031-rust-host-interpreter.md), [D0033](D0033-zig-host-vm.md)).

## Options considered

No separate pilot was run: this part is the same kind of symbolic code that the host-interpreter pilots measured
([R0005](../research/R0005-host-language-prior-art-and-pilots.md)). The samples compile an application and an `if`
with backpatched jumps.

### A. OCaml

```ocaml
let rec compile (c : core) (out : instr Dynarray.t) =
  match c.node with
  | CApp (f, a) -> compile f out; compile a out; Dynarray.add_last out Call
  | CIf (cond, t, e) ->
    compile cond out;
    let jf = emit_hole out in                    (* JumpIfFalse ?, patched below *)
    compile t out;
    let jend = emit_hole out in                  (* Jump ? *)
    Dynarray.set out jf (JumpIfFalse (Dynarray.length out));
    compile e out;
    Dynarray.set out jend (Jump (Dynarray.length out))
  | ...
```

- **Easy:** ML languages are the classic tool for compiling a typed IR; the shortest pilot code and fastest build.
- **Hard:** a fourth toolchain for the project (with the Lean mechanization); its own reader for the core
  interchange format.
- **Prior art (recalled):** the OCaml compiler; Rust's first compiler.

### B. Lean 4

```lean
def compile : Core → StateM (Array Instr) Unit
  | .app f a _ => do compile f; compile a; emit .call
  | .ite c t e _ => do
    compile c
    let jf ← hole
    compile t
    let jend ← hole
    patch jf (.jumpIfFalse (← size))
    compile e
    patch jend (.jump (← size))
  | ...
```

- **Easy:** no new toolchain ([D0025](D0025-lean-4.md)); shares the core datatype and reader with the verified
  reference ([D0027](D0027-executable-reference.md)); an optional path to a verified compiler (as CakeML and
  CompCert, recalled).
- **Hard:** release churn in a product component; less proven at compiler scale (recalled).

### C. Scala 3

```scala
def compile(c: Core, out: ArrayBuffer[Instr]): Unit = c match
  case CApp(f, a, _) => compile(f, out); compile(a, out); out += Call
  case CIf(cond, t, e, _) =>
    compile(cond, out)
    val jf = hole(out)
    compile(t, out)
    val jend = hole(out)
    out(jf) = JumpIfFalse(out.length)
    compile(e, out)
    out(jend) = Jump(out.length)
```

- **Easy:** good ADTs; a fast JIT for long compiles.
- **Hard:** a JVM in the build pipeline; a missing case is a warning; a fourth toolchain.

| | OCaml | Lean 4 | Scala 3 |
| --- | --- | --- | --- |
| New toolchain for the project | yes | no | yes, plus a JVM |
| Shares the core datatype with the reference | no | yes | no |
| Missing case | warning (can be fatal) | error | warning |
| Fit for compiler transformations | best | good | good |

Recommendation at the time: **Lean 4**, for adding no toolchain and sharing the reference's definitions of the core.

## Choice

**OCaml** (OCaml 5, pinned, [D0035](D0035-pinned-toolchains-and-recorded-libraries.md)) for the host compiler.

## Rationale

Compiling a typed IR is what ML languages do best, and OCaml's code for it is the most direct of the candidates and
the closest to QubeC's own ML lineage. Keeping the host compiler separate from the Lean reference also keeps it
independent of the reference's definitions: it reads the core through the interchange format like any other
consumer, so a mismatch between the two shows up as a test failure rather than being shared. We accept a fourth
toolchain and a second reader for the core format.

## Consequences

- **M16:** plans the compiler's OCaml project (build tool to be chosen then).
- The host compiler needs the core interchange format
  ([OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core))
  and produces the bytecode format
  ([OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)).
- OCaml's check for non-exhaustive matches is a warning by default; whether the build makes it fatal is a choice of
  this part ([D0034](D0034-idiomatic-code-per-part.md)).

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
