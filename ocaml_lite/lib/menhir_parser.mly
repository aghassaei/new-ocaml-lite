
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
%type <binding> Mbinding
%type <expr> Mexpr
%type <param> Mparam
// like function that takes something, parses, returns something





//   types of all rules


// associativity



// precedence 


// Start rules
// begining with M because it's a menhir rule
%%



let prog := 
| EOF; {[]}     // EOF return empty array
| b = Mbinding; DoubleSemicolon; p = prog; {b :: p}     // Return a list of bindings


let Mbinding :=
| Let; id = Id; params = Mparam*; t = option(Colon; Mtyp); Eq; e = Mexpr; {NonRecursiveBind(id, params, t, e)}
| Let; Rec; id = Id; params = parameter*; t = option(Colon; typ); Eq; e = Mexpr; {RecursiveBind(id, params, t, e)}
| Type; t = Id; Eq; type_constructors = option(Pipe; Mtypebind_constructor)+; {TypeBind(t, type_constructors)}

let Mtypebind_constructor :=
| id = Id; annotation = option(Of; MType) {TypeBindConstructor(id, annotation)}


let Mparam :=
| id = Id; {NonAnnotatedParam(id)}
| LParen; id = Id; Colon; t = Mtyp; RParen; {AnnotatedParam(id, t)}

let Mexpr :=
| Let; id = Id; params = MParam* t = option(Colon; Mtyp); Eq; e1 = Mexper; In; e2 Mexper; {}
| Let; Rec; id = Id; params = MParam*, t = option(Colon; MTyp); Eq; e1 = Mexper; In; e2 = Mexper; {}
| If; e1 = Mexper; Then e2 = Mexper; Else; e3 = Mexper; {}
| Fun; params = Mparam+; t = option(Colon; MTyp); DoubleArrow; e = Mexper; {}
| e1 = Mexper, e2 = Mexper; {}
| LParen; e1 = Mexpr>; e2 = option(Comma, e3 = Mexper)+; RParen; {}
| e1 = Mexper; b = Mbinop; e2 = Mexper; {}
| u = Munop; e = Mexper; {}
| Lparen; e = Mexper; RParen; {}
| int = Int; {}
| True; {}
| False; {}
| s = String; {}
| id = Id; {}
| u = Unit; {}
| Match; e = Mexper; With; m = option(MMatchbranch)+; {}




let type_rule :=
| EOF; {[]}

let Mbinop := 
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

let Mtype :=
| t1 = Mtype; Arrow; t2 = MType; {}
| LParen; t = MType; RParen; {}
| t1 = Mtype; Star; t2 = MType; {}
| TInt; {}
| TBool; {}
| TString; {}
| TUnit; ()
| s = Id; {}

let Mtype_constructor
// with pipes

let MMatchbranch := 
| id = Id; pv = option(Mpattern_vars); DoubleArrow; e = Mexper; {}

let Mpattern_vars := 
| id = id; {}
| LParen; id = Id; ids = option(Comma; nested_id = Id)+; RParen; {}


