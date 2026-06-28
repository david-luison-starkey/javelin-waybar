open! Base
open Javelin_waybar
open Waybar
open Test_helpers

let payload_rows =
  [
    ( "basic",
      to_payload [ "what"; "the" ],
      {|{"text":"what","tooltip":"what\nthe","markup":"pango"}|} );
    ( "embedded quote escaped",
      to_payload [ {|say, "|} ],
      {|{"text":"say, \"","tooltip":"say, \"","markup":"pango"}|} );
    ( "empty history",
      to_payload [],
      {|{"text":"","tooltip":"","markup":"pango"}|} );
    ( "to_payload escapes ampersand (pango)",
      to_payload [ "R&D" ],
      {|{"text":"R&amp;D","tooltip":"R&amp;D","markup":"pango"}|} );
    ( "to_payload escapes less-than (pango)",
      to_payload [ "<<" ],
      {|{"text":"&lt;&lt;","tooltip":"&lt;&lt;","markup":"pango"}|} );
    ( "to_payload escapes greater-than (pango)",
      to_payload [ ">" ],
      {|{"text":"&gt;","tooltip":"&gt;","markup":"pango"}|} );
    ( "to_payload escapes a real newline as visible backslash-n",
      to_payload [ "a\nb" ],
      {|{"text":"a\\nb","tooltip":"a\\nb","markup":"pango"}|} );
    ( "to_payload escapes a real tab as visible backslash-t",
      to_payload [ "a\tb" ],
      {|{"text":"a\\tb","tooltip":"a\\tb","markup":"pango"}|} );
    ( "to_payload escapes a real carriage return as visible backslash-r",
      to_payload [ "a\rb" ],
      {|{"text":"a\\rb","tooltip":"a\\rb","markup":"pango"}|} );
    ( "to_payload escapes a literal backslash by doubling it",
      to_payload [ {|a\b|} ],
      {|{"text":"a\\\\b","tooltip":"a\\\\b","markup":"pango"}|} );
  ]

let suite = [ ("to_payload", test_each payload_rows Alcotest.string) ]
