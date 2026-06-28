(lang dune 3.23)

(name javelin-waybar)

(generate_opam_files true)

(license MIT)

(authors "David Starkey")

(package
 (name javelin-waybar)
 (synopsis "Jarne/Javelin stenography paper tape for Waybar")
 (description "Jarne/Javelin stenography paper tape for Waybar")
 (depends
  (ocaml
   (>= "4.14"))
  base
  ppx_jane
  stdio
  bigstringaf
  yojson
  hidapi
  (alcotest :with-test)
  (odoc :with-doc)))
