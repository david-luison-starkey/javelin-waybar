open! Base

let cap = 20
let add history entry ~cap = List.take (entry :: history) cap
