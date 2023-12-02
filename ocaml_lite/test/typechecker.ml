(* Tests for the typechecker*)
open OUnit2
open Ocaml_lite.Typechecker


(* 
INPUT                   OUTPUT
1 + true                error
1 + 2                   pass
1 - true                error
1 - "string"            error
1 * true                error
true * false            error
true AND false          pass
true AND 1              error
1 AND  false            error
false ^ "string"        error
 *)