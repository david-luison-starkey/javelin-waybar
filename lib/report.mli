type t = Bigstringaf.t
(** The fixed-length packet exchanged with the Javelin firmware. *)

val size : int
(** Packet size in bytes. *)

val of_command : string -> t
(** Return Bigstringaf [t] loaded with Javelin firmware command, starting with a
    null report id byte.
    @raise Invalid_argument if command [string] is longer than [t]. *)

val to_string : ?len:int -> t -> string
(** Convert buffer [t] contents to string, stripping all null bytes.
    @param len number of bytes to convert, defaults to [t] length. *)
