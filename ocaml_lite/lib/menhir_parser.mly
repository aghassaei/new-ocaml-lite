
%{

    open Ast
    
%}



// Tokens

%token Type             // type - keyword
%token Of               // of - keyword
%token Let              // let - keyword
%token Rec              // rec - keyword
%token In               // in - keyword
%token If               // if - keyword
%token Then             // then - keyword
%token Else             // else - keyword
%token Match            // match - keyword
%token With             // with - keyword
%token Fun              // fun - keyword
%token True             // true - keyword
%token False            // false - keyword
%token Mod              // mod - keyword
%token TInt             // int - type name
%token TBool            // bool - type name
%token TString          // string - type name
%token TUnit            // unit - type name
%token Eq               // = - binary operator
%token Plus             // + - binary operator
%token Minus            // - - binary operator
%token Times            // * - binary operator
%token Divide           // / - binary operator
%token Lt               // < - binary operator
%token Concat           // ^ - binary operator
%token And              // && - binary operator
%token Or               // || - binary operator
%token Not              // ! - unary operator
%token Negate           // ~ - unary operator
%token DoubleSemicolon  // ;;
%token Colon            // :
%token Arrow            // ->
%token DoubleArrow      // =>
%token LParen           // (
%token RParen           // )
%token Pipe             // |
%token Comma            // ,
%token <string> Id      // Identifier, like a variable or function name
%token <int> Int              // Integer literal
%token <string> String           // String literal
%token EOF              // End-of-file - you can ignore this


// Rules 
%start <binding list> prog  // Start rule: a program as a list of bindings
%type <binding> mbinding
%type <expr> mexpr
%type <param> mparam
// like function that takes something, parses, returns something





//   types of all rules


// associativity



// precedence 


// Start rules
// begining with M because it's a menhir rule
%%



//   | LetRecInExpr of string * param list * typ option * expr * expr
//   | LetInExpr of string * param list * typ option * expr * expr
//   | ConditionExpr of expr * expr * expr 
//   | FunExpr of param list * typ option * expr 
//   | FunAppExpr of expr * expr 
//   | TupleExpr of expr list
//   | MatchExpr of expr * (string * string list * expr) list
//   | BExpr of expr * binop * expr 
//   | UExpr of unop * expr
//   | IntLit of int
//   | BoolLit of bool 
//   | StringLit of string 
//   | IdLit of string 
//   | UnitLit



let prog := 
| EOF; {[]}     // EOF return empty array
| b = mbinding; DoubleSemicolon; p = prog; {b :: p}     // Return a list of bindings


let mbinding :=
| Let; id = Id; params = mparam*; t = option(Colon; mtyp); Eq; e = mexpr; {NonRecursiveBind(id, params, t, e)}
| Let; Rec; id = Id; params = parameter*; t = option(Colon; typ); Eq; e = Mexpr; {RecursiveBind(id, params, t, e)}
| Type; t = Id; Eq; type_constructors = option(Pipe; mtypebind_constructor)+; {TypeBind(t, type_constructors)}

let mtypebind_constructor :=
| id = Id; annotation = option(Of; mtype); {TypeBindConstructor(id, annotation)}


let mparam :=
| id = Id; {NonAnnotatedParam(id)}
| LParen; id = Id; Colon; t = mtyp; RParen; {AnnotatedParam(id, t)}

let mexpr :=
| Let; id = Id; params = mparam*; t = option(Colon; mtyp); Eq; e1 = mexper; In; e2 = mexper; {LetInExpr(id, params, t, e1, e2)}
| Let; Rec; id = Id; params = mparam*; t = option(Colon; mtyp); Eq; e1 = mexper; In; e2 = mexper; {LetRecInExpr(id, params, t, e1, e2)}
| If; e1 = mexper; Then; e2 = mexper; Else; e3 = mexper; {ConditionExpr(e1, e2, e3)}
| Fun; params = mparam+; t = option(Colon; mtyp); DoubleArrow; e = mexper; {FunExpr(params, t, e)}
| e1 = mexper; e2 = mexper; {FunAppExpr(e1, e2)}
| LParen; e1 = mexpr; e2 = option(Comma; e3 = mexper)+; RParen; {TupleExpr(e1 :: e2)}
| e1 = mexper; b = Mbinop; e2 = mexper; {BExpr(e1, b, e2)}
| u = munop; e = mexper; {UExpr(u, e)}
| Lparen; e = mexper; RParen; {(TupleExpr(e))}
| i = Int; {IntLit(i)}
| True; {BoolLit(true)}
| False; {BoolLit(false)}
| s = String; {StringLit s}
| id = Id; {IdLit id}
| u = Unit; {UnitLit}
| Match; e = mexper; With; m = option(MMatchbranch)+; {MatchExpr(e,m)}




let type_rule :=
| EOF; {[]}

let mbinop := 
| Plus; {}
| Minus; {}
| Div; {}
| Mod; {}
| Lt; {}
| Eq; {}
| Concat; {}
| And; {}
| Or; {}

let Munop := 
| Not; {}
| Tilde; {}

let mtype :=
| t1 = mtype; Arrow; t2 = mtype; {}
| LParen; t = mtype; RParen; {}
| t1 = mtype; Star; t2 = mtype; {}
| TInt; {}
| TBool; {}
| TString; {}
| TUnit; ()
| s = Id; {}

let mtype_constructor
// with pipes

let MMatchbranch := 
| id = Id; pv = option(Mpattern_vars); DoubleArrow; e = mexper; {}

let Mpattern_vars := 
| id = id; {}
| LParen; id = Id; ids = option(Comma; nested_id = Id)+; RParen; {}


