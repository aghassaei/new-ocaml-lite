open Lexer
open Ast


(** Using your expect function: Raise an error if the next token in the list is not the expected token.
    Otherwise return the rest of the token list _after_ the expected token. *)


(* when to use let, and, function  *)

(* Used to have errors in format <raise (ParseError("Expected " ^ tok_to_str t ^ ", got " ^ tok_to_str x))>
   but it would give "This variant expression is expected to have type exn
       There is no constructor ParseError within type exn"
       so i switched to failwith *)

let expect (t : token) : token list -> token list = function
  | [] -> failwith ("Unexpected end of input: expected " ^ tok_to_str t)
  | x :: xs ->
    if x = t then xs
    else failwith ("Expected " ^ tok_to_str t ^ ", got " ^ tok_to_str x)



(* BINDINGS *)    
let rec parse_binding : token list -> binding * token list = function
(* Nonrecursive bindings *)
| Let :: Id (s) :: r ->                                           
  let (ps, r2) = parse_param_list r in            (* parse list of params *)
  let (t, r3) = parse_type (expect Colon r2) in   (* parse type annotation after colon *)
  let (e, r4) = parse_expr (expect Eq r3) in      (* parse expr after equals sign *)
  (NonRecursiveBind(Id, ps, t, e), r4)            (* return nonrecursive binding and remaining tokens *)

(* Parse a program as a list of bindings *)
let parse (src : token list) : binding list = 
  match parse_binding src with 
   | (b, []) -> [b]
   | (_, t :: _) -> failwith ("Expected end of input but got '" ^ tok_to_str t ^"'" ) 
 