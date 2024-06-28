if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "tablescript"

syn region String start=/`/ end=/`/
syn match Operator /|\s*\([<^]\|?[a-z]*\)\?/
syn match Operator /^\s*\(\^\|?[a-z0-9]*\)/
syn match Operator /^-\+$/
syn match Operator /^=\+$/
syn match Type /?[a-zA-Z0-9]*/ contained containedin=Operator
syn match Error /[^?lcrtmbBIU]/ contained containedin=Type
