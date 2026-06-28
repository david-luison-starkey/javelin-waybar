val cap : int
(** Steno history length. *)

val add : string list -> string -> cap:int -> string list
(** Add string to history head. If history is full, drops the last element. *)
