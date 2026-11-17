# D0076: Every source file has a source name, its unit's name followed by its path in the unit

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0013 |

## Question

A panic's source location is observable ([D0050](D0050-panic-contents.md)) and appears in the report line
([D0059](D0059-report-line-and-backtrace.md)). By determinism ([D0051](D0051-deterministic-sequential-language.md))
and byte-identical artifacts ([D0074](D0074-reproducible-artifacts.md)), the way a location names its file cannot
depend on where the files are stored, on the working directory, or on the host's path separator. How is a source
file named?

## Options considered

In every option, separators are always `/`, and diagnostics for rejected programs, which are not observable behavior,
may name files as the user gave them. The path of a file as given or as stored is not an option: the same program's
report line would differ between machines. Rust panics print that path (`src/main.rs:1:93`, or the absolute path when
compiled with one, verified by a pilot, [R0011](../research/R0011-units-reproducibility-and-source-names.md)), and Go
needs `-trimpath` to avoid embedding it (verified, R0011).

The scenario for every option: `wc` has the files `main.qbc` and `src/count.qbc`, `textutil` has `width.qbc`, the
standard library has `list.qbc`, and a single-file program `hello.qbc` is run directly
([D0013](D0013-easy-start.md)). Each panics once:

```text
panic in wc's src/count.qbc, line 12 column 9
panic in textutil's width.qbc, line 4 column 3
panic in the standard library's list.qbc, line 88 column 5
panic in hello.qbc, line 2 column 15
```

### A. The unit's name and the path in the unit, always

```text
wc/src/count.qbc:12:9
textutil/width.qbc:4:3
std/list.qbc:88:5
hello/hello.qbc:2:15      (single file: its unit is provisionally named after the file's stem)
```

- **Easy:** every name is unambiguous and the same wherever the unit is used.
- **Hard:** the single-file case looks redundant.
- **For implementers:** prefix the unit's name.
- **Prior art:** Swift's `#fileID` is `Module/File.swift` (verified by a pilot, which printed `Tool/main.swift`); Swift
  changed `#file` to this form for privacy, binary size, and reproducibility (verified, SE-0274, R0011). Go with
  `-trimpath` names files by module path and file (verified by a pilot, `example.com/tool/main.go`).

### B. The root unit's files bare, other units prefixed

```text
src/count.qbc:12:9
textutil/width.qbc:4:3
std/list.qbc:88:5
hello.qbc:2:15
```

- **Easy:** a program's own files read as they do in an editor.
- **Hard:** a root-unit file `std/list.qbc` reads the same as the standard library's, so a rule against collisions is
  needed; a unit's names depend on whether it is the root.
- **Prior art (recalled):** roughly what C and Rust users see when building from a project's root.

### C. The path in the unit only

`src/count.qbc`, `width.qbc`, `list.qbc`, `hello.qbc`.

- **Easy:** the shortest.
- **Hard:** ambiguous: two units with a `main.qbc` give the same location.
- **Prior art:** Zig's `@src().file` holds only the file's name (`main.zig`), with the module in a separate field
  (verified by a pilot, R0011).

Recommendation at the time: **A**, the only option that is unambiguous without further rules.

## Choice

**A.**
1. **Source names.** Every source file of a program has a **source name**: the name of its unit, followed by `/` and
   the file's path within the unit, with `/` between components. It does not depend on where or how the file is
   stored.
   - *Provisional ([OQ-016](../open-questions.md#oq-016-how-are-units-named-and-declared)):* how units are named, what
     a path within a unit is relative to, and whether a dependency's version appears in its name are M09's. Until then,
     a single-file program's unit is named after the file's name without `.qbc`, and the standard library's unit is
     named `std`.
2. **Locations in observable behavior** name files by their source names: the report line
   ([D0059](D0059-report-line-and-backtrace.md)), and anything else that later puts a location into observable
   behavior. Locations stored in artifacts (debugging information, backtraces, the build record of
   [D0075](D0075-build-record.md)) use source names too.
3. **Diagnostics** for rejected programs, and other output of tools that is not part of a run, may name files as the
   user gave them.
4. Source names of code entered in the REPL ([D0013](D0013-easy-start.md)) are M15's.

## Rationale

Source names are the only form that is both unambiguous and independent of the machine, as D0051's one meaning and
D0074's byte-identical artifacts require. The cost is a little bookkeeping in each implementation, and the details of
unit naming fall naturally to M09. Diagnostics are exempt because they are not program behavior, and editors work best
with the paths the user typed.

## Consequences

- **Spec:** [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 6, 8, and 10.
- **[OQ-014](../open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter):**
  the file part of a location is decided.
- **[OQ-016](../open-questions.md#oq-016-how-are-units-named-and-declared)** (new): unit naming, for M09.
- **M09:** names units, possibly with versions, and decides what a unit's paths are relative to; a unit name must not
  contain `/` or `:`, and neither may a path component contain `:`, or locations become ambiguous.
- **M15:** source names for the REPL.
- **I1, I2:** the front end gives every file its source name; the core and the bytecode carry source names, never
  disk paths.

## Affected artifacts

- Spec: [§1.2.9](../../spec/01-introduction.md#129-units-builds-and-source-names) rules 6, 8, 10;
  [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) rule 5
- Grammar rules: none
- Formal rules: none (a note in [dynamic.md](../../spec/formal/dynamic.md))
- Examples / tour: none
