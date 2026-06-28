val to_payload : string list -> string
(** [to_payload history] maps to the schema expected by Waybar's "return-type":
    "json" configuration, with the list head as "text" and entire list as
    "tooltip". Markup is "pango". *)
