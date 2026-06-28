open! Base

let pp_of sexp_of fmt v =
  Stdlib.Format.pp_print_string fmt (Sexp.to_string_hum (sexp_of v))

let buffer_of s =
  let b = Buffer.create 64 in
  Buffer.add_string b s;
  b

let test_each scenarios t =
  List.map scenarios ~f:(fun (name, got, expected) ->
      Alcotest.test_case name `Quick (fun () ->
          Alcotest.(check t) name expected got))
