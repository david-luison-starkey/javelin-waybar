open! Base
open Javelin_waybar
open Event
open Test_helpers

let d_jev = Alcotest.testable (pp_of sexp_of_t) equal
let javelin_event_res = Alcotest.result d_jev Alcotest.string

let outline_decode_rows =
  [
    ( "fields split into event (e + o keys)",
      parse_event "e: p\no: WAU",
      Ok
        (Paper_tape
           {
             outline = Scalar "WAU";
             dictionary = None;
             undo = None;
             translation = None;
           }) );
    ( "plain quoted outline decoded",
      parse_event "e: p\no: \"{pre^}\"",
      Ok
        (Paper_tape
           {
             outline = Scalar "{pre^}";
             dictionary = None;
             undo = None;
             translation = None;
           }) );
    ( "interior quote in outline survives",
      parse_event "e: p\no: \",\\\"\"",
      Ok
        (Paper_tape
           {
             outline = Scalar {|,"|};
             dictionary = None;
             undo = None;
             translation = None;
           }) );
    ( "list outline keeps item quotes",
      parse_event "e: p\no: [\"KP\", \"HROPB\"]",
      Ok
        (Paper_tape
           {
             outline = Items [ "\"KP\""; "\"HROPB\"" ];
             dictionary = None;
             undo = None;
             translation = None;
           }) );
  ]

let parse_event_rows =
  [
    ( "undo stroke has translation None",
      parse_event "e: p\no: \"*\"\nu: 1",
      Ok
        (Paper_tape
           {
             outline = Scalar "*";
             dictionary = None;
             undo = Some 1;
             translation = None;
           }) );
    ( "non-int count is Error, never raises",
      parse_event "e: s\no: x\nd: dd\nt: tt\nc: notnum",
      Error "suggestion count is not an int" );
    ( "clean translation is unwrapped",
      parse_event "e: p\no: \"WAU\"\nt: \"what\"",
      Ok
        (Paper_tape
           {
             outline = Scalar "WAU";
             dictionary = None;
             undo = None;
             translation = Some "what";
           }) );
    ( "suggestion translation is decoded",
      parse_event "e: s\no: x\nd: dd\nt: \",\\\"\"\nc: 2",
      Ok
        (Suggestion
           {
             count = 2;
             translation = {|,"|};
             output = Scalar "x";
             dictionary = Some "dd";
           }) );
  ]

let translation_of msg = parse_event msg |> Result.map ~f:get_translation

let translation_decode_rows =
  [
    ( "escaped quote decoded in translation",
      translation_of "e: p\no: \"X\"\nt: \"\\\"\"",
      Ok {|"|} );
    ( "escaped backslash decoded in translation",
      translation_of "e: p\no: \"X\"\nt: \"\\\\\"",
      Ok {|\|} );
    ( "escaped n decoded to real newline in translation",
      translation_of "e: p\no: \"X\"\nt: \"\\n\"",
      Ok "\n" );
    ( "escaped-backslash then literal n in translation",
      translation_of "e: p\no: \"X\"\nt: \"\\\\n\"",
      Ok {|\n|} );
  ]

let suite =
  [
    ("parse_event", test_each parse_event_rows javelin_event_res);
    ( "outline decoded via parse_event",
      test_each outline_decode_rows javelin_event_res );
    ( "translation decoded via parse_event",
      test_each translation_decode_rows
        (Alcotest.result Alcotest.string Alcotest.string) );
  ]
