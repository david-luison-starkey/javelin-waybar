val connect_command : string
(** Command to initiate a stable communication channel with the Javelin
    firmware, as per the web tools help command. *)

val drain : Buffer.t -> string list
(** Remove complete messages - denoted by \n\n - from the buffer, returning a
    list of "drained" messages (in order of appearance), and preserving
    incomplete messages in the buffer. *)

val get_connection_id : string list -> string option
(** Parses the connection id from the [connect_command] return message, or
    [None] if no id is found. *)
