--https://github.com/jake-stewart/shnip.nvim/blob/main/lua/shnip.lua
-- if needed, could add non-language agnostic snippets like:
-- require("shnip").snippet("<c-p>", "()<left>")

-- for now leaving as is.
-- To test something, do:
--require("shnip").setup(
--    overrides = {
--        python = {  -- filetype
--            extra = {
--                ["<c-a>"] = "new snippet"
--            },
--            print = false,  -- disable a snippet
--            class = "modified snippet",
--        },
--    }
--}
-- Probably no reason to fork the thing; the api is sufficient.

local shnip = require("shnip")


shnip.setup({
	leader = "<c-s>",
	keys = {
		["print"]    = "<c-p>",
		["debug"]    = "<c-d>",
		["error"]    = "<c-x>",
		["while"]    = "<c-w>",
		["for"]      = "<c-f>",
		["if"]       = "<c-i>",
		["elseif"]   = "<c-o>",
		["else"]     = "<c-e>",
		["switch"]   = "<c-s>",
		["case"]     = "<c-c>",
		["default"]  = "<c-b>",
		["function"] = "<c-z>",
		["lambda"]   = "<c-l>",
		["class"]    = "<c-k>",
		["struct"]   = "<c-h>",
		["try"]      = "<c-t>",
		["enum"]     = "<c-n>"
	},
	overrides = {
		rust = {
			["struct"] = "#[derive(Clone, Debug, Default, derive_new::new)]<CR>struct  {<CR>}<Esc>kg_hi", -- I guess now I have to manually derive Default for all enums
			extra = {
				["<c-t>"] = "tokio::spawn(async move {<CR>});<Esc>O",
				["<c-u>"] = "loop {<CR>}<Esc>ko",
				["<down>"] = "impl  {<CR>}<Esc>kg_hi",
				["<c-r>"] = "#[derive()]<Esc>hi",
				["<c-y>"] = "todo!()<Esc>",
			},
		},
		go = {
			extra = {
				["<c-r>"] = "if err!=nil {<CR>}",
				["<down>"] = "if err!=nil {<CR>return err<CR>}<Esc>",
				["<c-u>"] = "while true {<CR>}<Esc>ko",
			},
		},
		python = {
			extra = {
				["<c-u>"] = "while True:<CR>",
				["<c-y>"] = "raise NotImplementedError()<Esc>",
			}
		},
		typst = {
			extra = {
				["<c-u>"] = "#underscore[]<Esc>hi",
			}
		}
	},
})

shnip.addFtSnippets("typst", {
	["print"] = "",
	["debug"] = "",
	["error"] = "",
	["while"] = "",
	["for"] = "",
	["if"] = "",
	["elseif"] = "",
	["else"] = "",
	["switch"] = "",
	["case"] = "",
	["default"] = "bold(1)_",
	["function"] = "",
	["lambda"] = "$  $<Esc>hi",
	["class"] = "",
	["struct"] = "$<Esc>O$ ",
	["try"] = "",
})

shnip.addFtSnippets("sh", {
	["print"] = "",
	["debug"] = "",
	["error"] = "if [ $? -ne 0 ]; then<CR>return 1<CR>fi<Esc>",
	["while"] = "",
	["for"] = "",
	["if"] = "",
	["elseif"] = "",
	["else"] = "",
	["switch"] = "",
	["case"] = "",
	["default"] = "",
	["function"] = "",
	["lambda"] = "",
	["class"] = "",
	["struct"] = "",
	["try"] = "",
})
