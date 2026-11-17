# D0073: A unit is one or more source files, and units form an acyclic graph

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

A **unit** is what an implementation compiles, and caches, as a whole
([D0072](D0072-source-only-meaning.md)). Is a unit one source file or several, and may units depend on each other in a
cycle? What a unit corresponds to in source, how it names its dependencies, and how units are named belong to M09;
the shape and the graph are visible to users now, because a cycle could be a rejection, and they decide what
separate compilation means for both implementations ([D0029](D0029-permanent-host-implementation.md)).

## Options considered

The scenario for every option (provisional syntax; imports are M09's): the app `wc` has two files that call each
other and uses the library `textutil`, which would like to call back into `wc`.

```
// wc/main.qbc
proc main() { print(count(read_all()).to_str()); }
func is_sep(c: Char) -> Bool = c == ' ' || textutil.is_wide_space(c);

// wc/count.qbc
func count(s: Str) -> Int = …;   // calls is_sep from main.qbc

// textutil/width.qbc
func is_wide_space(c: Char) -> Bool = …;
func demo() -> Int = wc.count("a b");   // textutil → wc → textutil: a cycle
```

### A. One or more files per unit; an acyclic graph between units

Declarations in a unit's files refer to each other freely, so `main.qbc` and `count.qbc` are two halves of `wc`.
Dependencies between units form a directed acyclic graph, and `textutil.demo` is rejected (`R-unit-cycle`).

- **Easy:** a unit is split into files at will; mutual recursion works inside a component, where it is usually needed.
- **Hard:** code that must call in both directions belongs in one unit.
- **For implementers:** units are compiled bottom-up and cached one by one; constant cycles
  ([D0065](D0065-cycles-found-during-evaluation.md)) stay inside one unit; the checker needs a whole-unit pass.
- **Locks in / rules out:** M09 chooses what a unit is in source but keeps the graph acyclic.
- **Prior art (recalled):** Rust crates, Go packages (import cycles rejected), and Swift modules all work this way.

### B. One file per unit, acyclic

Each file is a unit, and files form an acyclic graph; `count.qbc` calling `is_sep` while `main.qbc` calls `count` is
rejected, so `is_sep` must move to a third file.

- **Easy:** the simplest model to check, file by file in dependency order; finer caching.
- **Hard:** files must be arranged around the dependency order, which is painful for mutually recursive code such as
  a parser and its syntax tree.
- **Prior art (recalled):** OCaml compilation units (cycles between files forbidden, link order matters); Haskell
  modules, whose cycles need `hs-boot` files.

### C. One or more files per unit; cycles allowed between units

`textutil` and `wc` may depend on each other; an implementation checks and compiles each cycle of units together.

- **Easy:** no cycle errors.
- **Hard:** separate compilation weakens: the real unit of caching becomes the group of units that all reach each
  other.
- **Prior art (recalled):** Java allows cycles between packages, which `javac` compiles together; large codebases often
  grow tangled package dependencies.

Recommendation at the time: **A**, because a self-hosted compiler has mutually recursive parts that belong in one
unit, while acyclic units keep separate compilation simple and fast.

## Choice

**A.**
1. **Units.** A unit consists of one or more source files. Declarations in any file of a unit may refer to
   declarations in its other files. What a unit corresponds to in source, how a unit names its dependencies, and how
   units are named are
   *Provisional ([OQ-016](../open-questions.md#oq-016-how-are-units-named-and-declared))* (M09).
2. **[R-unit-cycle]** The dependency graph of a program's units is acyclic: a unit must not depend on itself, directly
   or through other units.
3. **The program.** A program consists of its **root unit**, the unit that declares the entry point
   ([D0057](D0057-forms-of-main.md)), and every unit the root unit depends on, directly or indirectly, including the
   standard library's units. Every declaration of every unit of the program is checked, and every constant in it is
   evaluated ([D0064](D0064-every-constant-once.md)), whether used or not. A unit that the program does not depend on
   is not part of it.
4. A single source file is a complete program ([D0013](D0013-easy-start.md)): a root unit of one file that depends
   only on the standard library.

## Rationale

Acyclic units of several files give the speed and simplicity of separate compilation, which both implementations
provide for as long as QubeC exists, while allowing mutual recursion where code needs it most, inside one component.
Under source-only meaning (D0072) a cycle of units would have to be compiled together anyway, so allowing cycles would
buy little. The granularity of units is left to M09, which designs modules and packages with the information this
choice lacks.

## Consequences

- **Spec:** [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 1–3.
- **[OQ-016](../open-questions.md#oq-016-how-are-units-named-and-declared)** (new): how units are named and declared,
  for M09.
- **M04:** name resolution within a unit spans all of its files.
- **M09:** designs what a unit is in source, its dependency declarations, and its name, keeping the graph acyclic.
- **I1:** the driver builds the unit graph, rejects cycles, and checks units in dependency order; within a unit it
  checks all files together.

## Affected artifacts

- Spec: [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 1–3
- Grammar rules: none
- Formal rules: none (a note in [static.md](../../spec/formal/static.md))
- Examples / tour: none
