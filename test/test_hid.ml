open! Base
open Javelin_waybar
open Hid
open Test_helpers

let test_drain_splits () =
  let b = buffer_of "c07 OK\n\nEV e: p\n\nleftov" in
  Alcotest.(check (list string))
    "complete messages only" [ "c07 OK"; "EV e: p" ] (drain b)

let test_drain_remainder () =
  let b = buffer_of "c07 OK\n\nEV e: p\n\nleftov" in
  ignore (drain b);
  Alcotest.(check string)
    "incomplete messages left in buffer" "leftov" (Buffer.contents b)

let test_get_connection_id () =
  Alcotest.(check (option string))
    "connection id extracted from message" (Some "c07")
    (get_connection_id [ "c07 OK"; "EV e: p" ])

let test_get_connection_id_none () =
  Alcotest.(check (option string))
    "empty list returns None" None (get_connection_id [])

let suite =
  [
    ( "drain",
      [
        Alcotest.test_case {|splits on \n\n|} `Quick test_drain_splits;
        Alcotest.test_case "leaves only trailing incomplete messages in buffer"
          `Quick test_drain_remainder;
      ] );
    ( "connection_id",
      [
        Alcotest.test_case "extracts connection id from list of messages" `Quick
          test_get_connection_id;
        Alcotest.test_case "empty list returns None" `Quick
          test_get_connection_id_none;
      ] );
  ]
