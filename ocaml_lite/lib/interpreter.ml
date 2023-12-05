


(* take binding list  *)


type i_mapping = 
| IMap of string * value


(* possible values in language in normal form *)
type value = 
| VInt of int 
| VString of string
| VBool of bool 
| VUnit
| VFun of string * typ option * expr



let evaluate_expr (e : expr) (context : i_mapping list ) : value = 
  match e with 
  | BExpr (e1, b, e2) ->
    (match b with 
          | Minus -> evaluate e1 - evaluate e2)


let evaluate_binding (b : binding) (context : i_mapping list ) : i_mapping list = 
  match b with 
  | Bind(s, e) -> IMap (s, evaluate_expr e)


  (* ask greg about recursive ones *)


  