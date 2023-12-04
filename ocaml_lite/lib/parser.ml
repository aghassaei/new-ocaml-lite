open Ast

open Menhir_parser

include Nice_parser.Make(struct
  type result = binding list 
  type token = Menhir_parser.token
  exception ParseError = Menhir_parser.Error
  let parse = Menhir_parser.prog
include Lexer
end)

let () = pp_exceptions ()


(* because nice parser expects parse_string *)
let parse = parse_string