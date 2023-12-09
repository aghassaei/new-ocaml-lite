(* AST *)

type binding = 
  | NonRecursiveBind of string * param list * typ option * expr
  | RecursiveBind of string * param list * typ option * expr
  | TypeBind of string * typebind_constructor list

and typebind_constructor = 
  | TypeBindConstructor of string * typ option

and expr = 
  | LetRecInExpr of string * param list * typ option * expr * expr
  | LetInExpr of string * param list * typ option * expr * expr
  | ConditionExpr of expr * expr * expr 
  | FunExpr of param list * typ option * expr 
  | FunAppExpr of expr * expr 
  | TupleExpr of expr list
  | MatchExpr of expr * branch list
  | BExpr of expr * binop * expr 
  | UExpr of unop * expr
  | IntLit of int
  | BoolLit of bool 
  | StringLit of string 
  | IdLit of string 
  | UnitLit

and branch = 
  | Branch of string * pattern_var option * expr

and pattern_var = 
  | IdOnly of string
  | IdAndList of string * string list

and param = 
  | NonAnnotatedParam of string
  | AnnotatedParam of string * typ 

and typ = 
  | BoolTy
  | StringTy
  | IntTy
  | UnitTy
  | IdTy 
  | FunTy of typ * typ
  (* | TupTy of typ list *)

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
