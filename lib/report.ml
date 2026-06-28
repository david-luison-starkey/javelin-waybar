open! Base
module B = Bigstringaf

let size = 64

type t = B.t

let strip_null s = String.filter s ~f:(fun c -> not (Char.equal c '\000'))

let of_command command =
  let buf = B.of_string ~off:0 ~len:size (String.make size '\000') in
  let payload = command ^ "\n" in
  B.blit_from_string payload ~src_off:0 buf ~dst_off:1
    ~len:(String.length payload);
  buf

let to_string ?len buf =
  let len = Option.value len ~default:(B.length buf) in
  B.substring buf ~off:0 ~len |> strip_null
