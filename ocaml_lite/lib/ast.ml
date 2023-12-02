(* AST *)

type binding = 
  | NonRecursiveType of string * param list * typ option * expr
  | RecursiveType of string * param list * typ option * expr
  | TypeDefType of string * (string * typ option) list

and expr = 
  | LocalBindingType of binding * expr 
  | ConditionalType of expr * expr * expr 
  | FunctionExprType of param list * typ option * expr 
  | ApplicationType of expr * expr 
  | NestedExprType of expr * expr
  | MatchType of expr * (string * string list * expr) list
  | BinopType of expr * binop * expr 
  | UnopType of unop * expr
  | ExperType of typ

and param = string * typ option 

and typ = 
  | BoolType
  | StringType
  | IntType
  | UnitType
  | IdType of string
  | FunctionType of typ * typ
  | TupleType of typ list

and unop = 
  | NotType
  | NegativeType

and binop = 
  | AdditionType 
  | SubtractionType
  | MultiplicationType
  | DivisionType
  | ModuloType
  | GreaterType
  | LesserType
  | EqualsType
  | ConcatType
  | AndType
  | OrType

  (* type pattern_vars = 
  | Single of string 
  | Multiple of string list *)

(* type match_branch = string * string list * expr  *)