open! Base
open Stdio
open Hidapi
open Javelin_waybar
open Hid
open History

let ( let* ) m f = Result.bind m ~f
let product_id = 0x0001
let accepted_usages = [ (0x4C4A, 0x0001); (0xFF31, 0x0074) ]

let is_steno d =
  List.exists accepted_usages ~f:(fun (up, u) ->
      up = d.usage_page && u = d.usage)

let get_devices () = enumerate ~product_id ()
let find_steno_device = List.find ~f:is_steno

let open_device = function
  | None -> Error "No steno devices found"
  | Some v ->
      Result.of_option (open_path v.path) ~error:("No handle for " ^ v.path)

let send_command handle command = write handle (Report.of_command command)

let enable_events handle id event_type =
  Result.map_error
    (send_command handle (id ^ " enable_events " ^ event_type))
    ~f:(fun e -> "error encountered while enabling " ^ event_type ^ ": " ^ e)

let read_response ?(timeout_ms = -1) buf handle =
  match read ~timeout:timeout_ms handle buf Report.size with
  | Error e -> Error e
  | Ok 0 -> Error "Timeout"
  | Ok n -> Ok (Report.to_string buf ~len:n)

let handshake handle buf =
  let acc = Buffer.create Report.size in
  let* _ = send_command handle connect_command in
  let* response = read_response ~timeout_ms:1000 buf handle in
  Buffer.add_string acc response;
  Result.of_option (drain acc |> get_connection_id) ~error:"No messages"

let waybar_signal = "SIGRTMIN+11"

let refresh_waybar () =
  let pid =
    Unix.create_process "pkill"
      [| "pkill"; "--signal"; waybar_signal; "--exact"; "waybar" |]
      Unix.stdin Unix.stdout Unix.stderr
  in
  Unix.waitpid [] pid |> ignore

let filename = "/tmp/javelin-waybar.json"

(** Atomic write to json file tracked by Waybar. *)
let publish data =
  let temp_filename = filename ^ ".tmp" in
  Out_channel.write_all temp_filename ~data;
  Unix.rename temp_filename filename;
  refresh_waybar ()

let rec stream_loop acc hist handle buf =
  match read_response buf handle with
  | Error e -> (hist, e)
  | Ok chunk ->
      Buffer.add_string acc chunk;
      let hist' =
        drain acc
        |> List.fold ~init:hist ~f:(fun hist_acc msg ->
            match String.chop_prefix msg ~prefix:"EV " with
            | None ->
                eprintf "Non event response: %s\n" msg;
                hist_acc
            | Some v -> (
                match Event.parse_event v with
                | Ok ev -> add hist_acc (Event.get_translation ev) ~cap
                | Error e ->
                    eprintf "parse error: %s | raw: %s\n" e msg;
                    hist_acc))
      in
      publish (Waybar.to_payload hist');
      Out_channel.flush stderr;
      stream_loop acc hist' handle buf

let main hist =
  let buf = Bigstringaf.create Report.size in
  match get_devices () |> find_steno_device |> open_device with
  | Error e -> (hist, e)
  | Ok handle ->
      Exn.protectx handle ~finally:close ~f:(fun handle ->
          let setup =
            let* id = handshake handle buf in
            eprintf "Acquired connection id: %s\n" id;
            Out_channel.flush stderr;
            enable_events handle id "paper_tape suggestion"
          in
          match setup with
          | Error e -> (hist, e)
          | Ok _ -> stream_loop (Buffer.create 1024) hist handle buf)

(** Recursive wrapper around [main], attempting re-connection (every 3 seconds)
    if a connection is lost. *)
let rec supervise hist =
  let hist', reason = main hist in
  eprintf "Connection lost: %s\n" reason;
  Out_channel.flush stderr;
  Unix.sleep 3;
  supervise hist'

let () = supervise []
