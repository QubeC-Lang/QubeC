(* QubeC Grammar Checker.
   Has to be run from the project root: `ocaml tools/grammar/check.ml`
   Exits with 0 when every check passes, 1 otherwise. *)

(* ==================================== Failures and Failure Strings ==================================== *)

(* A failure of a check. *)
type failure = {
  file : string;    (* file path relative to the root with '/' as separator *)
  line : int;       (* line number at which the failure occurs, 1-based; 0 means the file as a whole *)
  code : string;    (* stable check code of the failure, e.g. `grammar-missing` *)
  message : string; (* human-readable message of the failure, e.g. "no grammar file" *)
}

(* [failure line file code message] constructs a failure with the given line, file, code, and message.
    The line is optional and defaults to 0, which means the file as a whole. *)
let failure ?(line = 0) (file : string) (code : string) (message : string) : failure =
  { file; line; code; message }

(* [render f] returns the string representation of a failure.
   It is in the format of `file:line: code: message` when a line is specified,
  or `file: code: message` when the entire file is the subject of the failure (line = 0). *)
let render (f : failure) : string =
  if f.line = 0
  then Printf.sprintf "%s: %s: %s" f.file f.code f.message
  else Printf.sprintf "%s:%d: %s: %s" f.file f.line f.code f.message

(* [compare_failures a b] compares two failures [a] and [b] for sorting.
   It returns a negative number if [a] is less than [b], 0 if they are equal, and a positive number if [a] is greater than [b].
   The comparison is done first by file path, then by line number, and finally by code. *)
let compare_failures (a : failure) (b : failure) : int =
  (* Compare by the tuple (file, line, code) to ensure a stable ordering. *)
  compare (a.file, a.line, a.code) (b.file, b.line, b.code)


(* ==================================== File Utilities ==================================== *)

(* The path to the grammar file, relative to the project root. *)
let grammar_path = "docs/spec/grammar/qubec.ebnf"

(* [exists root rel] returns true if the file at [root/rel] exists, false otherwise. *)
let exists root rel = Sys.file_exists (Filename.concat root rel)

(* [read_file root rel] reads the entire contents of the file at [root/rel] and returns it as a string. *)
let read_file root rel =
  In_channel.with_open_bin (Filename.concat root rel) In_channel.input_all

let lines text = String.split_on_char '\n' text

(* Every regular file under root/rel, as root-relative paths, sorted.
   Dotfiles (such as .DS_Store) are skipped; a missing directory gives []. *)
let rec files_under root rel =
  let dir = Filename.concat root rel in
  if not (Sys.file_exists dir && Sys.is_directory dir) then []
  else
    Sys.readdir dir |> Array.to_list
    |> List.filter (fun name -> not (String.starts_with ~prefix:"." name))
    |> List.sort compare
    |> List.concat_map (fun name ->
           let child = if rel = "" then name else rel ^ "/" ^ name in
           if Sys.is_directory (Filename.concat root child) then files_under root child
           else [ child ])


(* ==================================== Checks ==================================== *)
(* Each check takes the root and returns its failures. A check never
   raises for a problem in the repository: it reports a failure. *)

(* [check_grammar_present root] checks that the grammar file exists at [root/grammar_path].
   If it does not exist, it returns a single failure with code "grammar-missing" and message "no grammar file".
   If it exists, it returns an empty list. *)
let check_grammar_present (root : string) : failure list =
  if exists root grammar_path
  then []
  else [ failure grammar_path "grammar-missing" (Printf.sprintf "The provided path %s does not have a grammar file in location %s." root grammar_path) ]

(* [checks] is the list of all checks to run. Each check takes the root and returns its failures. *)
let checks : (string -> failure list) list = [ check_grammar_present ]

(* ==================================== Entry points ==================================== *)

(* [run ~root] runs all the checks on the given root directory and returns a list of failures.
   The failures are sorted by file, line, and code. *)
let run ~(root : string) : failure list =
  List.concat_map (fun check -> check root) checks |> List.sort compare_failures

let main () =
  let root = Sys.getcwd () in
  let failures = run ~root in
  if failures = [] then (
    print_endline "All checks passed.";
    exit 0)
  else (
    Printf.printf "%d failure(s):\n" (List.length failures);
    List.iter (fun f -> Printf.printf "\t%s\n" (render f)) failures;
    exit 1)

let () = if Filename.basename Sys.argv.(0) = "check.ml" then main ()
