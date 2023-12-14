open Parser
open Ast
open Typechecker

(* This still doesn't compile unfortunately, so I'm not expecting much credit for this. 
   I've tried to comment the project well so at least there's some clarity to the incomplete code.
   Hope you have a good break, and thank you again for the extension. *)

(* Placeholder for unfinished branches *)
let imsg = "Interpreter: not implemented yet"

(* type for possible values in OCaml-lite in normal form *)
type value = 
| VInt of int 
| VString of string
| VBool of bool 
| VUnit
| VFun of string * typ option * expr
| VBuiltin of string (* Ocaml-lite built in functions (check in function application if it's this type)*)
| VTuple of value list

(* Environment *)
type environment = (string * value) list

(* Helper function to (in theory) visualize values and make better error messages *)
let value_to_str (v : value) : string = 
  match v with 
  | VInt i -> "VInt " ^ string_of_int i 
  | VString s -> "VString " ^ s 
  | VBool b -> "VBool " ^ string_of_bool b
  | VUnit -> "VUnit"
  | VFun (s, t, e) -> "VFun "^s^"type here"^"expression here" 
  | VBuiltin s -> "VBuiltin "^s
  | VTuple l -> "VTuple [" ^ join (List.map value_to_str l)

(* Isolate an integer from a VInt value *)
let extract_int (v : value) : int = 
  match v with
  | VInt i -> i
  | _ -> failwith ("Expected VInt, got " ^ value_to_str v)

(* Isolate a string from a VString value *)
let extract_string (v : value) : string = 
  match v with 
  | VString s -> s 
  | _ -> failwith ("Expected VString, got " ^ value_to_str v)

(* Isolate a bool from a VBool value *)
let extract_bool (v : value) : bool = 
  match v with 
  | VBool b -> b 
  | _ -> failwith ("Expected VBool, got " ^ value_to_str v)

(* Evaluate a single binding *)
let rec interpret_binding (b : binding) (env : environment) : environment = 
  match b with 
  | NonRecursiveBind (s, x, t, e) -> (s, interpret_expr e env) :: env (* Idea is that you pair the name of the binding (s) with the interpreted expression (which should be of type value) and prepend it to the environment *)
  | RecursiveBind(s, x, t, e) -> (s, interpret_expr e env) :: env
  | TypeBind(s, t_list) -> failwith imsg (* Need to evalute typebind constructors here *)

(* Evalute a single expression. The idea to pull out the expression before matching on the operator was from Sam. *)
and interpret_expr (e : expr) (env : environment) : value = 
  match e with 
  | BExpr (e1, b, e2) -> 
      let l = interpret_expr e1 env in 
      let r = interpret_expr e2 env in 
    (match b with 
        | AddOp -> let v1 = extract_int l in let v2 = extract_int r in VInt (v1 + v2)
        | SubOp -> let v1 = extract_int l in let v2 = extract_int r in VInt (v1 - v2)
        | MulOp -> let v1 = extract_int l in let v2 = extract_int r in VInt (v1 * v2)
        | DivOp -> let v1 = extract_int l in let v2 = extract_int r in VInt (v1 / v2)
        | LtOp -> let v1 = extract_int l in let v2 = extract_int r in VBool (v1 < v2)
        | ModOp -> let v1 = extract_int l in let v2 = extract_int r in VInt (v1 mod v2)
        | ConcatOp -> let v1 = extract_string l in let v2 = extract_string r in VString (v1 ^ v2)
        | AndOp -> let v1 = extract_bool l in let v2 = extract_bool r in VBool (v1 && v2)
        | OrOp -> let v1 = extract_bool l in let v2 = extract_bool r in VBool (v1 || v2)
        | EqOp -> 
            (match (l,r) with 
            | (VInt i1, VInt i2) -> VBool (i1 = i2) 
            | (VString s1, VString s2) -> VBool (s1 = s2)
            | (VBool b1, VBool b2) -> VBool (b1 = b2)
            | _ -> failwith "Can't have these two things equal"))
  | UExpr (u, e) -> 
    let e = interpret_expr e env in (
    match u with 
    | NotOp -> VBool(not (extract_bool e))
    | NegOp -> VInt (- (extract_int e)))

  | IntLit i -> VInt i 
  | BoolLit bl -> VBool bl
  | StringLit s -> VString s
  | IdLit x -> failwith "Unsure what to do here"
  | UnitLit -> VUnit
  | LetRecInExpr (s, pl, t, e1, e2) -> failwith imsg (* interpret e1 and e2 *)
  | LetInExpr (s, pl, t, e1, e2) -> failwith imsg (* see above? *)
  | ConditionExpr(e1, e2, e3) -> failwith imsg (* interpret all three expressions *)
  | FunExpr(pl, t, e) -> failwith imsg (* interpret e *) 
  | FunAppExpr(e1, e2) -> 
        let l = interpret_expr e1 in 
        let r = interpret_expr in 
        (* if build in, then apply function to r *)
        (* interpret_expr e1 :: interpret_expr e2 *)
        failwith "functions"
  | TupleExpr(e_list) -> VTuple (List.map fold_left_map env  interpret_expr (env) e_list)
  | MatchExpr(e, branches) -> interpret_expr e :: List.map interpret_branch branches

  and interpret_branch (br : branch) (env : environment) : environment = 
    match br with 
    | Branch (s, pv, e) -> failwith "not sure" (* interpret pattern vars, interpret expr *)

  and interpret_patternvar (p: pattern_var) (env : environment) : value =
    match p with 
    | IdOnly s -> interpret_expr s 
    | IdAndList (s, s_list) -> interpret s, List.map interpret s_list
  
  and interpret_typebind_constructor (t : typebind_constructor) (env : environment) : environment = 
    match t with 
    | TypeBindConstructor (s, ty) -> failwith "not sure" (* interpret s, interpret_typ ty *)
    
  and interpret_param (p: param) (env : environment) : environment = 
    match p with 
    | NonAnnotatedParam s -> interpret s
    | AnnotatedParam (s,t) -> failwith "not sure " (* interpret s, interpret t *)
  
  and interpret_typ (t : typ) (env : environment) : environment = 
    match t with 
    | BoolTy
    | StringTy
    | IntTy
    | UnitTy
    | IdTy 
    | FunTy (t1, t2) -> failwith imsg (* interpret_typ t1, interpret_typ t2 *)



(* Base interpret function *)
let interpret(b_list : binding list) : mapping list = function 
| [] -> VUnit
| b :: rest -> interpret_binding b []
| _ -> failwith "Expected a binding, got something else"

