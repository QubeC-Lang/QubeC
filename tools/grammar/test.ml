(* Testing for the grammar checker.
   Has to be run from the project root: `ocaml tools/grammar/test.ml` *)
#use "tools/grammar/check.ml";;


(* ==================================== Test Reporting ==================================== *)

(* Number of tests passed.*) let passed = ref 0
(* Number of tests failed.*) let failed = ref 0

(* [record name ok detail] records the result of a test with [name].
    If [ok] is true, the test passed and [passed] is incremented.
    Otherwise, the test failed and [failed] is incremented.
    The information about the test is printed to the console. *)
let record (name: string) (ok: bool) (detail: string) : unit =
  if ok then
    (incr passed; Printf.printf "[OK]\t%s\n" name)
  else
    (incr failed; Printf.printf "[FAIL]\t%s\n%s" name detail)


(* ==================================== Unit Test Runner ==================================== *)

(* [unit name f] runs the test [f] and records the result with [name].
   If [f] raises an exception, the test is considered failed
   and the failure is recorded with the exception message. *)
let unit (name: string) (f: unit -> bool) : unit =
  match f () with
  | ok -> record name ok ""
  | exception e -> record name false ("  raised " ^ Printexc.to_string e ^ "\n")


(* ==================================== Fixture Tests Utilities and Runner ==================================== *)

(* [short f] returns the short form of a failure, without the message.
   It is the format of the lines in a fixture's `expected` file, i.e.
   "file:line: code" or "file: code" when line = 0. *)
let short (f : failure) : string =
  if f.line = 0 then Printf.sprintf "%s: %s" f.file f.code
  else Printf.sprintf "%s:%d: %s" f.file f.line f.code

(* The lines of dir/expected, trimmed, without blank lines and lines
   starting with '#'. Trimming also drops a CRLF editor's '\r'. *)
let read_expected (dir : string) : string list =
  read_file dir "expected"
  |> lines
  |> List.map String.trim
  |> List.filter (fun l -> l <> "" && not (String.starts_with ~prefix:"#" l))

(* [diff ~expected ~got] returns the lines that are in [expected] but not in [got],
   and the lines that are in [got] but not in [expected]. *)
let diff ~(expected : string list) ~(got : string list) : string list * string list =
  ( List.filter (fun l -> not (List.mem l got)) expected,
    List.filter (fun l -> not (List.mem l expected)) got )

(* [fixture dir] runs the grammar checker on the fixture in [dir], compares the
   results with the fixture's `expected` file, and records the result.
   On a mismatch, the missing and unexpected lines are recorded in the detail. *)
let fixture (dir : string) : unit =
  (* Run the grammar checker on the fixture directory, and get the short form of the failures.
     We are only interested in the short form because the fixture's `expected` file does not contain messages. *)
  let got = run ~root:dir |> List.map short |> List.sort compare in
  (* Read the expected lines from the fixture's `expected` file, and sort them. *)
  let expected = read_expected dir |> List.sort compare in
  (* Compare the expected and got lines, and record the result. *)
  let missing, unexpected = diff ~expected ~got in
  (* Show the missing and unexpected lines in the detail. *)
  let show label ls = String.concat "" (List.map (fun l -> "  " ^ label ^ " " ^ l ^ "\n") ls) in
  let detail =
    match show "missing:   " missing ^ show "unexpected:" unexpected with
    | "" -> "  the same lines, but a different number of times\n"
    | d -> d
  in
  (* Record the result of the fixture test. *)
  record ("fixture " ^ Filename.basename dir) (got = expected) detail

(* [fixtures root] runs all the fixtures in the directory [root].
   Every subdirectory of [root] is a fixture and must contain an `expected` file;
   a subdirectory without one is recorded as a failed test that raised an exception.
   This function collects all the fixtures and runs them, recording the results. *)
let fixtures (root : string) : unit =
  if not (Sys.file_exists root && Sys.is_directory root) then
    failwith ("fixtures: " ^ root ^ " is not a directory");
  Sys.readdir root
  |> Array.to_list
  |> List.sort compare
  |> List.filter (fun d -> Sys.is_directory (Filename.concat root d))
  |> List.iter (fun d ->
    let dir = Filename.concat root d in
    match fixture dir with
    | () -> ()
    | exception e -> record ("fixture " ^ d) false ("  raised " ^ Printexc.to_string e ^ "\n")
  )


(* ==================================== Tests ==================================== *)

let () =
  (* ---- unit tests ----
     Each unit test calls one function on a small, hand-made input and compares the result with the exact
     value it must return. A test passes when its function returns true; an exception counts as a failure. *)

  (* Rendering: the text a human reads in the checker's output. *)

  (* A failure on a known line renders as "file:line: code: message". *)
  unit "render with a line" (fun () ->
      render (failure ~line:3 "g.ebnf" "name-undefined" "WORD is not defined")
      = "g.ebnf:3: name-undefined: WORD is not defined");
  (* A whole-file failure (line 0) leaves the line out entirely: "file: code: message", never "file:0: …". *)
  unit "render without a line" (fun () ->
      render (failure "g.ebnf" "grammar-missing" "no grammar file")
      = "g.ebnf: grammar-missing: no grammar file");

  (* Short form: what a fixture's `expected` file lists. It drops the message, so rewording a message never
     breaks a fixture; the message text passed in here is deliberately irrelevant. *)
  unit "short with a line" (fun () ->
      short (failure ~line:3 "g.ebnf" "name-undefined" "any text") = "g.ebnf:3: name-undefined");
  unit "short without a line" (fun () ->
      short (failure "g.ebnf" "grammar-missing" "any text") = "g.ebnf: grammar-missing");

  (* Ordering: failures are sorted by file, then line, then code, so the output is the same on every run.
     The trap: lines 2 and 10 in the same file. Compared as numbers, 2 comes first; compared as text,
     "10" < "2" would put line 10 first. a and c share file and line, so their codes ("y" before "z")
     decide; d is in file "b", so it comes last even though its line (1) is the smallest. *)
  unit "failures sort by file, then line (as numbers), then code" (fun () ->
      let a = failure ~line:2 "a" "z" "" and b = failure ~line:10 "a" "b" "" in
      let c = failure ~line:2 "a" "y" "" and d = failure ~line:1 "b" "a" "" in
      List.sort compare_failures [ d; b; a; c ] = [ c; a; b; d ]);

  (* diff: explains a failed fixture. It returns (missing, unexpected): lines the fixture expects but the
     checker didn't report ("a"), and lines the checker reported that the fixture doesn't expect ("c").
     A line on both sides ("b") appears in neither. *)
  unit "diff finds missing and unexpected lines" (fun () ->
      diff ~expected:[ "a"; "b" ] ~got:[ "b"; "c" ] = ([ "a" ], [ "c" ]));
  (* When both sides agree, there is nothing to explain. *)
  unit "diff of equal lists is empty" (fun () ->
      diff ~expected:[ "a" ] ~got:[ "a" ] = ([], []));

  (* read_expected: the grammar-missing fixture's `expected` file has a '#' comment line and one failure line;
     only the failure line comes back. *)
  unit "read_expected skips blank lines and comments" (fun () ->
      read_expected "tools/grammar/tests/grammar-missing"
      = [ "docs/spec/grammar/qubec.ebnf: grammar-missing" ]);

  (* files_under: lists every file below a root, as root-relative paths with '/', sorted. *)
  unit "files_under skips dotfiles and sorts" (fun () ->
      files_under "tools/grammar/tests/grammar-present" ""
      = [ "docs/spec/grammar/qubec.ebnf"; "expected" ]);

  (* check_grammar_present, called directly (the fixtures below test it through run):
     with no grammar file there is exactly one failure, about the grammar path as a whole (line 0)... *)
  unit "a missing grammar is one whole-file failure" (fun () ->
      match check_grammar_present "tools/grammar/tests/grammar-missing" with
      | [ f ] -> f.code = "grammar-missing" && f.file = grammar_path && f.line = 0
      | _ -> false);
  (* ...and with a grammar file present, even an empty one, there is none. *)
  unit "a present grammar is no failure" (fun () ->
      check_grammar_present "tools/grammar/tests/grammar-present" = []);

  (* ---- fixture tests ----
     Every folder in tools/grammar/tests/ is a tiny repository. The whole checker runs on it (run ~root),
     and its failures, in short form, must be exactly the lines of the folder's `expected` file. *)
  fixtures "tools/grammar/tests";
  Printf.printf "%d passed, %d failed\n" !passed !failed;
  exit (if !failed = 0 then 0 else 1)
