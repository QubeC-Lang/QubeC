# D0057: `main` takes one of two forms, and arguments come from a library procedure

| Field | Value |
| --- | --- |
| Date | 2026-11-17 |
| Status | Accepted |
| Supersedes | — |
| Milestone / task | M01 / T0011 |

## Question

What forms may the entry point `main` take, and how does a program receive its arguments? `main` is a procedure
([D0008](D0008-purity.md)); hello world is one line inside it ([D0013](D0013-easy-start.md)); arguments, the
environment, and standard input are inputs ([D0048](D0048-trace-and-outcome.md)). On POSIX systems arguments are
arbitrary bytes (`execve` takes byte strings), so a list of text strings cannot always represent them. Result types
and `?` belong to M05 and M08.

## Options considered

The scenario for every option: `wc FILE` prints a word count, reports a usage error with status 2, and reads a file
that may not exist (provisional syntax).

### A. `proc main()` only

```
proc main() {
  let argv = args();                        // a library procedure (M14): an input
  if argv.len() != 2 { eprint("usage: wc FILE"); exit(2); }
  match read_file(argv[1]) {
    Ok(text) => print(count_words(text)),
    Err(e)   => { eprint("wc: " + e.message()); exit(1); },
  }
}
```

- **Easy:** one form; arguments arrive like every other input; nothing is committed ahead of M08.
- **Hard:** no `?` at the top level, so tools need explicit `match` and `exit`.
- **Prior art (recalled):** Go's `func main()` with `os.Args` and `os.Exit`.

### B. A fixed list of two forms

`proc main()`, or `proc main() -> Result[Unit, E]` with a displayable `E`. Returning `Err(e)` writes `e` to standard
error and ends with the error status. Any other signature is rejected.

```
proc main() -> Result[Unit, IoError] {
  let argv = args();
  if argv.len() != 2 { eprint("usage: wc FILE"); exit(2); }
  let text = read_file(argv[1])?;          // Err: written to standard error, status 1
  print(count_words(text));
  Ok(())
}
```

- **Easy:** `?` works at the top of a command-line tool ([D0002](D0002-purpose-and-domain.md)); errors cannot be
  dropped silently; the list is visible in one place.
- **Hard:** two forms to specify; the second waits on M05, M06, and M08 for its exact types.
- **Prior art:** Rust's `fn main() -> Result<(), E>`; verified here that returning `Err` exits with status 1
  ([R0009](../research/R0009-runtime-and-lifecycle-pilots.md)).

### C. Any return type implementing a library interface

```
type WcExit = Usage | Failed(IoError);
impl Termination for WcExit { func status(self) -> Int = … }   // provisional syntax
proc main() -> WcExit { … }
```

- **Easy:** extensible, for example a status per kind of error.
- **Hard:** depends on M06's interfaces; what `main` does at exit is defined far from it, which leans against NG-11
  ([D0005](D0005-non-goals.md)).
- **Prior art (recalled):** Rust's `Termination` trait, almost always used with `()` or `Result<(), E>`.

### D. `proc main(args: List[Str]) -> Int`

```
proc main(args: List[Str]) -> Int {
  if args.len() != 2 { eprint("usage: wc FILE"); return 2; }
  …; 0
}
```

- **Easy:** inputs and status are visible in the signature.
- **Hard:** hello world needs `-> Int` and `0` (against D0013); the result is conflated with the exit status; byte
  arguments do not fit.
- **Prior art (recalled):** C, C++, Java.

Recommendation at the time: **B**, with the result form provisional; a fixed list keeps `main`'s behavior visible, and
C can be added later without breaking programs.

## Choice

**B.**
1. A program's **entry point** is a procedure named `main` with no parameters, in exactly one of two forms:
   - `proc main()`, with the unit result;
   - `proc main() -> Result[Unit, E]`, where `E` is an error type that can be displayed.
2. Any other declaration of `main` as the entry point is rejected. Where `main` is declared (which unit, M09) and the
   rule's ID are fixed with declarations (M04).
3. The second form is *Provisional
   ([OQ-013](../open-questions.md#oq-013-what-exactly-is-the-result-form-of-main))*: the result type, what "can be
   displayed" means, and the text written for an error depend on M05, M06, and M08.
4. Arguments, the environment, and standard input reach the program through library procedures (M14), as inputs.
5. The list may later be extended, for example to an interface on the return type (M06, M08), by a new decision; such
   a change only adds forms.

## Rationale

Both forms serve real programs: the plain procedure keeps hello world minimal, and the result form lets command-line
tools propagate errors with `?` without discarding them. A fixed list keeps `main`'s exit behavior visible in one
place and does not wait on interfaces. Arguments come from a library procedure because every outside value is an
input, and because POSIX arguments are bytes.

## Consequences

- **M04:** states the entry-point rule with its rule ID. **M09:** says which unit's `main` is the entry point.
- **M05, M06, M08:** settle OQ-013.
- **M14:** provides `args()`, the environment, and `exit` ([D0058](D0058-exit-statuses.md)), with byte-level
  arguments available.
- **Tour and examples:** hello world is `proc main() { print("hello"); }` (`print`'s name is M14's).

## Affected artifacts

- Spec: [§1.2.7](../../spec/01-introduction.md#127-program-start-and-termination) (new)
- Grammar rules: none yet
- Formal rules: none yet
- Examples / tour: [vision.md](../vision.md)
