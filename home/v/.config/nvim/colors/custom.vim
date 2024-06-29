"
" __     ___              ____      _                
" \ \   / (_)_ __ ___    / ___|___ | | ___  _ __ ___ 
"  \ \ / /| | '_ ` _ \  | |   / _ \| |/ _ \| '__/ __|
"   \ V / | | | | | | | | |__| (_) | | (_) | |  \__ \
"    \_/  |_|_| |_| |_|  \____\___/|_|\___/|_|  |___/
"

set notermguicolors

" COLOR PALETTE {{{

let s:bg     = "NONE"
let s:fg     = "NONE"

let s:white  = "231"
let s:bright = "white"
let s:cyan   = "darkcyan"
let s:orange = "darkyellow"
let s:red    = "darkred"
let s:green  = "darkgreen"
let s:yellow = "yellow"
let s:blue   = "darkblue"
let s:purple = "darkmagenta"
let s:grey   = "gray"

let s:grey_0 = "233"
let s:grey_1 = "234"
let s:grey_2 = "235"
let s:grey_3 = "236"
let s:grey_4 = "237"
let s:grey_5 = "238"
let s:grey_6 = "240"

" }}}
" HL FUNCTION {{{

function! HL(name, fg, bg, attr)
    exe "hi " . a:name
                \ . " ctermfg=" . a:fg
                \ . " ctermbg=" . a:bg
                \ . " cterm=" . a:attr
endfunction

" }}}
" HL DEFINITION {{{

call HL("Normal",                   s:fg,     s:bg,     "NONE")
call HL("Conceal",                  s:fg,     "NONE",   "NONE")
call HL("Cursor",                   "NONE",   "NONE",   "NONE")
call HL("CursorLine",               "NONE",   s:grey_0, "NONE")
call HL("CursorColumn",             "NONE",   s:grey_0, "NONE")
call HL("SignColumn",               "NONE",   "NONE",   "NONE")
call HL("FoldColumn",               "NONE",   "NONE",   "NONE")
call HL("VertSplit",                s:grey_2, "NONE",   "NONE")
call HL("LineNr",                   s:grey_2, "NONE",   "NONE")
call HL("CursorLineNr",             "NONE",   s:grey_0, "NONE")
call HL("CursorLineSign",           "NONE",   s:grey_0, "NONE")
call HL("CursorLineFold",           "NONE",   s:grey_0, "NONE")
call HL("Folded",                   s:grey_5, "NONE",   "NONE")
call HL("IncSearch",                s:yellow, s:grey_1, "NONE")
call HL("CurSearch",                s:yellow, s:grey_1, "NONE")
call HL("Search",                   "NONE",   s:grey_1, "NONE")
call HL("ModeMsg",                  "NONE",   "NONE",   "NONE")
call HL("NonText",                  s:grey_2, "NONE",   "NONE")
call HL("Question",                 s:purple, "NONE",   "NONE")
call HL("SpecialKey",               s:purple, "NONE",   "NONE")
call HL("StatusLine",               s:fg,     s:grey_1, "NONE")
call HL("StatusLineNC",             s:grey_5, s:grey_1, "NONE")
call HL("Title",                    s:green,  "NONE",   "BOLD")
call HL("Visual",                   "NONE",   s:grey_2, "NONE")
call HL("WarningMsg",               s:yellow, "NONE",   "NONE")
call HL("Pmenu",                    "NONE",   s:grey_1, "NONE")
call HL("PmenuSel",                 s:fg,     s:grey_3, "NONE")
call HL("PmenuThumb",               s:fg,     s:grey_2, "NONE")
call HL("PmenuSbar",                "NONE",   s:grey_1, "NONE")
call HL("CocMenu",                  s:fg,     "NONE",   "NONE")
call HL("CocMenuSel",               s:fg,     s:grey_3, "NONE")
call HL("CocFadeout",               s:grey_5, "NONE",   "NONE")
call HL("CocWarningSign",           s:orange, "NONE",   "NONE")
call HL("DiffDelete",               s:red,    "NONE",   "NONE")
call HL("DiffAdd",                  s:green,  "NONE",   "NONE")
call HL("DiffChange",               s:yellow, "NONE",   "BOLD")
call HL("DiffText",                 s:bg,     s:fg,     "NONE")
call HL("Underlined",               "NONE",   "NONE",   "UNDERLINE")
call HL("OperatorSandwichChange",   "NONE",   s:purple, "NONE")
call HL("Comment",                  s:grey_5,   "NONE",   "ITALIC")
call HL("Exception",                s:cyan,   "NONE",   "NONE")
call HL("Constant",                 s:cyan,   "NONE",   "NONE")
call HL("Float",                    s:orange, "NONE",   "NONE")
call HL("Number",                   s:orange, "NONE",   "NONE")
call HL("Boolean",                  s:orange, "NONE",   "NONE")
call HL("Identifier",               "NONE",   "NONE",   "NONE")
call HL("Keyword",                  s:purple, "NONE",   "NONE")
call HL("Error",                    s:red,    "NONE",   "NONE")
call HL("ErrorMsg",                 s:red,    "NONE",   "NONE")
call HL("String",                   s:green,  "NONE",   "NONE")
call HL("Character",                s:green,  "NONE",   "NONE")
call HL("PreProc",                  s:yellow, "NONE",   "NONE")
call HL("PreCondit",                s:yellow, "NONE",   "NONE")
call HL("StorageClass",             s:yellow, "NONE",   "NONE")
call HL("Structure",                s:yellow, "NONE",   "NONE")
call HL("Type",                     s:yellow, "NONE",   "NONE")
call HL("Special",                  s:blue,   "NONE",   "NONE")
call HL("WildMenu",                 s:bg,     s:blue,   "NONE")
call HL("Include",                  s:blue,   "NONE",   "NONE")
call HL("Function",                 s:blue,   "NONE",   "NONE")
call HL("Todo",                     s:purple, "NONE",   "NONE")
call HL("Repeat",                   s:purple, "NONE",   "NONE")
call HL("Define",                   s:purple, "NONE",   "NONE")
call HL("Macro",                    s:purple, "NONE",   "NONE")
call HL("Statement",                s:purple, "NONE",   "NONE")
call HL("Label",                    s:purple, "NONE",   "NONE")
call HL("Operator",                 s:purple, "NONE",   "NONE")
call HL("MatchParen",               s:purple, s:grey_1, "NONE")
call HL("TabLine",                  s:fg,     s:grey_1, "NONE")
call HL("TabLineFill",              "NONE",   s:grey_1, "NONE")
call HL("TabLineSel",               s:bright, s:grey_1, "NONE")
call HL("Directory",                s:blue,   "NONE",   "NONE")

call HL("LeapMatch",                "NONE",   s:grey_1, "NONE")
call HL("LeapLabelPrimary",         "NONE",   s:grey_1, "NONE")
call HL("LeapLabelSecondary",       "NONE",   s:grey_1, "NONE")


call HL("@boolean",          s:orange,  "NONE", "NONE")
call HL("@character",        s:orange,  "NONE", "NONE")
call HL("@comment",          s:grey_5,  "NONE", "italic")
call HL("@conditional",      s:purple,  "NONE", "NONE")
call HL("@constant",         s:cyan,    "NONE", "NONE")
call HL("@constant.builtin", s:cyan,    "NONE", "NONE")
call HL("@constant.macro",   s:orange,  "NONE", "NONE")
call HL("@constructor",      "NONE",    "NONE", "NONE")
call HL("@exception",        s:purple,  "NONE", "NONE")
call HL("@field",            s:white,   "NONE", "NONE")
call HL("@float",            s:orange,  "NONE", "NONE")
call HL("@function",         s:blue,    "NONE", "NONE")
call HL("@function.builtin", s:blue,    "NONE", "NONE")
call HL("@function.macro",   s:blue,    "NONE", "NONE")
call HL("@include",          s:purple,  "NONE", "NONE")
call HL("@keyword",          s:purple,  "NONE", "NONE")
call HL("@label",            s:red,     "NONE", "NONE")
call HL("@method",           s:blue,    "NONE", "NONE")
call HL("@number",           s:orange,  "NONE", "NONE")
call HL("@operator",         s:purple,  "NONE", "NONE")
call HL("@parameter",        s:white,   "NONE", "NONE")
call HL("@property",         s:white,   "NONE", "NONE")
call HL("@punctuation",      s:white,   "NONE", "NONE")
call HL("@repeat",           s:purple,  "NONE", "NONE")
call HL("@string",           s:green,   "NONE", "NONE")
call HL("@string.escape",    s:grey_6,  "NONE", "NONE")
call HL("@type",             "NONE",    "NONE", "NONE")
call HL("@type.builtin",     s:yellow,  "NONE", "NONE")
call HL("@type.qualifier",   s:yellow,  "NONE", "NONE")
call HL("@type.definition",  s:red,     "NONE", "NONE")
call HL("@variable",         s:white,   "NONE", "NONE")
call HL("@variable.builtin", s:white,   "NONE", "NONE")
call HL("@tag",              s:red,     "NONE", "NONE")
call HL("@tag.delimiter",    s:grey_6,  "NONE", "NONE")
call HL("@tag.attribute",    s:yellow,  "NONE", "NONE")

call HL("DiagnosticErrorLine",      s:red,    s:grey_0, "NONE")
call HL("DiagnosticWarnLine",       s:orange, s:grey_0, "NONE")
call HL("DiagnosticHintLine",       s:orange, s:grey_0, "NONE")
call HL("DiagnosticInfoLine",       s:orange, s:grey_0, "NONE")

call HL("DiagnosticSignError",      s:red,    "NONE",   "NONE")
call HL("DiagnosticSignWarn",       s:orange, "NONE",   "NONE")
call HL("DiagnosticSignHint",       s:orange, "NONE",   "NONE")
call HL("DiagnosticSignInfo",       s:orange, "NONE",   "NONE")

call HL("DiagnosticError",          "NONE",   "NONE",   "NONE")
call HL("DiagnosticWarn",           s:orange, "NONE",   "NONE")
call HL("DiagnosticHint",           "NONE",   "NONE",   "NONE")
call HL("DiagnosticInfo",           s:cyan,   "NONE",   "NONE")
call HL("DiagnosticUnnecessary",    s:grey_5, "NONE",   "NONE")
call HL("DiagnosticUnderlineError", s:red,    "NONE",   "NONE")
call HL("DiagnosticUnderlineHint",  s:grey_5, "NONE",   "NONE")
call HL("DiagnosticUnderlineInfo",  s:grey_5, "NONE",   "NONE")
call HL("DiagnosticUnderlineWarn",  s:orange, "NONE",   "NONE")

call HL("Border",                   s:grey_3, "NONE",   "NONE")
" call HL("NormalFloat",              "NONE",   "NONE",   "NONE")

call HL("CmpItemAbbrDeprecated",    s:grey_5, "NONE",   "strikethrough")
call HL("CmpItemKindText",          s:grey_5, "NONE",   "NONE")
call HL("CmpItemKindMethod",        s:blue,   "NONE",   "NONE")
call HL("CmpItemKindFunction",      s:blue,   "NONE",   "NONE")
call HL("CmpItemKindInterface",     s:yellow, "NONE",   "NONE")
call HL("CmpItemKindClass",         s:yellow, "NONE",   "NONE")
call HL("CmpItemKindStruct",        s:yellow, "NONE",   "NONE")
call HL("CmpItemKindConstant",      s:cyan,   "NONE",   "NONE")
call HL("CmpItemKindVariable",      s:purple, "NONE",   "NONE")
call HL("CmpItemMenu",              s:grey_5, "NONE",   "NONE")

" exe "hi SpellCap gui=UNDERCURL guisp=" . s:yellow
" exe "hi SpellBad gui=UNDERCURL guisp=" . s:red
exe "hi SpellCap gui=UNDERCURL guifg=" . s:yellow
exe "hi SpellBad gui=UNDERCURL guifg=" . s:red

call HL("BqfPreviewFloat", "NONE", "232", "NONE")
call HL("QuickFixLine", "NONE", "NONE", "bold")
hi default link BqfPreviewBorder Border
" call HL("BqfPreviewCursor", "NONE", "NONE", "NONE")
hi default link BqfPreviewRange  IncSearch

" }}}
" TERMINAL HIGHLIGHTING {{{

let g:terminal_color_0  = s:grey_5
let g:terminal_color_1  = s:red
let g:terminal_color_2  = s:green
let g:terminal_color_3  = s:yellow
let g:terminal_color_4  = s:blue
let g:terminal_color_5  = s:purple
let g:terminal_color_6  = s:cyan
let g:terminal_color_7  = s:white
let g:terminal_color_8  = s:grey_5
let g:terminal_color_9  = s:red
let g:terminal_color_10 = s:green
let g:terminal_color_11 = s:yellow
let g:terminal_color_12 = s:blue
let g:terminal_color_13 = s:purple
let g:terminal_color_14 = s:cyan
let g:terminal_color_15 = s:white

" }}}
" VISUAL CURSORLINE {{{

" in vim, the cursorline disappears when in visual mdoe
" however, the cursorline in the number column remains
" this function + autocommands removes cusorline from
" the number column when in visual mode

function RemoveCursorlineInVisual()
    if mode() =~# "^[vV\x16]"
        set showcmd
        exe "hi CursorLineNr ctermbg=" . s:bg
    else
        set noshowcmd
        exe "hi CursorLineNr ctermbg=" . s:grey_0
    endif
endfunction

if !exists("cul_au_loaded")
    let cul_au_loaded = 1
    au ModeChanged [vV\x16]*:* call RemoveCursorlineInVisual()
    au ModeChanged *:[vV\x16]* call RemoveCursorlineInVisual()
    au WinEnter,WinLeave *     call RemoveCursorlineInVisual()
endif


sign define DiagnosticSignError text=>>
            \ texthl=DiagnosticSignError
            \ culhl=DiagnosticErrorLine
sign define DiagnosticSignWarn text=>>
            \ texthl=DiagnosticSignWarn
            \ culhl=DiagnosticWarnLine
sign define DiagnosticSignInfo text=>>
            \ texthl=DiagnosticSignInfo
            \ culhl=DiagnosticInfoLine
sign define DiagnosticSignHint text=>>
            \ texthl=DiagnosticSignHint
            \ culhl=DiagnosticHintLine


" }}}

" vim:nowrap:foldmethod=marker
