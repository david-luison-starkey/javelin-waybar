(** Javelin-Waybar produces a binary that:
    - connects to a Jarne keyboard using the Javelin firmware over HID,
    - writes a JSON file following the schema expected by Waybar to /tmp,
    - and reconnects to a Jarne if the connection is interrupted.

    Once a Waybar module is configured to read from this JSON file, a
    stenography paper tape Waybar segment is created. *)

module Hid = Hid
(** HID protocol related functions and variables. *)

module Report = Report
(** Fixed length HID report exchanged with Javelin and utilities. *)

module Event = Event
(** Parsing and typed representation of Javelin events. *)

module Waybar = Waybar
(** Build Waybar JSON to render stenography paper tape in Waybar segment. *)

module History = History
(** Bounded history of stenography translations and suggestions. *)
