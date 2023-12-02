(* Tests for the interpreter *)
(* More will come later *)


(* 
INPUT             OUTPUT
boolean tests:
3 = 4             false
not(3 = 4)        true 
true OR false     true
false or false    false
true and false    false
true and true     true

Binop tests:
1+2                3
3 * 10             30
5-3                 2
5-6                -1
1/1               1
3 mod 6           3
1/0               divide by zero error 
1 > 0             true
0 > 1             false 
0 < 1             true
1 < 0             false
1 = 1             true
"h"^"i"           "hi"
 *)