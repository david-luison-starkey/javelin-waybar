open! Base

(** Convert &, <, and > to HTML entities so they render and aren't interpreted
    as markdown. *)
let pango_escape s =
  String.concat_map s ~f:(function
    | '&' -> "&amp;"
    | '<' -> "&lt;"
    | '>' -> "&gt;"
    | c -> String.of_char c)

(** Escape whitespace characters so that they are rendered as text. *)
let escape_whitespace s =
  String.concat_map s ~f:(function
    | '\\' -> "\\\\"
    | '\n' -> "\\n"
    | '\t' -> "\\t"
    | '\r' -> "\\r"
    | c -> String.of_char c)

let to_payload history =
  let escaped =
    List.map history ~f:(fun s -> pango_escape (escape_whitespace s))
  in
  let text = match escaped with [] -> "" | hd :: _ -> hd in
  let tooltip = String.concat ~sep:"\n" escaped in
  `Assoc
    [
      ("text", `String text);
      ("tooltip", `String tooltip);
      ("markup", `String "pango");
    ]
  |> Yojson.Basic.to_string
