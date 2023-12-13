
open Parser
open Ast

let imsg = "Interpreter: not implemented yet"

(* take binding list  *)





(* possible values in language in normal form *)
type value = 
| VInt of int 
| VString of string
| VBool of bool 
| VUnit
| VFun of string * typ option * expr
| VBuiltin of string (* Ocaml-lite built in functions (check in function application if it's this type)*)


(* Environment *)
type environment = (string * value) list


let rec interpret_binding (b : binding) (env : environment) : environment = 
  match b with 
  | NonRecursiveBind (s, x, t, e) -> (s, interpret_expr e env) :: env
  | RecursiveBind(s, x, t, e) -> (s, interpret_expr e env) :: env
  | TypeBind(s, t_list) -> failwith imsg (*IMap(s, evaluate typebind_constructors)*)


and interpret_expr (e : expr) (env : environment) : value = 
  match e with 
  | BExpr (e1, b, e2) ->
    (match b with 
          | AddOp -> interpret_expr e1 + interpret_expr e2
          | SubOp -> interpret_expr e1 - interpret_expr e2
          | MulOp -> interpret_expr e1 * interpret_expr e2 
          | DivOp -> interpret_expr e1 / interpret_expr e2
          | ModOp -> interpret_expr e1 mod interpret_expr e2
          | GtOp -> interpret_expr e1 > interpret_expr e2
          | LtOp -> interpret_expr e1 < interpret_expr e2
          | EqOp -> interpret_expr e1 = interpret_expr e2
          | ConcatOp -> interpret_expr e1 ^ interpret_expr e2
          | AndOp -> interpret_expr e1 && interpret_expr e2
          | OrOp -> interpret_expr e1 || evaluate_expr e2)

  | UExpr (u, e) -> (
    match u with 
    | NotOp -> not (interpret_expr e)
    | NegOp -> -(interpret_expr e))

  | IntLit i -> i 
  | BoolLit bl -> bl
  | StringLit s -> s
  | IdLit x -> interpret_id x
  | UnitLit -> ()
  | LetRecInExpr (s, pl, t, e1, e2) -> failwith imsg (* map s to new environment with interpret_expr e1 and interpret_expr e2 *)
  | LetInExpr (s, pl, t, e1, e2) -> failwith imsg (* see above?*)
  | ConditionExpr(e1, e2, e3) -> failwith imsg (* interpret all three expressions *)
  | FunExpr(pl, t, e) -> failwith imsg (* interpret e *) 
  | FunAppExpr(e1, e2) -> 
        let l = interpret_expr e1 in 
        let r = interpret_expr in 
        (* if build in, then apply function to r *)
        interpret_expr e1 :: interpret_expr e2
  | TupleExpr(e_list) -> VTuple (List.map interpret_expr e_list)
  | MatchExpr(e, branches) -> interpret_expr e :: List.map interpret_branch branches

  and interpret_branch (br : branch) (env : environment) : environment = 
    match br with 
    | Branch (s, pv, e) -> interpret pattern vars, interpret expr

  and interpret_patternvar (p: pattern_var) (env : environment) : value =
    match p with 
    | IdOnly s -> interpret_expr s 
    | IdAndList (s, s_list) -> interpret s, List.map interpret s_list
  
  and interpret_typebind_constructor (t : typebind_constructor) (env : environment) : environment = 
    match t with 
    | TypeBindConstructor (s, ty) -> interpret s, interpret_typ ty
    
  and interpret_param (p: param) (env : environment) : environment = 
    match p with 
    | NonAnnotatedParam s -> interpret s
    | AnnotatedParam (s,t) -> interpret s, interpret t
  
  and interpret_typ (t : typ) (env : environment) : environment = 
    match t with 
    | BoolTy
    | StringTy
    | IntTy
    | UnitTy
    | IdTy 
    | FunTy (t1, t2) -> interpret_typ t1, interpret_typ t2

    







  (* ask greg about recursive ones *)



let interpret(b_list : binding list) : mapping list = function 
| [] -> VUnit
| b :: rest -> interpret_binding b []
| _ -> failwith "Expected a binding, got something else"


