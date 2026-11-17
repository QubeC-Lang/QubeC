# D0033: The host VM is written in Zig

| Field | Value |
| --- | --- |
| Date | 2026-11-16 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M00 / T0006 |

## Question

Which language is the host VM ([D0030](D0030-three-part-host.md)) written in? It holds the bytecode loader and
interpreter loop (**dispatch**: read an opcode, run its handler), the heap and garbage collector (or reference
counting, M07), the growable stacks ([D0012](D0012-tail-calls-and-stacks.md)), later the task scheduler (OQ-001,
M10), panics, and the native library functions. It is built as a library with a **C ABI**, the calling convention
every language can link against, so that native code, if M01 adds it, can use the same runtime. This is the one part
that manages raw memory, so languages with their own garbage collector (Go, OCaml, Scala, Lean) are poor fits; Rust and
OCaml are taken by the other parts.

## Options considered

The sample for each option is the dispatch of `CALL` and of `MAKE_CLOSURE`, which allocates and so may trigger
collection.

### A. Zig

```zig
fn run(vm: *Vm) !void {
    while (true) {
        const op: Op = @enumFromInt(vm.code[vm.pc]);
        vm.pc += 1;
        switch (op) {
            .call => {
                const arg = vm.pop();
                const callee = vm.pop().asClosure();
                try vm.pushFrame(callee, arg);           // grows the stack segment if needed
            },
            .make_closure => {
                const clo = try vm.heap.create(Closure); // GC may run; out of memory is an error value
                clo.* = .{ .code = vm.readU32(), .env = vm.env };
                try vm.push(.{ .closure = clo });
            },
            .ret => if (vm.popFrame()) |v| try vm.push(v) else return,
        }   // a missing opcode is a compile error
    }
}
```

- **How it works:** no hidden allocation; allocators are passed explicitly, so the GC heap is one more allocator;
  errors are values; `export fn` gives a C ABI.
- **Easy:** exhaustive `switch` is a hard error (pilot); debug builds check bounds and overflow; cross-compilation is
  built in.
- **Hard:** pre-1.0, with breaking changes in most releases (the pilot met the new `std.Io` API); not memory-safe.
- **Prior art:** Roc rewrote its compiler from Rust to Zig, citing compile times and an allocator-passing style; Bun
  moved the other way, from Zig to Rust, citing memory-safety bugs (both verified by search,
  [R0005](../research/R0005-host-language-prior-art-and-pilots.md)).

### B. C

```c
for (;;) {
    switch ((Op)vm->code[vm->pc++]) {
    case OP_CALL: {
        Value arg = pop(vm);
        Closure *callee = as_closure(pop(vm));
        if (!push_frame(vm, callee, arg)) return VM_OUT_OF_MEMORY;
        break;
    }
    case OP_MAKE_CLOSURE: {
        Closure *clo = gc_alloc(vm, sizeof *clo);   /* GC may run here */
        if (!clo) return VM_OUT_OF_MEMORY;
        clo->code = read_u32(vm); clo->env = vm->env;
        push(vm, closure_value(clo));
        break;
    }
    case OP_RET: /* … */ break;
    }   /* a missing case: only a -Wswitch warning */
}
```

- **Easy:** stable; it is the C ABI; where most VMs live.
- **Hard:** undefined behavior everywhere, with sanitizers as the only net; return-code errors.
- **Prior art (recalled):** Lua, CPython, the OCaml runtime, the BEAM.

### C. C++

```cpp
for (;;) {
    switch (static_cast<Op>(vm.code[vm.pc++])) {
    case Op::Call: {
        Value arg = vm.pop();
        Closure& callee = vm.pop().as_closure();
        vm.push_frame(callee, arg);                 // throws std::bad_alloc on OOM
        break;
    }
    case Op::MakeClosure: {
        auto* clo = vm.heap.make<Closure>(vm.read_u32(), vm.env);   // GC may run
        vm.push(Value::closure(clo));
        break;
    }
    case Op::Ret: /* … */ break;
    }   // a missing case: only a -Wswitch warning
}
```

- **Easy:** RAII and templates; mature tooling.
- **Hard:** C's undefined behavior plus a very large language; exceptions conflict with stack switching; C-ABI
  wrappers needed.
- **Prior art (recalled):** V8, HotSpot, JavaScriptCore.

| | Zig | C | C++ |
| --- | --- | --- | --- |
| Missing case | error | warning | warning |
| Undefined-behavior safety net | debug-mode checks | sanitizers only | sanitizers only |
| Toolchain stability | pre-1.0 (pin it) | stable | stable |
| C ABI | `export fn` | native | `extern "C"` |

Recommendation at the time: **Zig**, for explicit allocators, error-value out-of-memory, exhaustive `switch`, and a
direct C ABI, with its churn handled by pinning.

## Choice

**Zig** (pinned, [D0035](D0035-pinned-toolchains-and-recorded-libraries.md)) for the host VM, built as a library with
a C ABI.

## Rationale

A VM wants its own heap and collector, which Zig's explicit allocators make natural, and out-of-memory is an ordinary
error value that the runtime must handle rather than an abort. Exhaustive `switch` and debug-mode checks catch mistakes
that C leaves to sanitizers. A Zig runtime with a C ABI can serve bytecode and native code alike. We accept pre-1.0
churn, handled like Lean's: a pinned version and deliberate upgrades.

## Consequences

- **M01, M07, M10:** the runtime they design (execution model, memory management, scheduler) is written in Zig.
- **M12:** the host VM's C ABI is a natural base for FFI design.
- **M16:** plans the VM's build (`build.zig`) and the C-ABI boundary.
- The host VM reads the bytecode format
  ([OQ-009](../open-questions.md#oq-009-what-is-the-bytecode-format-between-the-host-compiler-and-the-host-vm)).

## Affected artifacts

- Spec: none
- Grammar rules: none
- Formal rules: none
- Examples / tour: none
