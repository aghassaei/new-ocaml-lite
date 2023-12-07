Open Menhir_parser
(* Open Ast *)

let tmsg = "Typechecker: not implemented yet"
(* Internally define types for the constraints *)
type c_type = 
| CInt                        (* Base types*)
| CBool   
| CString
| CUnit                       
| CUser of string             (* Types from source code*)
| CFun of c_type * c_type
| CTuple of c_type list
| CVar of string                (* Variables for types, just indexed by integers *)
| CForall of string * c_type     (* Quantifiers *)

(* 
(* A constraint is a pair of types *)
type constr = 
| Constr of c_type * c_type *)


(* mapping type *)
type mapping = 
| Map of string * c_type


(* Takes AST and throws error if typechecking fails, returns unit otherwise *)


let typecheck (bindings : binding list ) : unit = 
  let mappings = List.map get_expr_constraints bindings in 
  let _ = unify map in () (* unify outer mappings *)



(* find expression in b, generate constraints for expressions, return pair of what it's bound to and constraints *)
(* unify after every let binding *)
let get_expr_constraints (b : binding) : mapping = function 
  | NonRecursiveBind(s, pl, t, e) -> 
        let c = unify (generate_constraints (e, [])) in Map(s, c)
  | RecursiveBind(s, pl, t, e) -> 
        let c = unify (generate_constraints (e, [])) in Map(s, c)
  | TypeBind(s, t_list) ->
        let c = unify (generate_constraints (e, [])) in Map(s, c)



(* constraints specific to binding, environment needs to carry over  *)

(* here when we unify, we unify local mappings *)
let rec generate_constraints (e : expr ) (context : mapping list ): c_type =
  match e with 
  (* Var *)
  | IdLit x -> failwith tmsg

  (* Abs *)
  | FunExpr (x, t, e) -> CFun(CType t, generate_constraints(e, Map(x CType t) :: context))

  (* App *)
  FunAppExpr(e1, e2) -> failwith tmsg (*CFun(generate_constraints e1 Map(?), e2 Map(?))*)
  

  (* Let *)

  (* Inst *)

  (* Gen *)

(* if let appears *)
  | something (e) -> unify ()


    (* see phone *)
    

(* indexing by strings *)



(* Takes a system of constraints and returns a unified list of constraints *)
let unify (map : mapping list) : mapping list = function 
| [] -> []
| h :: t -> failwith "Not implemented"


(* let solve_single ( c : constr ) : constr list = function 
(* If t1 is a variable *)
match c with 
| (CVar t1, t2) -> 
    (match t2 with 
    | CVar -> (t1, t2)) (* should be if t1=t2 then do nothing, else arbitrarily map one to the other *)

(* If both are function types *)
| (CFun f1, CFun f2) ->  *)



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