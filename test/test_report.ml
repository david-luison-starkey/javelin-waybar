open! Base
open Javelin_waybar
open Test_helpers

let test_report_to_string () =
  Alcotest.(check string)
    "Report is converted to string" "hello\n"
    (Report.to_string (Report.of_command "hello"))

let report_len_rows =
  let buf = Bigstringaf.of_string ~off:0 ~len:64 ("hi" ^ String.make 62 'Z') in
  let padded =
    Bigstringaf.of_string ~off:0 ~len:64 ("ab\000cd" ^ String.make 59 '\000')
  in
  [
    ("len bounds output to first n bytes", Report.to_string ~len:2 buf, "hi");
    ( "without len, tail junk is included",
      Report.to_string buf,
      "hi" ^ String.make 62 'Z' );
    ("len shorter than payload truncates", Report.to_string ~len:1 buf, "h");
    ( "strip_null still runs within the len window",
      Report.to_string ~len:5 padded,
      "abcd" );
  ]

let suite =
  [
    ( "Report.to_string",
      [
        Alcotest.test_case "converts Report to string" `Quick
          test_report_to_string;
      ] );
    ("Report.to_string ~len", test_each report_len_rows Alcotest.string);
  ]
