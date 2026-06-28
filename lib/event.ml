open! Base

let ( let* ) m f = Result.bind m ~f

type field_value = Scalar of string | Items of string list
[@@deriving equal, sexp_of]

type t =
  | Paper_tape of {
      outline : field_value;
      dictionary : string option;
      undo : int option;
      translation : string option;
    }
  | Suggestion of {
      count : int;
      translation : string;
      output : field_value;
      dictionary : string option;
    }
[@@deriving equal, sexp_of]

let unescape s =
  let rec inner acc = function
    | [] -> String.of_char_list (List.rev acc)
    | '\\' :: 'n' :: rest -> inner ('\n' :: acc) rest
    | '\\' :: 't' :: rest -> inner ('\t' :: acc) rest
    | '\\' :: 'r' :: rest -> inner ('\r' :: acc) rest
    | '\\' :: c :: rest -> inner (c :: acc) rest
    | c :: rest -> inner (c :: acc) rest
  in
  inner [] (String.to_list s)

let get_translation = function
  (* Assuming that the absence of a translation can only be in the case of an undo stroke *)
  | Paper_tape p -> Option.value p.translation ~default:"*"
  | Suggestion s -> s.translation

let decode_scalar s =
  (match String.chop_prefix s ~prefix:"\"" with
    | None -> s
    | Some rest -> String.chop_suffix_if_exists rest ~suffix:"\"")
  |> unescape

let decode_value v =
  match String.chop_prefix v ~prefix:"[" with
  | Some rest ->
      let items =
        String.chop_suffix_if_exists rest ~suffix:"]"
        |> String.split ~on:',' |> List.map ~f:String.strip
      in
      Items items
  | None -> Scalar (decode_scalar v)

let parse_fields packet =
  String.split_lines packet
  |> List.filter_map ~f:(fun line ->
      String.lsplit2 line ~on:':'
      |> Option.map ~f:(fun (k, v) -> (String.strip k, String.strip v)))

let parse_event e =
  let fields = parse_fields e in
  let find k = List.Assoc.find fields k ~equal:String.equal in
  let require k =
    Result.of_option (find k) ~error:(k ^ " key not present in message " ^ e)
  in
  let* event_type = require "e" in
  match event_type with
  | "p" ->
      let* o = require "o" in
      let t = find "t" in
      let d = find "d" in
      let u = find "u" in
      Ok
        (Paper_tape
           {
             outline = decode_value o;
             dictionary = d;
             translation = Option.map t ~f:decode_scalar;
             (* We never expect u to not be an int-shaped string *)
             undo = Option.bind u ~f:Int.of_string_opt;
           })
  | "s" ->
      let* o = require "o" in
      let d = find "d" in
      let* t = require "t" in
      let* c = require "c" in
      (* We never expect c to not be an int-shaped string, and always present for Suggestion event *)
      let* count =
        Result.of_option (Int.of_string_opt c)
          ~error:"suggestion count is not an int"
      in
      Ok
        (Suggestion
           {
             output = decode_value o;
             dictionary = d;
             translation = decode_scalar t;
             count;
           })
  (* Parse, don't validate *)
  | _ -> Error ("Unrecognised event: " ^ event_type)
