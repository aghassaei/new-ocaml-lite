
open Parser

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


(* A mapping  *)
type i_mapping = 
| IMap of string * value

(* constraints are indexed by strings *)



let rec evaluate_expr (e : expr) (context : i_mapping list ) : value = 
  match e with 
  | BExpr (e1, b, e2) ->
    (match b with 
          | AddOp -> evaluate_expr e1 + evaluate_expr e2
          | SubOp -> evaluate_expr e1 - evaluate_expr e2
          | MulOp -> evaluate_expr e1 * evaluate_expr e2
          | DivOp -> evaluate_expr e1 / evaluate_expr e2
          | ModOp -> evaluate_expr e1 mod evaluate_expr e2
          | GtOp -> evaluate_expr e1 > evaluate_expr e2
          | LtOp -> evaluate_expr e1 < evaluate_expr e2
          | EqOp -> evaluate_expr e1 = evaluate_expr e2
          | ConcatOp -> evaluate_expr e1 ^ evaluate_expr e2
          | AndOp -> evaluate_expr e1 && evaluate_expr e2
          | OrOp -> evaluate_expr e1 || evaluate_expr e2)


let evaluate_binding (b : binding) (context : i_mapping list ) : i_mapping list = 
  match b with 
  | NonRecursiveBind (s, x, t, e) -> IMap (s, evaluate_expr e)
  | RecursiveBind(s, x, t, e) -> failwith imsg
  | TypeBind(s, t_list) -> failwith imsg (*IMap(s, evaluate typebind_constructors)*)


  (* ask greg about recursive ones *)



let interpret(b_list : binding list) : mapping list = function 
| [] -> VUnit
| b :: rest -> evaluate_binding b []
| _ -> failwith "Expected a binding, got something else"


