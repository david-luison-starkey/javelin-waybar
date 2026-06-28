(** Values from Javelin events are formatted as either [Scalar] (string), or
    [Items] (string list). This is an artificial designation since the event
    payload is just a JSON-like string. *)
type field_value = Scalar of string | Items of string list

(** Event payload sent by the Javelin firmware.

    e: event

    p: paper_tape
    - o: outline, string (single chord) or string list (multiple chords)
    - d: dictionary, string
    - t: translation, string option (not present when outline is "*")
    - u: undo, int option (appears when outline is "*")

    s: suggestion
    - c: count, int (number of strokes tracked to make current suggestion/s)
    - t: translation, string
    - o: output, (single suggestion) or string list (multiple suggestions)
    - d: dictionary, string (potentially string list if multiple dictionaries
      are the source of the suggestions) *)
type t =
  | Paper_tape of {
      outline : field_value;
      dictionary : string option; (* Raw, never wrapped in quotations *)
      undo : int option;
      translation : string option;
    }
  | Suggestion of {
      count : int;
      translation : string;
      output : field_value;
      dictionary : string option; (* Raw, never wrapped in quotations *)
    }
[@@deriving equal, sexp_of]

val parse_event : string -> (t, string) result
(** Parse a Javelin event to [t], returning Error if [string] doesn't match [t]
    shape. *)

val get_translation : t -> string
(** Return [translation] from [t], returning "*" if no translation is present
    (i.e. stroke deletion). *)
