# 1. Introduction

Status: Draft · Formal: static none, dynamic none

This chapter states what the specification covers, what conformance means (including what about a run is
observable, what may differ between runs, and how a run starts and ends), and how the specification is written.

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
4. The kind, the message, and the source location of a panic are each specified with the operation that can fail and,
   for source locations, with source files. [D0050]
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
   run the program. Such a report is not a rejection (§1.2.1). [D0053]
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
      `exhausted: memory`, with no location. The exact text of the kind, the message, and the location is
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

The grammar of QubeC is the file [`grammar/qubec.ebnf`](grammar/qubec.ebnf). Productions shown in this
specification are quoted from it verbatim; where a quotation and the file differ, the file governs. [D0001]

> **Note (non-normative).** Until M02 fixes the notation, the grammar is written in W3C-style EBNF (XML 1.0, Fifth
> Edition, section 6).

### 1.3.7 Spelling

This specification uses US English spelling, except in proper names, titles of external works, and verbatim
quotations. [D0020]

**Grammar.** None.

**Formal rules.** None.
