(* AST *)

type binding = 
  | NonRecursiveBind of string * param list * typ option * expr
  | RecursiveBind of string * param list * typ option * expr
  | TypeDefBind of string * (string * typ option) list

and expr = 
  | LetRecInExpr of string * param list * typ option * expr * expr
  | LetInExpr of string * param list * typ option * expr * expr
  | ConditionExpr of expr * expr * expr 
  | FunExpr of param list * typ option * expr 
  | FunAppExpr of expr * expr 
  | TupleExpr of expr list
  | MatchExpr of expr * (string * string list * expr) list
  | BExpr of expr * binop * expr 
  | UExpr of unop * expr
  | IntLit of int
  | BoolLit of bool 
  | StringLit of string 
  | IdLit of string 
  | UnitLit

and param = string * typ option 

and typ = 
  | BoolTy
  | StringTy
  | IntTy
  | UnitTy
  | IdTy 
  | FunTy of typ * typ
  | TupTy of typ list

and unop = 
  | NotOp
  | NegOp

and binop = 
  | AddOp 
  | SubOp
  | MulOp
  | DivOp
  | ModOp
  | GtOp
  | LtOp
  | EqOp
  | ConcatOp
  | AndOp
  | OrOp