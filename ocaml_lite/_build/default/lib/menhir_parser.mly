
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
%type <binding> binding
%type <expr> expr
// like function that takes something, parses, returns something





//   types of all rules


// associativity



// precedence 


// Start rules
// begining with M because it's a menhir rule
%%



let prog := 
| EOF; {[]}     //EOF return empty array
| b = Mbinding; DoubleSemicolon; p = prog; {b :: p}


let binding :=
| Let; id = Id; params = Mparam*; t = option(Colon; Mtyp); Eq; e = Mexpr; {NonRecursiveBind()}
| Let; Rec; id = Id; params = parameter*; t = option(Colon; typ); Eq; e = Mexpr; {RecursiveBind()}
| Type; t = Id; Eq; types = type_rule2+



let expr :=
| EOF; {[]}



let parameter :=
| EOF; {[]}



let type_rule :=
| EOF; {[]}

let type_rule2 :=
//deal with pipes

  (*
  

<param> ::= $id
          | ( $id : <type> )

<expr> ::= let $id [<param>]* [: <type>] = <expr> in <expr>
         | let rec $id [<param>]* [: <type>] = <expr> in <expr>
         | if <expr> then <expr> else <expr>
         | fun [<param>]+ [: <type>] => <expr>
         | <expr> <expr>
         | ( <expr> [, <expr>]+ )
         | <expr> <binop> <expr>
         | <unop> <expr>
         | ( <expr> )
         | $int
         | true
         | false
         | $string
         | $id
         | ( )
         | match <expr> with ['|' <match_branch>]+

<binop> ::= + | - | * | / | mod | < | = | ^ | && | ||

<unop> ::= not | ~

<type> ::= <type> -> <type>
         | ( <type> )
         | <type> * <type>
         | int
         | bool
         | string
         | unit
         | $id

<match_branch> ::= $id [<pattern_vars>] => <expr>

<pattern_vars> ::= $id
                 | ( $id [, $id ]+ )


  *)