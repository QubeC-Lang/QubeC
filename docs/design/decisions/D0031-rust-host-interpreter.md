# D0031: The host interpreter is written in Rust

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

Which language is the host interpreter ([D0030](D0030-three-part-host.md)) written in? It holds the front end
(parsing, name resolution, type and purity checking, elaboration into the typed core, and every rejection with its
rule ID, [D0018](D0018-diagnosis-and-rule-ids.md)), the tree-walking core interpreter, the REPL, and the driver
([D0013](D0013-easy-start.md)). It is permanent and leads every feature
([D0029](D0029-permanent-host-implementation.md)), so it is the code each feature lands in first, forever.

## Options considered

All six candidates with an installed toolchain were piloted on the same program: a type-and-purity checker for a
small language with rule-ID rejections, elaboration into a separate typed core, and a core evaluator, with eight
tests ([R0005](../research/R0005-host-language-prior-art-and-pilots.md)). Go was set aside for this part because it
has no exhaustiveness checking (its compiler and `go vet` were silent when a case was deleted), and Zig because its
pilot was the longest and its errors carry no payload. The sample for each remaining option is its pilot's case for
checking and elaborating a function application.

### A. Rust

```rust
Expr::App(f, a) => {
    let (cf, pf) = check(f, env)?;
    let (p, phi, r) = match cf.ty() {
        Ty::Fun(p, phi, r) => ((**p).clone(), *phi, (**r).clone()),
        t => return err("R-call-non-function", format!("callee has type {:?}", t)),
    };
    let (ca, pa) = check(a, env)?;
    expect(&ca, &p, "argument")?;
    Ok((Core::App(Box::new(cf), Box::new(ca), r), join(join(pf, pa), phi)))
}
```

- **Easy:** a missing case is a hard error (E0004); `Result` with `?`; mature libraries for source-snippet
  diagnostics and REPL line editing (recalled); a stable toolchain with editions.
- **Hard:** `Box`, `Rc`, and `clone` noise; compile times that grow with the code (a reason Roc gave for leaving Rust,
  [R0005](../research/R0005-host-language-prior-art-and-pilots.md)).
- **Pilot:** 221 lines; clean build 1.3 s; no borrow-checker conflicts.
- **Prior art (recalled):** rustc, Gleam's compiler.

### B. OCaml

```ocaml
| App (f, a) ->
  let* (cf, pf) = check env f in
  (match cf.ty with
   | TFun (p, phi, r) ->
     let* (ca, pa) = check env a >>= expect "argument" p in
     Ok ({ ty = r; node = CApp (cf, ca) }, join (join pf pa) phi)
   | t -> err "R-call-non-function" ("callee has type " ^ show_ty t))
```

- **Easy:** the shortest code and fastest build; garbage-collected trees; closest to QubeC's ML lineage.
- **Hard:** a missing case is a warning unless made fatal; thinner diagnostics and line-editing libraries.
- **Pilot:** 146 lines; clean build 0.4 s.

### C. Lean 4

```lean
| .app f a => do
  let (cf, tf, pf) ← check ctx f
  match tf with
  | .fn p ph r =>
    let (ca, ta, pa) ← check ctx a
    expectTy "argument" p ta
    pure (.app cf ca r, r, pf.join (pa.join ph))
  | t => throw ⟨"R-call-non-function", s!"cannot call value of type {t.show}"⟩
```

- **Easy:** the same language as the reference ([D0027](D0027-executable-reference.md)), so the front end could share
  the core datatype, and the elaborator could later be mechanized; a missing case is a hard error.
- **Hard:** the smallest ecosystem for a user-facing tool; release churn ([D0025](D0025-lean-4.md)); the evaluator
  needs `partial`.
- **Pilot:** 192 lines; clean build 1.4 s; `lean --run` 0.6 s.

### D. Scala 3

```scala
case App(f, a) =>
  for
    ff <- check(f, ctx)
    aa <- check(a, ctx)
    r <- ff.core.typeOf match
      case Type.Fun(p, ph, res) =>
        expect(aa.core.typeOf, p, "argument").map: _ =>
          Checked(CApp(ff.core, aa.core, res), join(join(ff.purity, aa.purity), ph))
      case other => Left(Err("R-call-non-function", s"callee has type ${show(other)}"))
  yield r
```

- **Easy:** enums, `match`, `Either`; JVM libraries.
- **Hard:** a missing case is a warning; JVM startup for `qubec run` (0.13 s packaged); about 1 s of tooling latency
  per run; a JVM as a permanent dependency.
- **Pilot:** 184 lines; clean compile 2.2 s.

Recommendation at the time: **Rust**, because this part owns the user-facing diagnostics and the REPL, a missing case
is a hard error, and a permanent host benefits most from a low-churn toolchain.

## Choice

**Rust** (stable channel, pinned, [D0035](D0035-pinned-toolchains-and-recorded-libraries.md)) for the host
interpreter: front end, tree-walking core interpreter, REPL, and driver.

## Rationale

The host interpreter is where users meet QubeC: its diagnostics carry the rule IDs, and its REPL is the easy start.
Rust has the strongest libraries for both, its compiler refuses a non-exhaustive match outright, and its toolchain
changes slowly, which matters for code maintained indefinitely. The pilot hit no ownership friction on tree code. We
accept the boilerplate and growing compile times.

## Consequences

- **M15, M16:** plan the interpreter's Cargo project, its diagnostic rendering, and its REPL.
- The host interpreter emits the typed core for the host compiler and the reference
  ([OQ-008](../open-questions.md#oq-008-what-is-the-core-interchange-format-and-how-do-implementations-emit-core)).
- Every rejection in the host pipeline is made here.

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
