# OCaml-lite 


# Greg: please ignore this document for now


## Directories
- lib/ and test/ directories and various dune files as we've seen before.
- The only thing in lib/ is lib/lexer.mll which defines a lexer for OCaml-lite. This lexer should work for both handwritten and generated parsers, although you'll need to edit it a bit for generated parsers. There's a comment in the file with more information.
- test/ contains a tiny test suite. It's mostly there to provide some examples to help you add your own test cases.
- In contrast to prior homeworks, we now also have a bin/ directory with a file bin/main.ml. This defines an executable for your project so that you can run your interpreter when it's finished. See Programming with OCaml-lite below.
- There is also an example OCaml-lite program called lc_parser.ol. This is an implementation of our lambda calculus parser in OCaml-lite, which I've provided so you can see some of the differences between OCaml and OCaml-lite in a concrete program.

## Grammar

**Notation:**
- [ A ] for some sequence of symbols A means that A is optional. For example, <a> ::= [ A ] is equivalent to <a> ::= e | A.
- [ A ]* means that A may appear any number of times (including zero). For example <a> ::= [ A ]* is equivalent to <a> ::= e | <a> A or <a> ::= e | A <a> depending on associativity.
- [ A ]+ means that A may appear any number of times but must appear at least once. For example <a> ::= [ A ]+ is equivalent to <a> ::= A | <a> A or <a> ::= A | A <a>.


```
<program> ::= [<binding> ;;]+

<binding> ::= let $id [<param>]* [: <type>] = <expr>
            | let rec $id [<param>]* [: <type>] = <expr>
            | type $id = ['|' $id [of <type>]]+

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
```



Note that the last binary operation is || which looks a bit confusing in the grammar.

The binary operators are all left-associative (except for < and =, which are non-associative) and all operators have their normal precedences:

(Highest precedence)
not
~
*, /, mod
+, -, ^
<, =
&&
||
(Lowest precedence)





Note that a few of these precedences are loose. For example, the string concatenation operator ^ can really be parsed at any precedence above = because the program will be ill-typed if an expression includes both ^ and any numerical operators. If you find it easier to modify the precedences above you're free to do so, as long as you preserve the parse trees of well-typed expressions.

The grammar of OCaml-lite is very similar to OCaml. The main differences are:

Each top-level binding must be separated by ;;. This is optional in OCaml, but it makes parsing easier, so we'll make it mandatory in Ocaml-lite.
User-defined types and match expressions must have a | before the first constructor/branch. Again this is optional in OCaml, but it's easier on us (as language implementors) to require it.
The anonymous function construct fun uses a different arrow: => instead of ->. This makes parsing easier in the case that the anonymous function has an explicit return type.
Match expressions use the => arrow for consistency with functions.
We use ~ rather than - for negating integers. That means we don't need to deal with the problem of - being both a binary and a unary operator.
Neither nested patterns nor literals are allowed in match expressions.
Moreover, only constructors with data values are allows as patterns in a match expression. For example, we cannot write match x with | (a, b) -> ... in OCaml-lite.
Patterns are not allowed on the left hand side of a let binding, so match is the only construct which allows destructuring. For example, suppose you have a value p of type pair where pair has one constructor Pair of int * int. In OCaml-lite you cannot write let Pair (x, y) = p in ..., instead you must write match p with | Pair (x, y) -> ....
We cannot explicitly represent type variables. That is, in OCaml-lite we cannot write let id (x : 'a) : 'a = x because the rules for parsing types to not allow 'a. We can write polymorphic functions by simply omitting the type annotations (as in id x = x). Our type inference algorithm will be able to construct polymorphic types, so it will correctly assign id a type of 'a -> 'a.
While we can represent tuple types and tuple expressions, we cannot match on tuples, so we have no way to destructure them. In practice, tuples are only useful for defining data type constructors which need multiple data fields.
Your parser should follow OCaml's rules for disambiguation. In particular, this means match expressions should extend as far to the right as possible, so for example

match boolean_value with
| true -> match list_value with
  | Nil -> e1
  | Cons (hd, tl) -> e2
| false -> e3
should be parsed such that the false branch is associated with the inner match expression (resulting in a type error). In order to make this expression work, you can surround the inner match expression with parentheses.

Type Inference
Now, we'll develop a typechecker for OCaml-lite. OCaml-lite uses a Hindley-Milner type system, so we'll need to implement a unification based type inference algorithm.

We'll talk about this in class as it gets closer.

OCaml-lite has three built-in functions: int_of_string, string_of_int, and print_string. These are parsed just like regular functions, but they should be built into your type inference and interpretation algorithms, so they are available to all OCaml-lite programs even if they haven't been defined. The built-in functions have the following behavior.

int_of_string : string -> int takes an integer and returns a string representing that integer.
string_of_int : int -> string takes a string and returns an integer represented by that string. If the given string is not an integer, then this function throws an error.
print_string : string -> unit takes a string and prints it to stdout (followed by a newline) as a side effect. This is equivalent to the OCaml function print_endline.
Interpretation
In this section you will develop an interpreter for OCaml-lite programs. To interpret an OCaml-lite program, you'll need to process each binding in order while building up an evaluation context. Recall that a binding can be either a value binding (let or let rec) or a type binding (type). To process a type binding, add each constructor from that type declaration to the evaluation context. In order to process a value binding, evaluate the expression on the right hand side of the binding and associate the resulting value with the name on the left hand side of the binding in the evaluation context. In this case you'll need to consider what context to use when evaluating the right hand side based on the presence of absence of the rec keyword.

Expression evaluation is similar to what we've seen in previous assignments. We've evaluated simple expressions before in our expression assignment, and we've evaluated abstraction and function application in our lambda calculus reduction engine. The new component here is match expressions. In order to evaluate the expression match e with | p1 -> e1 | p2 -> e2 | ..., we need to first evaluate e to get a value v. Then we need to check p1, p2, ... one at a time to see if they match v. If they do, we add any appropriate values to the context and evaluate the associated expression.

Programming OCaml-lite
Now that you've written a full programming language, let's test it out by writing a program. This can be anything you want--I redid my lambda calculus parser, but you can choose to implement something else. You don't have to stick to programming languages topics for this. I would recommend keeping the program pretty small because our OCaml-lite implementation does not provide very helpful error messages and it's likely that your interpreter is fairly slow (mine certainly is). Both of these tend to make developing software difficult, so keep your project manageable.

In the starter code, I've given you an executable which takes the name of an OCaml-lite file, reads the file, parses and typechecks it, then interprets the result. This executable can be run with

dune exec ocaml_lite -- <filename>
where <filename> is the name of the OCaml-lite program you want to interpret.

The given code has three undefined functions: parse, typecheck, and interpret. These should all be updated to point to the parsing, typechecking, and interpretation functions you've defined in previous parts of the homework. For example, the top of my bin/main.ml file in the solution looks like this:

let parse = Ocaml_lite.Parser.parse
let typecheck = Ocaml_lite.Typecheck.typecheck
let interpret = Ocaml_lite.Interpret.interpret
This is because my parse function is in lib/parser.ml, so I can access it by referencing Ocaml_lite.Parser. Typechecking and interpretation are handled similarly.

Appendix: Annotated Grammar
<program> ::= [<binding> ;;]+
A program in OCaml-lite is a list of bindings separated by ;;. This is exactly like OCaml except that the ;; is optional in OCaml and required in OCaml-lite.

<binding> ::= let $id [<param>]* [: <type>] = <expr>
            | let rec $id [<param>]* [: <type>] = <expr>
            | type $id = ['|' $id [of <type>]]+
A binding can either be a value binding or a type binding. In either case, these look almost exactly like OCaml, but type definitions require a | before the first constructor. That is, in OCaml we would be allowed to write something like type t = A | B but in OCaml-lite we must write type t = | A | B.

<param> ::= $id
          | ( $id : <type> )
Parameters are exactly like OCaml--they are either a name by itself, or a name associated with a type.

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
Expressions in OCaml-lite are a subset of OCaml expressions with a few small tweaks. We have a normal set of binary operators, normal local bindings (let) and conditionals (if), plus tuples, application, etc. There are a few differences from OCaml though:

We use ~ rather than - for unary minus to make parsing easier.
We use => in anonymous function definitions.
<type> ::= <type> -> <type>
         | ( <type> )
         | <type> * <type>
         | int
         | bool
         | string
         | unit
         | $id
Types are exactly like OCaml except that we can't parse type variables (like 'a).

<match_branch> ::= $id [<pattern_vars>] => <expr>

<pattern_vars> ::= $id
                 | ( $id [, $id ]+)
Pattern matching is a bit more restricted than in OCaml. In particular, we do not allow nested patterns and each pattern consists of exactly a single constructor followed by names for that constructor's data. Note that match also uses => instead of -> for consistency with fun.





## Tests
for parser

(* Test cases *)
(* More to come, not all of these have the correct input/output format, not all have annotations but will in final documentation *)

(* 
INPUT                                     OUTPUT                            FUNCTION 
parse (tokenize "1 + 2 + 3")              add (add (1,2), 3)                checking left associativity for plus
parse (tokenize 1 * 2 * 3)                (1*2) *3                          check left associativity for times
1 + 2 * 3                                 add(1, mul(2, 3))
+ 1 + 2                                   leading operator error
1 +                                       hanging operator error
1 = 3                                     equals (int 1, int 3)
not 1 = 3                                 Not(Int 1, Int 3)
~3 + 4                                    minus(Int 3, Int 4)
1 + + 2                                   error
x && y || z                               And(x, Or(y, z))
*)


(* More ideas *)
(* 
   1.  Make sure match statements are disambiguated correctly
   2. not before ~
   3. ~ before *, /, mod
   4. *, /, mod before +, -, ^
   5. +, -, ^ before comparisons
   6. Comparison before AND
   7. AND before OR
   8. hanging operator
   9. leading operator
   10. 
   
*)

(* Precedence (for reference)*)

(* 
   not
~
*, /, mod
+, -, ^
<, =
&&
||


*)
 





