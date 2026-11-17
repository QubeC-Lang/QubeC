# 1. Introduction

Status: Draft · Formal: static none, dynamic none

This chapter states what the specification covers, what conformance means (including what about a run is
observable, what may differ between runs, how a run starts and ends, what happens before it starts, and how a
program is made of units and names its source files), and how the specification is written.

## 1.1 Scope

1. This specification defines the QubeC programming language: its lexical structure, its syntax, its **static
   semantics** (the conditions a program must meet to be accepted), and its **dynamic semantics** (what an accepted
   program does when it runs). [D0015]
2. It also defines the **core library**: the types, values, and functions on which a rule of the language depends,
   such as the type a `?` expression requires. The rest of the standard library, and the tools that process QubeC
   programs, are outside the scope of this specification. [D0015]
3. The specification is written for two readers at once: programmers who need an exact answer to "is this legal,
   and what does it do?", and implementers of compilers and tools. Normative text uses QubeC's own vocabulary;
   mathematical notation is confined to the formal rules (§1.3.3). [D0015]
4. A passage of normative text that admits more than one reading is a defect in this specification. [D0015]

> **Note (non-normative).** The specification does not teach the language; the
> [tour](../guide/tour.md) does. The list of core-library items is drawn in M14. The `qubec` tool, including
> `qubec run` ([D0013](../design/decisions/D0013-easy-start.md)), is documented with the tools.

## 1.2 Conformance

A **conforming implementation** is an implementation that meets every requirement this specification places on
implementations. A **rejection rule** is a rule of this specification stating a condition under which a program
MUST be rejected (§1.3.5). A **conforming program** is a program that violates no rejection rule and uses no
extension (§1.2.3). [D0018, D0019]

### 1.2.1 Diagnosis of violations

1. A conforming implementation MUST reject, before the program runs, every program that violates a rejection rule,
   and MUST NOT run such a program. [D0018]
2. No rule of this specification is exempt from diagnosis: every rejection rule is stated so that a conforming
   implementation can decide whether a program violates it. [D0018]

> **Note (non-normative).** Run-time failures, such as panics, are not rejections. They are defined behavior,
> specified with the dynamic semantics of the construct that fails.

### 1.2.2 Reporting

1. When a conforming implementation rejects a program, it MUST report the rule ID (§1.3.5) of at least one
   rejection rule that the program violates. It MAY report more than one. [D0018]
2. The wording, layout, and presentation of diagnostics, and any additional codes they carry, are not specified.
   [D0018]

> **Example (non-normative).** A rejected program and one possible report. The QubeC code is provisional syntax.
>
> ```qubec
> proc read_count() -> Int { … }
> func f() -> Int = read_count();
> ```
>
> ```
> error[R-func-calls-proc]: func `f` calls proc `read_count`
>   --> main.qbc:2:19
> ```
>
> Only the presence of the rule ID is required. A program that violates two rejection rules may be reported with
> either ID, or both.

### 1.2.3 Extensions

An **extension** is a feature provided by an implementation that this specification does not define. An
**extension opt-in** is a declaration in a source file that names an extension. [D0019]

1. A conforming implementation MAY provide extensions. An extension MUST take effect only in a source file that
   contains an extension opt-in naming it. The syntax and placement of an extension opt-in are
   *Provisional ([OQ-006](../design/open-questions.md#oq-006-how-is-an-extension-opt-in-written-and-where-may-it-appear))*.
   [D0019]
2. An extension MUST NOT change the meaning of a source file that does not opt into it. In such a file, §1.2.1 and
   §1.2.2 apply unchanged. [D0019]
3. [R-extension-unknown] An extension opt-in MUST name an extension that the implementation provides. [D0019]
4. A program that contains an extension opt-in is not a conforming program. This specification gives such a program
   no meaning beyond rule 3. [D0019]

### 1.2.4 Means of execution

1. This specification defines what a program means. It does not define how a program is executed, what files an
   implementation produces, or what an implementation's commands are called. [D0042, D0044]
2. A conforming implementation MAY execute a program by interpreting it, by compiling it, or by any combination of
   the two, and MAY use different means for different runs of the same program. [D0042, D0045]

> **Note (non-normative).** The host implementation runs programs with a tree-walking interpreter and with a bytecode
> VM. A command that runs a source file directly is expected to behave as building the program and executing the
> result. The observable behavior that every means of execution must share is defined in §1.2.5.

### 1.2.5 Observable behavior and determinism

A **run** is one execution of a program. The **environment** of a run is everything outside the program with which
the run interacts. An **event** is one interaction of a run with its environment: what the run sends, and what it
receives in response. The **trace** of a run is the sequence of its events, in the order in which they happen. The
**inputs** of a run are the responses it receives in its events. [D0048]

The **outcome** of a run is one of the following [D0048, D0050, D0053, D0060]:
- a return, with an exit status (§1.2.7);
- a **panic**, with its kind, its message, and the source location of the operation that failed;
- **resource exhaustion**, naming the resource (§1.2.6);
- **termination by the environment**: the environment ends the run (§1.2.7);
- **divergence**: the run never ends.

The **observable behavior** of a run is its trace together with its outcome. [D0048]

1. Nothing other than the trace and the outcome of a run is observable. In particular, the output of `dbg`, the time
   and memory a run uses, any backtrace, and the means of execution (§1.2.4) are not observable. [D0008, D0048,
   D0050]
2. The order of all the events in a trace is observable, including the order of events that concern different
   streams or files. [D0048]
3. A run panics at the first failing operation that the evaluation order of the program reaches. Its trace consists
   of exactly the events that precede that operation. [D0049]
4. The kind, the message, and the source location of a panic are each specified with the operation that can fail.
   How a source location is written is specified in §1.2.9. [D0050, D0077]
5. **Determinism.** If two runs of a conforming program receive the same response to each event, they have the same
   observable behavior, whatever the conforming implementation, the means of execution, the build settings, and the
   platform. The only exception is resource exhaustion, as §1.2.6 permits. [D0049, D0051]
6. No behavior of a conforming program is implementation-defined or unspecified, other than resource exhaustion
   (§1.2.6). [D0051]
7. A conforming implementation MUST NOT let a choice of its own, such as its means of execution, a build setting, or
   an optimization, change the observable behavior of a run. No build setting removes or weakens a check that an
   operation makes. [D0049]
8. A conforming implementation MAY be nondeterministic internally, only where this cannot change the observable
   behavior of a run. [D0051]
9. Differences between platforms reach a program only as inputs. [D0051]
10. Every floating-point operation, including the conversion of floating-point values to and from text and the
    mathematical functions of the core library, has exactly one specified result for each choice of operands, so rule
    5 holds for floating-point results without exception. How the mathematical functions and the canonical NaN are
    specified is
    *Provisional ([OQ-011](../design/open-questions.md#oq-011-how-are-floating-point-math-functions-and-the-canonical-nan-specified))*.
    [D0052]

> **Example (non-normative).** A run of the program below, whose input line is `Ann`. The QubeC code is provisional
> syntax.
>
> ```qubec
> proc main() {
>   print("name? ");
>   let n = read_line();
>   eprint("got input");
>   print("hello " + n);
>   let x = dbg(1 + 1);
> }
> ```
>
> ```
> trace:    out "name? " · in → "Ann" · err "got input" · out "hello Ann"
> outcome:  return, with the exit status of a successful run
> ```
>
> Every conforming implementation, by every means of execution and on every platform, gives this run the same trace
> and outcome. The output of `dbg` is not part of either. An implementation that showed `name? ` only after reading
> the input would change the order of events, and so would not conform.

> **Note (non-normative).** Rule 10 means that floating-point operations follow IEEE 754 with rounding to nearest,
> ties to even; that no implementation fuses operations such as `a * b + c` unless the program asks for it, or
> flushes very small results to zero; and that every observation of a NaN sees one canonical NaN. The floating-point
> types and their rules are specified with the types. Rules 5 and 6 cover the sequential language; what a program
> that uses concurrency may vary is specified with concurrency.

### 1.2.6 Resource exhaustion and implementation limits

**Resource exhaustion** is a run's running out of stack or of memory. [D0053]

1. A run that never has more nested calls in progress than the **guaranteed minimum depth** MUST NOT exhaust its
   stack. The guaranteed minimum depth is 100,000 nested calls. A call whose frame holds k values, its parameters
   and local bindings, with k greater than 256, counts as ⌈k/256⌉ calls. A call made by `tailcall` does not add to
   the number of nested calls. [D0012, D0014, D0053, D0062]
2. When a run exhausts a resource, its trace MUST be a prefix of the trace that the run would have had without
   resource limits, and its outcome MUST be resource exhaustion, naming the resource. The outcome carries no source
   location. [D0053]
3. Within rules 1 and 2, the point at which a run exhausts a resource is not specified, and it may differ between
   runs, implementations, means of execution, and platforms. [D0053]
4. If a conforming implementation exhausts a resource while processing a program, it MUST report this and MUST NOT
   run the program. Such a report is not a rejection (§1.2.1). Running out of steps during compile-time evaluation
   counts as exhausting a resource for this rule (§1.2.8). [D0053, D0070]
5. Every limit that this specification places on the structure of a program, such as a depth of nesting or a number
   of parameters, is a rejection rule, stated with the construct it limits. [D0054]
6. A conforming implementation MUST NOT reject a conforming program. If it exhausts a resource while processing one,
   rule 4 applies. [D0054]

> **Note (non-normative).** Rule 2 means that resource exhaustion never produces a wrong result: the run behaves
> exactly as specified up to the point where it stops. Sizes, such as the length of a source file or the number of
> declarations, are limited only by resources. A conformance test whose program might exhaust a resource accepts
> either resource exhaustion or the expected outcome.

### 1.2.7 Program start and termination

A program's **entry point** is the procedure named `main` with which a run starts. A **procedure** is a callable
declared with `proc`; declarations are specified in a later chapter, which states the rejection rule for an entry
point of any other form. **Pending output** is output that a run has written but that has not yet been delivered to
its destination; §1.2.5 rule 2 lets an implementation hold output only while this cannot be observed. The **exit
status** of a run is an integer from 0 to 255 that a run that returns, panics, or exhausts a resource hands to its
environment. [D0008, D0048, D0057, D0058]

1. The entry point has one of two forms [D0057]:
   - a procedure `main` with no parameters and the unit result;
   - a procedure `main` with no parameters whose result type is the core library's result type with the unit success
     type and an error type that can be displayed. This form is
     *Provisional ([OQ-013](../design/open-questions.md#oq-013-what-exactly-is-the-result-form-of-main))*.
2. A run receives its arguments, its environment, and its standard input only through procedures of the standard
   library, as inputs (§1.2.5). [D0048, D0057]
3. When the entry point returns, the run ends as follows [D0048, D0058]:
   1. All pending output is delivered.
   2. If the entry point returned an error value, the display of the error is written to standard error. Its text is
      *Provisional ([OQ-013](../design/open-questions.md#oq-013-what-exactly-is-the-result-form-of-main))*.
   3. The run returns with exit status 1 if the entry point returned an error value, and 0 otherwise.
4. When the standard library's exit procedure is called with an integer n, the run ends as follows [D0048, D0058]:
   1. If n is less than 0 or greater than 255, the call panics.
   2. Otherwise, all pending output is delivered, and the run returns with exit status n.
5. When a run panics or exhausts a resource, it ends as follows [D0048, D0053, D0058, D0059]:
   1. All pending output is delivered.
   2. Exactly one **report line** is written to standard error. For a panic, it is
      `panic: <kind>: <message> at <location>`; for resource exhaustion, it is `exhausted: stack` or
      `exhausted: memory`, with no location. The location is written as §1.2.9 rule 7 states. The exact text of the
      kind and the message is
      *Provisional ([OQ-014](../design/open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter))*.
   3. If an input of the run requests it, a delimiter line and a **backtrace** MAY follow. Everything written from
      the delimiter line to the end of the run is not part of the trace. The delimiter's text is
      *Provisional ([OQ-014](../design/open-questions.md#oq-014-what-is-the-exact-text-of-the-report-line-and-the-backtrace-delimiter))*.
   4. The run ends with exit status 101 after a panic, and 102 after resource exhaustion. This holds even if the
      report line could not be written.

   Exhausting a resource MUST NOT prevent an implementation from performing steps 1 to 4.
6. When the environment ends a run, its outcome is termination by the environment, and its trace is a prefix of the
   trace it would have had otherwise. No further output is delivered and no report line is written; the run ends in
   the way the platform ends it, so that the environment can tell the cause. When the environment ends a run is an
   input of the run. [D0051, D0060]
7. If a write to standard output or standard error fails because the reader of that stream has closed it, the
   outcome of the run is termination by the environment. Any other failure of a write to standard output or standard
   error is a panic whose kind states that output failed. [D0061]

> **Note (non-normative).** A program that wants to finish its work when interrupted asks the standard library to
> receive interrupts; by default, output held in a buffered writer of the standard library is lost when the
> environment ends a run, while output written directly has already been delivered. On POSIX platforms, step 6
> means that a run interrupted from the keyboard ends as if killed by `SIGINT`, which a shell reports as status 130,
> and rule 7 means that `program | head -1` ends quietly.

> **Example (non-normative).** The runs of one program, `wc.qbc`. The QubeC code is provisional syntax beyond the
> forms of `main`.
>
> ```qubec
> proc main() -> Result[Unit, IoError] {
>   let argv = args();
>   if argv.len() != 2 { eprint("usage: wc FILE"); exit(2); }
>   let text = read_file(argv[1])?;
>   print(count_words(text).to_str());
>   Ok(())
> }
> ```
>
> ```
> wc notes.txt      out "412"                                    return, status 0
> wc missing.txt    err <display of the error>                   return, status 1
> wc                err "usage: wc FILE"                         return, status 2
> (a failing index) err "panic: <kind>: <message> at <location>"  panic, status 101
> (too deep)        err "exhausted: stack"                       resource exhaustion, status 102
> ```

### 1.2.8 Program phases and compile-time evaluation

A **constant** is a name declared with `const`, at top level or locally, whose value is computed before the program
runs; its **initializer** is the expression that computes it. Declarations are specified in a later chapter.
**Compile-time evaluation** is the evaluation of constants' initializers. A **step** of compile-time evaluation is one
call of any callable, or one iteration of a loop. A **pure native** is a native operation of the standard library
whose specification makes it pure. A **build input** is a file whose contents are part of what is processed to build
a program; source files are build inputs. [D0009, D0056, D0063, D0068, D0070]

**Phases**

1. A conforming implementation processes a program in three phases, in this order: **checking**, in which the whole
   program is checked against every rejection rule that does not depend on evaluation; **compile-time evaluation**,
   in which every constant is evaluated; and the run, which starts at the entry point (§1.2.7). A program rejected in
   either of the first two phases is not run, and no part of it runs. [D0063]
2. Checking does not evaluate any expression. A type does not mention the value of a constant. [D0063]
3. Compile-time evaluation follows the dynamic semantics of the run. The value of a constant is the value its
   initializer would have if it were evaluated by a run, with the same results, panics, and evaluation order (§1.2.5).
   [D0049, D0051, D0063]

> **Note (non-normative).** A later chapter may allow integer constants in types, such as the length of an array
> type. If it does, the checker uses this same evaluation, not a separate language of types; cycles through types are
> rejected; whether two types are equal is the same in every implementation; and only constants, never values
> computed by a run, appear in types. [D0063]

**Which constants, and how often**

4. Every constant of the program is evaluated exactly once, whether or not anything uses it, including the local
   constants of callables that are never called. Every use of a constant refers to that one value. The order in which
   constants are evaluated is not observable: it does not change any value, any step count, or whether the program is
   accepted. [D0064]
5. [R-const-cycle] The evaluation of a constant MUST NOT read a constant whose evaluation is in progress. A mention of
   a constant in code that the evaluation does not execute is not such a read. [D0065]
6. [R-const-generic] The type and the initializer of a constant MUST NOT mention a type parameter or a purity
   parameter of an enclosing declaration. [D0066]
7. [R-const-mutable] The value of a constant MUST NOT contain mutable state: neither a mutable object nor, through any
   value it holds or any value captured by a function value it holds, a reference to one. A constant whose type is or
   contains a mutable collection type violates this rule. A constant may otherwise have any type, including a
   function type. How the rule is checked beyond types is specified with memory and resources. [D0067]

**What runs**

8. Compile-time evaluation performs no effect. It calls no procedure and no effectful function value; the
   corresponding rejection rules are stated with constants and purity. A pure native may be called, and has the same
   result as in a run. [D0008, D0009, D0068]
9. The value of a constant depends only on the source files of the program, the standard library's included. [D0068]

> **Note (non-normative).** A later chapter may let a constant's value come from a named file. If it does, that file
> is a build input like a source file, and the same file gives the same value in every implementation. [D0068]

**Failure**

10. [R-const-panic] The evaluation of a constant MUST NOT panic. A diagnostic for this rule SHOULD give the kind, the
    message, and the source location of the panic (§1.2.5 rule 4). [D0069]

**Bounds**

11. Steps are counted on the program as written, together with the standard library's source. Each constant is
    charged only for the steps of its own initializer; reading another constant takes no steps. Which constructs are
    loops is specified with them. [D0070]
12. The **guaranteed number of steps** of a constant is 10,000,000, or the number its declaration states, if that is
    larger. The syntax of that statement is
    *Provisional ([OQ-015](../design/open-questions.md#oq-015-how-is-the-raise-of-a-constants-guaranteed-steps-written))*.
    [D0070]
13. A conforming implementation MUST complete the evaluation of a constant that needs no more steps than its
    guaranteed number of steps, no more nested calls than the guaranteed minimum depth (§1.2.6 rule 1), and no more
    memory than is available. [D0062, D0070]
14. Beyond its guaranteed number of steps, a constant's evaluation MAY be stopped. An implementation that stops it
    has exhausted a resource while processing the program (§1.2.6 rule 4): it MUST report this and MUST NOT run the
    program, and the report is not a rejection. Where an implementation stops is not specified. [D0053, D0070]
15. Rejection by rules 5, 7, and 10, and stopping by rule 14, are the only ways in which compile-time evaluation fails.
    Within the bounds of rule 13, every conforming implementation gives each constant the same value, or rejects the
    program by the same rule. [D0051, D0069, D0070]

**Debugging output**

16. The output of `dbg` during compile-time evaluation is not observable (§1.2.5 rule 1). An implementation SHOULD
    show it while processing the program, marking the constant being evaluated, and MUST NOT write it again when the
    program runs. [D0008, D0071]

> **Note (non-normative).** The host implementation stops a constant's evaluation after 1,000,000,000 steps, or the
> constant's stated number if that is larger, and an input of the build raises that limit. An implementation is
> expected to report progress while a constant runs long, and to say when a constant needed more steps than its
> guarantee, so that its author can state the number and every implementation completes it.

> **Example (non-normative).** The QubeC code is provisional syntax beyond `const`, `func`, and `proc`.
>
> ```qubec
> const KEYWORDS: ImmutableList[Str] = ImmutableList.of(["func", "proc", "let", "const"]);
> const MAX_TOKEN: Int = dbg(16 * 16);
> const SPARE: Int = KEYWORDS.len() / 0;
> const SCRATCH: List[Str] = List.new();
> const C: Int = D + 1;
> const D: Int = C + 1;
>
> func is_keyword(s: Str) -> Bool = KEYWORDS.contains(s);
> proc main() { print(is_keyword("proc").to_str()); }
> ```
>
> ```
> SPARE      rejected: R-const-panic, although nothing uses it
> SCRATCH    rejected: R-const-mutable (List is mutable)
> C, D       rejected: R-const-cycle
> MAX_TOKEN  256; its dbg line may be shown while building, and never by a run
> ```
>
> Without `SPARE`, `SCRATCH`, `C`, and `D`, the program is accepted and every run writes `true`.

### 1.2.9 Units, builds, and source names

A **unit** is a set of one or more source files that is compiled as a whole. A unit **depends on** another unit when
its source refers to that unit. The **root unit** of a program is the unit that declares its entry point (§1.2.7). A
**compiled form** of a unit is anything an implementation produces from the unit's source files and keeps for later
use, such as its checked core, the values of its constants, or its bytecode. The **source name** of a source file is
the name by which a program's observable behavior refers to it. A **source location** is a position in a source file.
[D0057, D0072, D0073, D0076, D0077]

**Units**

1. Every source file of a program belongs to exactly one unit. A declaration in one file of a unit may refer to a
   declaration in any other file of the same unit. What a unit corresponds to in source, how a unit names the units it
   depends on, and how units are named are
   *Provisional ([OQ-016](../design/open-questions.md#oq-016-how-are-units-named-and-declared))*. [D0073]
2. [R-unit-cycle] A unit MUST NOT depend on itself, directly or through other units. [D0073]
3. A program consists of its root unit and every unit on which the root unit depends, directly or through other
   units, the units of the standard library included. Every declaration of every unit of the program is checked, and
   every constant of every unit of the program is evaluated (§1.2.8 rule 4). A unit on which the root unit does not
   depend is not part of the program. A single source file that depends only on the standard library is a complete
   program. [D0013, D0064, D0073]

**Source-only meaning**

4. Whether a program is accepted, the values of its constants, and its observable behavior are determined by the build
   inputs of the program (§1.2.8), never by a compiled form of a unit. [D0068, D0072]
5. A conforming implementation MAY use a compiled form of a unit, produced earlier or provided with the
   implementation, only if the result is the same as compiling that unit from its source files. [D0072]

**Source names and locations**

6. The source name of a source file is the name of its unit, followed by `/` and the path of the file within the
   unit, with `/` between the components of the path. It does not depend on where or how the file is stored. How the
   name of a unit is formed, and what the path of a file within a unit is relative to, are
   *Provisional ([OQ-016](../design/open-questions.md#oq-016-how-are-units-named-and-declared))*. [D0076]
7. A source location is written `<source name>:<line>:<column>`, where the line and the column are decimal numerals
   with no leading zeros. The first line of a file is line 1, and the first column of a line is column 1. What a
   column counts, and what ends a line, are specified with the lexical structure. The source location of an operation
   that can fail is specified with the operation. [D0050, D0077]
8. Wherever the observable behavior of a run contains a source location, including the report line (§1.2.7 rule 5),
   the location is written as rule 7 states. Nothing in the observable behavior of a run depends on where or how the
   program's files are stored. [D0050, D0051, D0076]
9. No part of the language, the core library, or the standard library gives a program access to the implementation,
   the release, the build settings, or any record of the build that produced it. [D0051, D0075]
10. A diagnostic for a rejected program, and other output of an implementation that is not part of a run, MAY name
    source files in another way, such as by the paths through which they were given. [D0076]

> **Note (non-normative).** Until units are named, the unit of a single-file program is named after the file's name
> without `.qbc`, and the standard library's unit is named `std`. Source names for code entered in a REPL are
> specified with the tools. Rule 9 is a consequence of §1.2.5 rule 5: a program that could read how it was built
> could behave differently under two builds of the same source.

> **Note (non-normative).** The host implementation and the self-hosted compiler also promise reproducible builds. A
> build is identified by the contents of its build inputs, the implementation and its release, the target platform,
> and the build settings; the same identity gives byte-identical artifacts on any building machine, in any
> directory, with any state of caches, and a cross-build gives the same bytes as a native build. Every executable they
> build carries a record of its build identity, with the source name and a content hash of each file, which tools can
> show. Other implementations are encouraged to do the same. Neither promise is a conformance requirement (§1.2.4).
> [D0074, D0075]

> **Example (non-normative).** The QubeC code is provisional syntax beyond `func`, `proc`, `const`, and the forms of
> `main`; how one unit names another is not yet specified.
>
> ```qubec
> // unit textutil, file width.qbc
> const WIDTHS: ImmutableMap[Char, Int] = build_widths();
> func display_width(s: Str) -> Int = …;
>
> // unit wc, file main.qbc
> const BANNER_W: Int = textutil.display_width("wc 1.0");
> proc main() { print(count(read_all()).to_str()); }
>
> // unit wc, file src/count.qbc
> func count(s: Str) -> Int = …;   // line 12 indexes sizes[j] at column 24
> ```
>
> ```
> wc, textutil, std        the program; main.qbc and src/count.qbc refer to each other freely
> textutil depends on wc   rejected: R-unit-cycle
> a failing sizes[j]       err "panic: <kind>: <message> at wc/src/count.qbc:12:24", status 101
> ```
>
> The report line is the same whatever directory the files are stored in and whatever machine built or runs the
> program.

## 1.3 Notation and conventions

### 1.3.1 Requirement keywords

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY, and
OPTIONAL in this specification are to be interpreted as described in BCP 14
([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174)) when, and
only when, they appear in all capitals, as shown here. [D0001]

### 1.3.2 Structure and citations

1. Chapters are ordered by dependency: a chapter uses only terms and rules defined in itself or in earlier
   chapters. A term is set in **bold** where it is defined. [D0001]
2. A bracketed list such as `[D0012]` at the end of a normative statement names the design decisions it rests on.
   Citations are informative; they do not change the meaning of the statement. [D0001]
3. A rule that depends on an open question is marked *Provisional (OQ-nnn)*. [D0001]
4. Material labeled *Note (non-normative)* or *Example (non-normative)* is not normative. Everything else in a
   chapter is normative. [D0001]

### 1.3.3 Formal status and authority

1. Each chapter's status line states a **formal status** for its static semantics and for its dynamic semantics,
   each one of *complete*, *partial*, or *none*, as in `Status: Draft · Formal: static partial, dynamic none`.
   [D0016]
2. An aspect (static or dynamic) of a chapter is **formally complete** when its formal status is *complete*. Where
   an aspect is formally complete, the rules in [`formal/`](formal/README.md) govern it, and the prose explains
   them. Everywhere else, the prose governs, and the formal rules are a model that must agree with it. [D0016]
3. A disagreement between the prose and the formal rules is a defect in this specification. Until it is corrected,
   the governing text applies. [D0016]
4. An aspect becomes formally complete only by a recorded decision (a **promotion**), which requires that every
   normative rule of the aspect has formal rules, that every way to fail them is tagged with a rule ID (§1.3.5), and
   that the meta-properties covering the aspect have at least a proof sketch. [D0016]
5. The **formal target** is the whole sequential language: every construct except those of concurrency (tasks,
   channels, and race freedom) and any low-level memory model. Only an aspect within the formal target can be
   formally complete. A chapter outside it has formal status *partial* or *none*. [D0021]
6. The formal rules are of two kinds. **Elaboration rules** are stated over the language as written. They define its
   static semantics, and they translate each accepted program into the **core**, an internal, explicitly typed
   language. **Core rules** define the core's typing and its dynamic semantics. The dynamic semantics of a program is
   that of its core. [D0022]
7. A core rule is given by a definition in the mechanization in [`formal/lean/`](formal/README.md), which governs it.
   The rendering of the rule in `formal/` names that definition. Elaboration rules are given in `formal/` only.
   [D0024, D0026, D0028]
8. In addition to rule 4, a promotion requires that the meta-properties covering the aspect's core rules are proved
   in the mechanization, and that the reference evaluator and reference checker (see the note below) cover those core
   rules. [D0024, D0027]

> **Note (non-normative).** The mechanization contains a **reference evaluator** and a **reference checker** for the
> core, each proved to agree with the core rules. They let conformance tests, and the core produced by an
> implementation, be checked against the definition itself. The claimed meta-properties are listed in
> [`formal/metatheory.md`](formal/metatheory.md). No chapter can be promoted before the mechanization exists (M03).
> [D0023, D0027, D0028]

### 1.3.4 Rule style

1. Static semantics is stated declaratively, as conditions a program must meet. [D0017]
2. Dynamic semantics is stated as numbered steps wherever the order of events is observable: effects, panics,
   evaluation order, and cleanup. Where order is not observable, a declarative statement MAY be used. [D0017]
3. In a chapter whose dynamic semantics is formally complete, the chapter states how its numbered steps correspond,
   through its elaboration rules, to the core rules (§1.3.3). [D0017, D0022]

> **Example (non-normative).** The two styles, in illustrative section text.
>
> ```
> (static)  [R-func-calls-proc] The body of a `func` MUST NOT call a `proc`. [D0008]
> (dynamic) To evaluate f(a1, …, an):
>             1. Evaluate f to a callable g.
>             2. Evaluate a1, …, an in order to v1, …, vn. If one of them panics,
>                the call panics, and no later argument is evaluated.
>             3. Invoke g with v1, …, vn.
> ```

### 1.3.5 Rejection rules and rule IDs

1. Every rejection rule carries a **rule ID**, written in brackets at the start of the rule, as in
   `[R-func-calls-proc]`. [D0018]
2. A rule ID consists of `R-` followed by one or more words separated by single hyphens. Each word consists of
   lowercase ASCII letters `a`–`z` and digits `0`–`9`, and begins with a letter. [D0018]
3. The words name the subject first, then the problem (`R-const-cycle`, `R-extension-unknown`). A rule ID contains
   no section number. [D0018]
4. Rule IDs form a single namespace across this specification: no two rules share an ID. [D0018]
5. A rule ID, once published, is never reused for another rule or renamed. A rule that no longer applies keeps its
   ID and is marked *retired*. [D0018]

### 1.3.6 Grammar notation

1. The grammar of QubeC is the file [`grammar/qubec.ebnf`](grammar/qubec.ebnf). Productions shown in this
   specification are quoted from it verbatim; where a quotation and the file differ, the file governs. [D0001]
2. The grammar is written in the EBNF notation of XML 1.0 (Fifth Edition), section 6
   ([W3C](https://www.w3.org/TR/xml/#sec-notation)), without its `[ wfc: … ]` and `[ vc: … ]` annotations. A
   difference `A - B` that is one item of a longer sequence is written in parentheses. [D0078]
3. The grammar has two layers. [D0079]
   - The **lexical grammar** consists of the productions whose names are in `UPPER_SNAKE_CASE`. They match characters
     of the source text, with nothing implicit between their parts, and never refer to a syntactic production. They
     may be recursive.
   - The **syntactic grammar** consists of the productions whose names are in `UpperCamelCase`. They match sequences
     of tokens. Trivia may appear between any two tokens and is not part of the token sequence.
4. The lexical production `TOKEN` has one alternative for each kind of **token**, and the lexical production `TRIVIA`
   one for each kind of **trivia**. Every other lexical production is a **helper production**, used only inside other
   lexical productions. A syntactic production refers to no helper production. [D0079]
5. A quoted string in a syntactic production denotes the one token whose text is that string; the string is exactly
   one token. [D0079]
6. The operator `-` appears only in lexical productions, and its right operand matches only finitely many strings.
   [D0078]
7. The **start symbol** of the syntactic grammar is `SourceFile`. [D0079]
8. Every production carries a trailing comment that names the decisions it implements, such as `/* [D0078] */`.
   [D0078]

How source text is divided into tokens and trivia is specified in the lexical chapter (§2).

> **Note (non-normative).** The grammar file is checked by the grammar checker in
> [`tools/grammar/`](../../tools/grammar/README.md): its structure and the rules above (stage 1), its lexical grammar
> run on text by a reference lexer (stage 2), and from M03 the syntactic grammar's freedom from conflicts (stage 3).
> [D0080, D0081]

### 1.3.7 Spelling

This specification uses US English spelling, except in proper names, titles of external works, and verbatim
quotations. [D0020]

### 1.3.8 Rejection by the grammar

A source file **tokenizes** when its text can be divided into tokens and trivia as the lexical chapter (§2)
specifies. Its **token sequence** is then the sequence of its tokens, without its trivia.

1. [R-token-invalid] Every source file MUST tokenize. [D0082]
2. Each lexical failure that the lexical chapter names has its own rejection rule there. Where tokenization fails at a
   position at which such a rule applies, the file violates that rule, and not `R-token-invalid`. [D0082]
3. [R-syntax] The token sequence of every source file MUST be derivable from the start symbol `SourceFile` (§1.3.6). A
   file that does not tokenize has no token sequence and does not violate this rule. [D0079, D0082]
4. A later chapter MAY add a syntactic rejection rule for a particular mistake. Such a rule states exactly which token
   sequences it covers; a file whose token sequence it covers violates that rule, and not `R-syntax`. [D0082]

> **Note (non-normative).** A parse failure has one rule ID because where a parser notices a mistake depends on how it
> parses; the diagnostic's message can still say what was expected. Lexical failures are found at the same position
> by every correct lexer, so they are named one by one.

> **Example (non-normative).** With illustrative lexical rules (the literal forms are decided in later tasks):
>
> ```
> let a = 1__0;     // R-number-malformed, a named lexical rule
> let b = 1 ¤ 2;    // R-token-invalid: '¤' begins no token
> let = 1;          // R-syntax: the file tokenizes, but no name follows 'let'
> ```

**Grammar.** None.

**Formal rules.** None.
