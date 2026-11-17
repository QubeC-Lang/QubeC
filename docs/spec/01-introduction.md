# 1. Introduction

Status: Draft · Formal: static none, dynamic none

This chapter states what the specification covers, what conformance means, and how the specification is written.
Further conformance requirements (observable behavior, implementation limits) are added by M01.

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
> result. The observable behavior that every means of execution must share is specified with the dynamic semantics.

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
