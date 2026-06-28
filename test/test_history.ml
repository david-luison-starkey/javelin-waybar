open! Base
open Javelin_waybar
open History
open Test_helpers

let recent_rows =
  [
    ("grows under cap", add [ "a" ] "b" ~cap:5, [ "b"; "a" ]);
    ("evicts oldest", add [ "b"; "a" ] "c" ~cap:2, [ "c"; "b" ]);
    ("empty start", add [] "a" ~cap:2, [ "a" ]);
  ]

let suite =
  [ ("add_recent", test_each recent_rows (Alcotest.list Alcotest.string)) ]
