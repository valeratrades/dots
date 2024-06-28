let b:current_syntax = 1

syn region String start=/"/ end=/"/ skip=/\\"/
syn region String start=/"""/ end=/"""/
syn region String start=/'/ end=/'/ skip=/\\'/
syn keyword Keyword def if while for in or and import from return continue
            \ break yield await async try except else elif class raise del
            \ contained containedin=MarkdownPythonCode
syn keyword Boolean True False
syn keyword Constant None
syn match Number /\d\+\.\?/
syn match Operator /[/+*%&|<>^=-]/
syn match Function /[a-zA-Z_]\+[a-zA-Z_0-9]*\s*\ze(/
syn keyword Type int float list dict set bool str
syn match Comment /#.*$/
