setlocal conceallevel=2

syn case match

syn match MarkdownLink /^\s*\[[^\[\]]*\]([a-zA-Z0-9._\/ -]\+)$/
syn match MarkdownLinkText /\[[^\[\]]*\]([a-zA-Z0-9._\/ -]\+)$/ contained containedin=MarkdownLink
syn match MarkdownLinkJunk /\[\|\](.*)/ contained containedin=MarkdownLinkText conceal
hi MarkdownLinkText ctermfg=darkblue cterm=underline

syn match MarkdownImage /^\s*!\[[^\[\]]*\]([a-zA-Z0-9._\/ -]\+)$/
syn match MarkdownImageText /!\[[^\[\]]*\]([a-zA-Z0-9._\/ -]\+)$/ contained containedin=MarkdownImage
syn match MarkdownImageJunk /!\[\|\](.*)/ contained containedin=MarkdownImageText conceal
hi MarkdownImageText ctermfg=darkmagenta

syn region MarkdownCodeSnippet start=/`/ end=/`/ skip=/\\`/ excludenl keepend
syn match MarkdownCodeSnippetBackticks /`/
            \ contained containedin=MarkdownCodeSnippet
hi link MarkdownCodeSnippet CursorLine
hi MarkdownCodeSnippetBackticks ctermbg=233 ctermfg=233

hi MarkdownHeading1 cterm=bold,underline ctermfg=darkgreen
hi MarkdownHeading2 cterm=bold ctermfg=darkgreen
hi MarkdownHeading3 ctermfg=darkgreen

syn match MarkdownHeading1 /^### .*/
syn match MarkdownHeading2 /^#### .*/
syn match MarkdownHeading3 /^##### .*/
syn match MarkdownHeadingJunk /^#\+ / contained conceal
            \ containedin=MarkdownHeading1,MarkdownHeading2,MarkdownHeading3
syn match Error /^##\? .*/

syn region MarkdownCode start=/^```.*$/ end=/^```$/ keepend
            \ contains=MarkdownCodeJunk

syn match MarkdownCodeJunk /^```.*$/ contained conceal

syn region MarkdownPythonCode start=/^```python$/ end=/^```$/
            \ contained containedin=MarkdownCode contains=MarkdownCodeJunk
syn region String start=/"/ end=/"/ skip=/\\"/
            \ contained containedin=MarkdownPythonCode
syn region String start=/"""/ end=/"""/
            \ contained containedin=MarkdownPythonCode
syn region String start=/'/ end=/'/ skip=/\\'/
            \ contained containedin=MarkdownPythonCode
syn keyword Keyword def if while for in or and import from return continue
            \ break yield await async try except else elif class raise del
            \ contained containedin=MarkdownPythonCode
syn keyword Boolean True False
            \ contained containedin=MarkdownPythonCode
syn keyword Constant None
            \ contained containedin=MarkdownPythonCode
syn match Number /\d\+\.\?/
            \ contained containedin=MarkdownPythonCode
syn match Operator /[/+*%&|<>^=-]/
            \ contained containedin=MarkdownPythonCode
syn match Function /[a-zA-Z_]\+[a-zA-Z_0-9]*\s*\ze(/
            \ contained containedin=MarkdownPythonCode
syn keyword Type int float list dict set bool str
            \ contained containedin=MarkdownPythonCode
syn match Comment /#.*$/
            \ contained containedin=MarkdownPythonCode

syn region MarkdownCppCode start=/^```c\(++\)\?$/ end=/^```$/
            \ contained containedin=MarkdownCode contains=MarkdownCodeJunk
syn region String start=/"/ end=/"/ skip=/\\"/
            \ contained containedin=MarkdownCppCode
syn region String start=/'/ end=/'/ skip=/\\'/
            \ contained containedin=MarkdownCppCode
syn keyword Keyword if while for or and return continue break delete
            \ try catch else class struct enum typedef throw new
            \ contained containedin=MarkdownCppCode
syn match PreProc /^#\w*/
            \ contained containedin=MarkdownCppCode
syn keyword Boolean true false null nullptr
            \ contained containedin=MarkdownCppCode
syn keyword Constant nullptr NULL std
            \ contained containedin=MarkdownCppCode
syn match Number /\d\+\.\?/
            \ contained containedin=MarkdownCppCode
syn match Operator /[/+*%&|<>^=-]/
            \ contained containedin=MarkdownCppCode
syn match Function /[a-zA-Z_]\+[a-zA-Z_0-9]*\s*\ze(/
            \ contained containedin=MarkdownCppCode
syn keyword Type int short long char float double const static
            \ uint8_t uint16_t uint32_t uint64_t bool
            \ contained containedin=MarkdownCppCode
syn match Comment /\/\/.*$/
            \ contained containedin=MarkdownCppCode
syn region Comment start=/\/\*/ end=/\*\//
            \ contained containedin=MarkdownCppCode

syn region MarkdownJsCode start=/^```\(javascript\|typescript\)$/ end=/^```$/
            \ contained containedin=MarkdownCode contains=MarkdownCodeJunk
syn region String start=/"/ end=/"/ skip=/\\"/
            \ contained containedin=MarkdownJsCode
syn region String start=/'/ end=/'/ skip=/\\'/
            \ contained containedin=MarkdownJsCode
syn keyword Keyword if while for or and return continue break
            \ try catch else class enum interface type extends require
            \ import from implements function const let var throw new
            \ contained containedin=MarkdownJsCode
syn keyword Boolean true false null undefined
            \ contained containedin=MarkdownJsCode
syn match Number /\d\+\.\?/
            \ contained containedin=MarkdownJsCode
syn match Operator /[/+*%&|<>^=-]/
            \ contained containedin=MarkdownJsCode
syn match Function /[a-zA-Z_]\+[a-zA-Z_0-9]*\s*\ze(/
            \ contained containedin=MarkdownJsCode
syn keyword Type Number Array String Float Object Boolean
            \ contained containedin=MarkdownJsCode
syn match Comment /\/\/.*$/
            \ contained containedin=MarkdownJsCode
syn region Comment start=/\/\*/ end=/\*\//
            \ contained containedin=MarkdownJsCode

syn region MarkdownShCode start=/^```\(sh\|bash\|zsh\|shell\)$/ end=/^```$/
            \ contained containedin=MarkdownCode contains=MarkdownCodeJunk
syn match Function /\v(([;&|]|^|<(do|if|while|in)>)\s*)@<=[a-zA-Z0-9_-]+/
            \ contained containedin=MarkdownShCode
syn region MarkdownShString start=/"/ end=/"/ skip=/\\"/
            \ contained containedin=MarkdownShCode
syn match Normal /\\./
            \ contained containedin=MarkdownShCode
hi link MarkdownShString String
syn region String start=/'/ end=/'/
            \ contained containedin=MarkdownShCode
syn keyword Keyword while for in do done if elif else fi case esac
            \ contained containedin=MarkdownShCode
syn keyword Boolean true false
            \ contained containedin=MarkdownShCode
syn match Number /\d\+\.\?/
            \ contained containedin=MarkdownShCode
syn match Operator /[/*|&!<>=$(){}]/
            \ contained containedin=MarkdownShCode
syn match Constant /\$[a-zA-Z0-9_]\+/
            \ contained containedin=MarkdownShCode,MarkdownShString
syn match Comment /#.*$/
            \ contained containedin=MarkdownShCode

syn region MarkdownLuaCode start=/^```lua$/ end=/^```$/
            \ contained containedin=MarkdownCode contains=MarkdownCodeJunk
syn region String start=/"/ end=/"/ skip=/\\"/
            \ contained containedin=MarkdownLuaCode
syn region String start=/'/ end=/'/ skip=/\\'/
            \ contained containedin=MarkdownLuaCode
syn keyword Keyword if elseif else while for function end in
            \ contained containedin=MarkdownLuaCode
syn keyword Boolean true false nil
            \ contained containedin=MarkdownLuaCode
syn match Number /\d\+\.\?/
            \ contained containedin=MarkdownLuaCode
syn match Operator /[/+*%&|<>^~=-]/
            \ contained containedin=MarkdownLuaCode
syn match Function /[a-zA-Z_]\+[a-zA-Z_0-9]*\s*\ze(/
            \ contained containedin=MarkdownLuaCode
syn match Comment /--.*$/
            \ contained containedin=MarkdownLuaCode
syn region Comment start=/--\[\[*/ end=/\]\]/
            \ contained containedin=MarkdownLuaCode

hi link MarkdownCodeJunk Comment
