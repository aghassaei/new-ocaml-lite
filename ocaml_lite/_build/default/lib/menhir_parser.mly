%{
    open Ast
%}

// TOKENS
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
%token <int> Int        // Integer literal
%token <string> String  // String literal
%token EOF              // End-of-file - you can ignore this

// RULES - all rules start with an r except the start rule (prog)
%start <binding list> prog      // Start rule: parse a program as a list of bindings
%type <binding> rBinding        // Parse a binding
%type <expr> rExpr              // Parse expression
%type <param> rParam            // Parse single parameter, either annotated or nonannotated 
%type <binop> rBinop            // Parse binary operators
%type <typebind_constructor> rTypbind_constructor      // Parse subtypes 
%type <typ> rTyp                // Parse type
%type <unop> rUnop              // Parse unary operator
%type <branch> rMatchbranch     // Parse match branch
%type <pattern_var> rPatternvar                       // Parse pattern variables


// ASSOCIATIVITY AND PRECEDENCE (lowest to highest)
%nonassoc In
%nonassoc Else
%right Arrow
%right DoubleArrow
%left Or
%left And
%nonassoc Lt, Eq
%left Plus, Minus, Concat
%left Times, Divide, Mod
%nonassoc Negate
%nonassoc Not 


%%


let prog := 
| EOF; {[]}     // No more bindings to parse
| b = rBinding ; DoubleSemicolon; p = prog; {b :: p}     // Return a list of bindings

let rBinding  :=
| Let; id = Id; params = rParam*; t = option(Colon; rTyp); Eq; e = rExpr; {NonRecursiveBind(id, params, t, e)}
| Let; Rec; id = Id; params = rParam*; t = option(Colon; rTyp); Eq; e = rExpr; {RecursiveBind(id, params, t, e)}
| Type; t = Id; Eq; constructors = separated_nonempty_list(Pipe, rTypbind_constructor); {TypeBind(t, constructors)}

let rTypbind_constructor :=
| id = Id; annotation = option(Of; rTyp); {TypeBindConstructor(id, annotation)} // Type annotations are optional

let rParam :=
| id = Id; {NonAnnotatedParam(id)}
| LParen; id = Id; Colon; t = rTyp; RParen; {AnnotatedParam(id, t)}

let rExpr:=
| Let; id = Id; params = rParam*; t = option(Colon; rTyp); Eq; e1 = rExpr; In; e2 = rExpr; {LetInExpr(id, params, t, e1, e2)}
| Let; Rec; id = Id; params = rParam*; t = option(Colon; rTyp); Eq; e1 = rExpr; In; e2 = rExpr; {LetRecInExpr(id, params, t, e1, e2)}
| If; e1 = rExpr; Then; e2 = rExpr; Else; e3 = rExpr; {ConditionExpr(e1, e2, e3)}
| Fun; params = rParam+; t = option(Colon; rTyp); DoubleArrow; e = rExpr; {FunExpr(params, t, e)}
| e1 = rExpr; e2 = rExpr; {FunAppExpr(e1, e2)}
// | LParen; e1 = rExpr; e2 = separated_nonempty_list(Comma, rExpr)+; RParen; {TupleExpr(e1 :: e2)}
// This expression has type expr list list but an expression was expected of type expr list. Type expr list is not compatible with type expr
| e1 = rExpr; b = rBinop; e2 = rExpr; {BExpr(e1, b, e2)}
| u = rUnop; e = rExpr; {UExpr(u, e)}
| LParen; e = rExpr; RParen; {(TupleExpr([e]))}
| i = Int; {IntLit(i)}
| True; {BoolLit(true)}
| False; {BoolLit(false)}
| s = String; {StringLit s}
| id = Id; {IdLit id}
| LParen; RParen; {UnitLit}
// | Match; e = rExpr; With; branches = separated_nonempty_list(Pipe, rMatchbranch); {MatchExpr(e, branches)}
| Match; e = rExpr; With; branches = separated_nonempty_list(Pipe, rMatchbranch); {MatchExpr(e, branches)}

// let rMatchbranch := 
// // | id = Id; pv = option(rPatternvars); DoubleArrow; e = rExpr; {Branch(id, pv, e)}
// | id = Id; DoubleArrow; e = expr; {NoVarBranch(id, e)}
// | id = Id; ids = separated_nonempty_list(Comma, rPatternvars); DoubleArrow; e = expr {VarBranch(id, ids, e)}

// let rPatternvars := 
// | id = Id; { IdOnly(id) }
// | LParen; id = Id; ids = separated_nonempty_list(Comma, Id); RParen; {IdAndList(id, ids)}



let rMatchbranch := 
| id = Id; pv = option(rPatternvar); DoubleArrow; e = rExpr; {Branch(id, pv, e)}

let rPatternvar := 
| id = Id; { IdOnly(id) }
| LParen; id = Id; ids = separated_nonempty_list(Comma, Id); RParen; {IdAndList(id, ids)}

let rBinop := 
| Plus; {AddOp}
| Minus; {SubOp}
| Divide; {MulOp}
| Mod; {ModOp}
| Lt; {LtOp}
| Eq; {EqOp}
| Concat; {ConcatOp}
| And; {AndOp}
| Or; {OrOp}

let rUnop := 
| Not; {NotOp}
| Negate; {NegOp}

let rTyp :=
| t1 = rTyp; Arrow; t2 = rTyp; {FunTy(t1, t2)}
| LParen; t = rTyp; RParen; {t}
// | t1 = rTyp; Times; t2 = rTyp; {TupTy(t1 :: t2)}
| TInt; {IntTy}
| TBool; {BoolTy}
| TString; {StringTy}
| TUnit; {UnitTy}
| s = Id; {IdTy}


// let rTyp_constructor





