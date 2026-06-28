open! Base

let connect_command = "hello"
let msg_term = String.Search_pattern.create "\n\n"

let drain b =
  match
    Buffer.contents b |> String.Search_pattern.split_on msg_term |> List.rev
  with
  | [] -> []
  | trailing :: msgs ->
      Buffer.clear b;
      Buffer.add_string b trailing;
      List.rev msgs

let get_connection_id = function
  | [] -> None
  | hd :: _ -> String.lsplit2 hd ~on:' ' |> Option.map ~f:fst
