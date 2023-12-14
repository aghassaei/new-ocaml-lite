(* AST *)

(* A program is a list of bindings *)
type binding = 
  | NonRecursiveBind of string * param list * typ option * expr       (* let $id [<param>]* [: <type>] = <expr> *)
  | RecursiveBind of string * param list * typ option * expr          (* let rec $id [<param>]* [: <type>] = <expr> *)
  | TypeBind of string * typebind_constructor list                    (* type $id = ['|' $id [of <type>]]+ *)

and typebind_constructor = 
  | TypeBindConstructor of string * typ option                        (* '|' $id [of <type>] *)

and expr = 
  | LetRecInExpr of string * param list * typ option * expr * expr    (* let $id [<param>]* [: <type>] = <expr> in <expr> *)
  | LetInExpr of string * param list * typ option * expr * expr       (* let rec $id [<param>]* [: <type>] = <expr> in <expr> *)
  | ConditionExpr of expr * expr * expr                               (* if <expr> then <expr> else <expr> *)
  | FunExpr of param list * typ option * expr                         (* fun [<param>]+ [: <type>] => <expr> *)
  | FunAppExpr of expr * expr                                         (* <expr> <expr> *)
  | TupleExpr of expr list                                            (* ( <expr> [, <expr>]+ ) *)
  | MatchExpr of expr * branch list                                   (* match <expr> with ['|' <match_branch>]+ *)
  | BExpr of expr * binop * expr                                      (* <expr> <binop> <expr> *)
  | UExpr of unop * expr                                              (* <unop> <expr> *)
  | IntLit of int                                                     (* $int *)
  | BoolLit of bool                                                   (* true | false *)
  | StringLit of string                                               (* $string *)
  | IdLit of string                                                   (* $id *)
  | UnitLit                                                           (* () *)

  and branch = 
    | Branch of string * pattern_var option * expr                    (* $id [<pattern_vars>] => <expr> *)
  
  and pattern_var = 
    | IdOnly of string                                                (* $id  *)
    | IdAndList of string * (string list)                             (* ( $id [, $id ]+ ) *)

and param = 
  | NonAnnotatedParam of string                                       (* $id *)
  | AnnotatedParam of string * typ                                    (* ($id : <type> ) *)

and typ = 
  | BoolTy                                                            (* bool *)                                  
  | StringTy                                                          (* string *)
  | IntTy                                                             (* int *)
  | UnitTy                                                            (* unit *)
  | IdTy                                                              (* $id *)
  | FunTy of typ * typ                                                (* <type> -> <type> *)
  (* | TupTy of typ list *)                                           (* <type> * <type> NOTE: not quite right, had to comment out to resolve errors, and this doesn't quiet match up with the grammar I said it did *)

and unop = 
  | NotOp                                                             (* not *)
  | NegOp                                                             (* ~ *)

and binop = 
  | AddOp                                                             (* + *)
  | SubOp                                                             (* - *)
  | MulOp                                                             (* * *)
  | DivOp                                                             (* / *)
  | ModOp                                                             (* mod *)  
  | LtOp                                                              (* < *)
  | EqOp                                                              (* = *)
  | ConcatOp                                                          (* ^ *)
  | AndOp                                                             (* && *)
  | OrOp                                                              (* || *)
