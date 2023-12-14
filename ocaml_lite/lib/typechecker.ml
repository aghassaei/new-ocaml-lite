open Menhir_parser
open Ast

(* My main issue with the typechecker was figuring out how to fit the pieces together *)

(* Placeholder for unfinished branches *)
let tmsg = "Typechecker: not implemented yet"

(* type to build constraints *)
type c_type = 
(* Base types *)
| CInt                         
| CBool   
| CString
| CUnit                       
| CUser of string 
(* Types from source code *)             
| CFun of c_type * c_type
| CTuple of c_type list
(* Variables for types, indexed by integers *)
| CVar of int   
(* Quantifiers *)         
| CForall of string * c_type   

(* Type for constraints, which may be one of four types. Idea to have subtypes of constraints from Sam *)
type const = 
| Ident                                (* t1 ~ t1 *)
| NewConstrs of (c_type * c_type) list (* t1 ~ t2; t3 ~ int, etc*)
| Map of int * c_type                  (* t1 |-> int *)
| SingleConstraint of c_type * c_type  (* NOTE: idea here was to have a type to match a single constraint with in unify_single_constraint. Probably not actually necessary since I could just pattern match on a constr list with one element *)

(* A context is what you are given when you are typechecking an expression. 
The reason that it is string * c_type is so that a named variable may be associated with the c_type CVar i, then i gets mapped to some other c_type (also an idea from Sam). *)
type context = (string * c_type) list

(* Helper function to flatten a string list into a single string *)
let rec join (l : string list) (sep : string) : string = 
  match l with
  | [] -> ""
  | h :: t -> h ^ sep ^ (join t)

(* Print function for internal constraint types *)
let rec ctype_to_string (c : c_type) : string = 
  match c with  
  | CInt -> "int"
  | CBool -> "bool"
  | CString -> "string"
  | CUnit -> "unit"             
  | CUser s -> s (* user defined types are already strings*)
  | CFun(a, b) -> "fun " ^ (ctype_to_string a) ^ " -> " ^ (ctype_to_string b)
  | CTuple(l) -> "[" ^ (join ((List.map ctype_to_string l) ";")) ^ "]"
  | CVar s -> "CVar " ^ string_of_int s
  | CForall(s, c) -> "forall " ^ s ^ ": " ^ (ctype_to_string c)



(* TYPECHECKER *)
(* Takes a program (list of bindings) and returns unit if it passes (fails otherwise) *)


(* Unify a system of constraints: takes constraint list and return list with modifications to make it unified *)
let rec unify (consts : const list) : const list = 
  match consts with
  | [] -> []
  | SingleConstraint(t1, t2) :: rest -> failwith tmsg (* Something along the lines of let reduction = reduce t1 t2 in... *)
  (* pseudo code for after you get the reduced form of a constraint
     match reduction with 
     | a trivial constraint (ex: 'x = 'x, int = int) -> do nothing (Ident) 
     | function type (f * g) -> break apart into new constraints  (NewConstrs [(a1, a2);(b1, b2)])
     | type variable in need of substitution -> 
          1. replace variable with t, getting rid of variable
          2.  add substitution t/variable to solution 
     | _ -> failwith "No more forms of the reduction" *)
  
(* Solve a single constraint - I didn't know how to incorporate this into the function above *)
let unify_single_constraint (c: const) : const list = 
match c with 
(* If two variables, map one to the other *)
| SingleConstraint(CVar t1, CVar t2) -> [c]

(* If first is a variable *)
(* | Map(CVar t1, c) -> m *) (* for rest with variables, just return m?*)

(* function
| SingleConstraint(CFun(a1, b1), CFun (a1, b2)) -> [unify Map(a1, a2) :: unify Map(b1, b2)] *)

(* tuple *)
(* | SingleConstraint(CTuple l1, CTuple l2) -> List.map2 unify l1 l2 *)

(* base types *)
| SingleConstraint(x, y) -> if x = y then [c] else failwith ("Types " ^ (ctype_to_string x) ^ " and " ^ (ctype_to_string y) ^ " cannot be unified.")


(* find expression in b, generate constraints for expressions, return pair of what it's bound to and constraints *)
(* unify after every let binding *)
let rec typecheck_binding (b : binding) (ctx : context) : const list = function 
  | NonRecursiveBind(s, pl, t, e) -> 
        let c = unify (typecheck_expr (e, [])) in Map(s, c)
  | RecursiveBind(s, pl, t, e) -> 
        let c = unify (typecheck_expr (e, [])) in Map(s, c)
  | TypeBind(s, t_list) ->
        let c = unify (typecheck_expr (e, [])) in Map(s, c)


(* given some context and expression, generate a type for that expression with constraints, then (in different function probably) run unifi
   cation on constraint set  to get a substitution sequence S (your solution), apply the substitution to type, so the 
   final inferred type is t with S applied*)
and typecheck_expr (e : expr) (ctx : context ) : const list =
  match e with 
(* match for all types of expressions in the AST *)
  | LetRecInExpr(s, pl, t, e1, e2) -> failwith tmsg (* return constraints from e1 and e2, when gettting constraints pass Map(name, t) into context*)
  | LetInExpr(s, pl, t, e1, e2) -> failwith tmsg (* return constraints from e1, e2*)
  | ConditionExpr(e1, e2, e3) -> failwith tmsg (* return constraint [e1 ~ e2], [e2 ~ e3], and the constraints of each expression*)
  | FunExpr (pl, t, e) -> failwith tmsg (* CFun(t, typecheck_expr e), map *)
  | FunAppExpr (e1, e2)  -> failwith tmsg (* typecheck_expr on e1 and e2*)
  | TupleExpr (e_list) -> failwith tmsg (* List.map typecheck_expr e_list*)
  | MatchExpr (e, branches) -> failwith tmsg (* typecheck_expr, typecheck_branch on branches  *)
  | BExpr (e1, op, e2) -> failwith tmsg
  | UExpr (op, e)  -> failwith tmsg
  | IntLit i -> failwith tmsg
  | BoolLit bl -> failwith tmsg
  | StringLit s -> failwith tmsg
  | IdLit x -> failwith tmsg
  | UnitLit -> failwith tmsg

  and typecheck_matchbranch (b : branch) (ctx : context) : 'c = failwith tmsg

(* Base function *)
let typecheck (bindings : binding list ) : unit = 
  (* Get constraints from all bindings *)
  let constraints = List.map typecheck_binding bindings in 

  (* Unify those constraints *)
  let _ = unify constraints in () (* unify outer mappings *)

