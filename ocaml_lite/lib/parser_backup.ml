open Lexer
open Ast

let msg = "not implemented yet"

(* HELPER FUNCTIONS *)
(* Raise an error if the next token in the list is not the expected token.
  Otherwise return the rest of the token list _after_ the expected token. *)
let expect (t : token) : token list -> token list = function
  | [] -> failwith ("Unexpected end of input: expected " ^ tok_to_str t) (* NOTE: Used to have errors in format <raise (ParseError("Expected " ^ tok_to_str t ^ ", got " ^ tok_to_str x))> but it would give "This variant expression is expected to have type exn. There is no constructor ParseError within type exn" so i switched to failwith *)
  | x :: xs ->
    if x = t then xs
    else failwith ("Expected " ^ tok_to_str t ^ ", got " ^ tok_to_str x)



(* BINDINGS *)    
let rec parse_binding : token list -> binding * token list = function
  (* Nonrecursive bindings *) (* Does not account for typ option*)
  | Let :: Id s :: r ->      
  (* let (ps, r2) = parse_param_list r in
     (match r2 with 
     | Colon :: rest -> parse type on rest, expect =, parse expr)  *)
    let (ps, r2) = parse_param_list r in  
    ( match r2 with 
    | Colon :: r3 -> let (t, r4) = parse_typ_option r3 in 
                      let (e, r5) = parse_expr (expect Eq r4) in failwith msg
    | Eq :: r3 -> failwith msg)         (* parse list of params *)
    (* let (t, r3) = parse_type (expect Colon r2) in  *)  (* parse type annotation after colon *)
    (*let (e, r4) = parse_expr (expect Eq r3) in    *)   (* parse expr after equals sign *)
    (*(NonRecursiveBind(s, ps, t, e), r4)          *)   (* return nonrecursive binding and remaining tokens *)

  (* Recursive bindings *)
  | Let :: Rec :: Id s :: r -> 
    let (ps, r2) = parse_param_list r in            (* parse list of params *)
    let (t, r3) = parse_type (expect Colon r2) in   (* parse type annotation after colon *)
    let (e, r4) = parse_expr (expect Eq r3) in      (* parse expr after equals sign *)
    failwith "not yet"
    (* (RecursiveBind(Id s, ps, t, e), r4)               return recursive binding and remaining tokens *)
  
  (* Type definitions *)
  | Type :: Id s:: Eq :: rest -> failwith "Not implemented"        (* let (subtypes, rest2) = parse_typedef_list rest*)     (* have typedef helper deal with pipe type sequence *)

  | _ -> failwith "Other cases"

(* deals with second half of type binding for single subtybe *)
and parse_typedef_list : token list -> (string * typ option) list * token list = function
  (* | Pipe :: rest -> parse_typedef rest
  | x -> raise (ParseError("got" ^ tok_to_str x)) *)
  | _ -> failwith "not yet"

and parse_typedef : token list -> string * (typ option) * (token list) = function 
  (* | Id :: Of :: rest -> (Id, parse_type rest)
  | Id :: rest -> (Id, rest)
  | x -> raise (ParseError("what? got:  " ^ tok_to_str x)) *)
  | _ -> failwith "msg"



and parse_param_list : token list -> param list * token list = function 
(* | [] :: r -> failwith "Return r?" *) (* This variant pattern is expected to have type token
       There is no constructor [] within type token *)
| Id s :: r -> failwith "Not sure yet"
| _ -> failwith "parse_param_list not implemented"

(* EXPRESSIONS  *)
and parse_expr : token list -> expr * token list = function 
(* 
  (* Nonrecursive let expressions *)
  | Let :: Id :: r ->                    
    let (ps, r2) = parse_param_list r in           (* parse list of params *)
    let (t, r3) = parse_type (expect Colon r2) in  (* parse type annotation after colon *)
    let (e, r4) = parse_expr (expect Eq r3) in     (* parse expr1 after equals sign *)
    let (e2, r5) = parse_expr (expect In r4) in      (* parse expr2 after In *)
    (LetInExpr(Id, ps, t, e, e2 ), r5)             return let expression and remaining tokens *)
(* 
(* Recursive let expressions *)
| Let :: Rec :: Id :: r ->
    let (ps, r2) = parse_param_list r in            (* same as above, but returns the recursive ast version *)
    let (t, r3) = parse_type (expect Colon r2) in    
    let (e, r4) = parse_expr (expect Eq r3) in
    let (e2, r5) = parse_expr (expect In r4) in
    (LetRecInExpr(Id, ps, t, e, e2 ), r5)

(* If statements *)       
| If :: rest -> 
let (e, r2) = parse_expr rest in                (* parse first expression *)
let (e2, r3) = parse_expr (expect Then r2) in   (* parse second expression after Then *)
let (e3, r4) = parse_expr (expect Else r3) in   (* parse third expression after Else *)
(ConditionExpr(e, e2, e3), r4)                  (* return if statement and remaining tokens *)

(* Functions *)
| Fun :: rest -> 
let (ps, r) = parse_param_list rest in          (* parse list of params *)
let (t, r2) = parse_type (expect Colon r) in
let (e, r3) = parse_expr (expect DoubleArrow r2) in
(FunExpr(ps, t, e), r3) *)

(* Unit
| LParen :: RParen :: r -> (UnitLit(), r) *)

(* Tuple or nested expression *)
(* | LParen :: rest -> 
let (e, r) = parse_expr rest in
(match r with 
| Comma :: r2 -> TupleExpr([e, parse_expr], r2)                (* comma *)
| RParen :: r2 -> raise(ParseError("not written yet"))          (* end of tuple or nested expr *)
| _ -> raise (ParseError("go this after parsing ( <expr>: " ^ tok_to_str r)))
| Match :: rest ->
let (e, r) = parse_expr rest in 
let (branches, r2) = parse_match_branch_list (expect With r) in
(MatchExpr(e, branches), r2)
| Mod :: rest -> raise(ParseError("not written yet"))
| Eq  :: rest ->   raise(ParseError("not written yet"))        
| Plus :: rest -> raise(ParseError("not written yet"))
| Minus :: rest -> raise(ParseError("not written yet"))
| Times  :: rest -> raise(ParseError("not written yet"))
| Divide  :: rest -> raise(ParseError("not written yet"))
| Lt   :: rest -> raise(ParseError("not written yet"))
| Concat :: rest -> raise(ParseError("not written yet"))
| And   :: rest -> raise(ParseError("not written yet"))
| Or  :: rest -> raise(ParseError("not written yet"))
| Not  :: rest -> raise(ParseError("not written yet"))
| Negate  :: rest -> raise(ParseError("not written yet"))
| DoubleSemicolon :: rest -> raise(ParseError("not written yet")) *)
(* Still missing: function applications, literals *)
| _ -> failwith "parse_expr not implemented"

(* | MatchExpr of expr * (string * string list * expr) list *)
and parse_match_branch_list : token list -> (string * string list * expr) list * token list = function 
(* 
| Pipe :: Id :: rest -> raise(ParseError("not written yet"))
        (* let (pvs, r) = parse_pattern_vars rest in 
        let (e, r2) = parse_expr (expect DoubleArrow r) *) *)
| _ -> failwith "no"     

and parse_param : token list -> param * token list = function
  | _ -> failwith "no"
  (* | Id :: r -> (Id, r)
  | LParen :: r -> 
      let (p, r2) = parse_param r in 
      let (t, r3) = parse_type (expect Colon r2) in
      (Id, t, (expect RParen r3))
  | x -> failwith "error" (*parse_expr x*) Also not sure what next move is here *)

(* and parse_param_list : token list -> param list * token list = function
  | [] :: r -> r 
  | Id :: r ->  *)

(* and parse_type : token list -> typ * token list = function 
  | Bool :: r -> (BoolTy(), r)
  | Int :: r -> (IntTy(), r)
  | LParen :: RParen :: r -> (UnitTy(), r)
  | LParen :: r -> 
            let (t1, r1) = parse_type r 
  | RParen :: rest -> raise(ParseError("not written yet")) *)
    
and parse_unop : token list -> unop * token list = function 
(* | Not :: r -> 
        let (e, r2) = parse_expr r in 
       (UExpr(NotOp(), e), r2)
| Neg :: r -> 
      let (e, r2) = parse_expr r in 
      ((UExper(NegOp(), e ), r2)) *)
| _ -> failwith "msg"




(* Base types *)
and parse_type : token list -> typ * token list = function 
(* | TBool :: r -> (BoolTy(), r)
| TString :: r -> (StringTy(), r) 
| TInt :: r -> (IntTy() , r)
| TUnit :: r -> (UnitTy(), r) 
| Id :: r -> (IdTy(), r)
| Fun :: r -> (FunTy(), r)
| Arrow :: r -> parse_type r        (* expect another type to follow *)
| Times :: r -> parse_type r        expect another type to follow *)
| _ :: r -> failwith("not implemented")     (*TODO*)


(* Parse a program as a list of bindings *)
let parse (src : token list) : binding list = 
  match parse_binding src with 
   | (b, []) -> [b]
   | (_, t :: _) -> failwith ("Expected end of input but got '" ^ tok_to_str t ^"'" ) 
 