open OUnit2
open Ocaml_lite.Parser


let parse_tests = "test suite for parser" >::: [
    "left associativity for plus" >::
    (fun _ -> assert_equal
        [BinopType (BinopType (IntType 1, AdditionType(), IntType 2), AdditionType(), IntType 3)]
         parse (tokenize "1 + 2 + 3") );;
    "left associativity for times" >::
    (fun _ -> assert_equal
         [BinopType(BinopType (IntType 1, MultiplicationType(), IntType 2), MultiplicationType(), IntType 3)]
         parse (tokenize "1 * 2 * 3")  )
  ]

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