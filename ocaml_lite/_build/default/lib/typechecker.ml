open Menhir_parser
open Ast

let tmsg = "Typechecker: not implemented yet"

(* type to build constraints *)
type c_type = 
| CInt                         (* Base types*)
| CBool   
| CString
| CUnit                       
| CUser of string              (* Types from source code*)
| CFun of c_type * c_type
| CTuple of c_type list
| CVar of int                  (* Variables for types, just indexed by integers *)
| CForall of string * c_type   (* Quantifiers *)


(* A constraint. May be one of three types *)
(* Had the idea to structure things this way from Sam *)
type const = 
| Ident   (* t1 ~ t1 *)
| NewConstrs of (c_type * c_type) list (* t1 ~ t2; t3 ~ int, etc*)
| Map of int * c_type  (* t1 |-> int *)
| SingleConstraint of c_type * c_type

(* A context is what you are given when you are typechecking an expression. The reason that it is string * c_type is so that 
   a named variable may be associated with the c_type CVar i, then i gets mapped to some other c_type. *)
type context = (string * c_type) list


let rec join (l : string list) : string = 
  match l with
  | [] -> ""
  | h :: t -> h ^ (join t)


(* Printer function for internal constraint types *)
let rec ctype_to_string (c : c_type) : string = 
  match c with  
  | CInt -> "int"
  | CBool -> "bool"
  | CString -> "string"
  | CUnit -> "unit"             
  | CUser s -> s (* user defined types are already strings*)
  | CFun(a, b) -> "fun " ^ (ctype_to_string a) ^ " -> " ^ (ctype_to_string b)
  | CTuple(l) -> join (List.map ctype_to_string l)
  | CVar s -> "CVar " ^ string_of_int s
  | CForall(s, c) -> "forall " ^ s ^ ": " ^ (ctype_to_string c)



      (* (match l with 
      | [] -> ""
      | h :: t -> (ctype_to_string h) ^ ";" ^ (ctype_to_string t)
  ) *)

(* Takes AST and throws error if typechecking fails, returns unit otherwise *)





(* Takes a system of constraints and returns a unified list of constraints *)
let rec unify (consts : const list) : const list = 
  match consts with
  | [] -> []
(* | SingleConstraint(t1, t2) :: rest -> let reduction = reduce t1 t2  *)
(* | c :: rest -> let reduction = reduce c in ( *)
  (* redutions can only have a few forms *)
  (* match reduction with  *)
  (* | trivial constraint ('x = 'x, int = int, etc) -> Ident
  | function type -> break into new constraints
  | type variable = t where variable does not appear in t ->
      replace variable with t, getting rid of variable
      add substitution t/variable to solution
  else, fail  *)
(* ) *)
(* options: 1. update solution with new substitutions, add new constraints to consts, or fail *)



(* | Map(t1, t2) :: t -> let new_constr = unify_single_constraints Map(t1, t2) in (
  unify (new_constr :: m)
) *)













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


(* let solve_single ( c : constr ) : constr list = function 
(* If t1 is a variable *)
match c with 
| (CVar t1, t2) -> 
    (match t2 with 
    | CVar -> (t1, t2)) (* should be if t1=t2 then do nothing, else arbitrarily map one to the other *)

(* If both are function types *)
| (CFun f1, CFun f2) ->  *)

(* substitution: sequence of smaller substitutions, carried out in order *)
(* S unifies a constrain t1 ~ t2 if t1 S = t2 S *)
  (* a substitution S unifies a set of constraints if it unifies all the constraints in the set *)


(* find expression in b, generate constraints for expressions, return pair of what it's bound to and constraints *)
(* unify after every let binding *)
let rec typecheck_binding (b : binding) (ctx : context) : const list = function 
  | NonRecursiveBind(s, pl, t, e) -> 
        let c = unify (typecheck_expr (e, [])) in Map(s, c)
  | RecursiveBind(s, pl, t, e) -> 
        let c = unify (typecheck_expr (e, [])) in Map(s, c)
  | TypeBind(s, t_list) ->
        let c = unify (typecheck_expr (e, [])) in Map(s, c)



(* constraints specific to binding, environment needs to carry over  *)

(* here when we unify, we unify local mappings *)
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

(*  *)
let typecheck (bindings : binding list ) : unit = 
  (* Get constraints from all bindings *)
  let constraints = List.map typecheck_binding bindings in 

  (* Unify those constraints *)
  let _ = unify constraints in () (* unify outer mappings *)


(* notes
   

have constraint system

t0 -> t1 ~ int ->t2        (FunTy (Var 0, Var 1)       FunTy (Var Int, Var 2))

t2 ~ bool                   (Var 2, Bool)


Then follow unification algorithm (on Moodle page)





ex: forall t0. t0 -> t0

would be ForAll(0, FunTy (Var 0, Var 0))

keep track of constraints with refs or monads????? 


 *)





 (* build these in 
    
 
 int_of_string : int -> string takes an integer and returns a string representing that integer.
string_of_int : string -> int takes a string and returns an integer represented by that string. If the given string is not an integer, then this function throws an error.
print_string : string -> unit takes a string and prints it to stdout (followed by a newline) as a side effect. This is equivalent to the OCaml function print_endline.
 
 
 *)





  (* Var *)
  (* | IdLit x -> failwith tmsg *)

  (* Abs *)
  (* | FunExpr (x, t, e) -> CFun(CType t, generate_constraints(e, Map(x CType t) :: context)) *)

  (* App *)
  (* FunAppExpr(e1, e2) -> failwith "error" CFun(generate_constraints e1 Map(?), e2 Map(?)) *)
  

  (* Let *)

  (* Inst *)

  (* Gen *)