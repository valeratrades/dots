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

require("shnip").setup({
	leader = "<c-s>",
	keys = {
		["print"]    = "<down>",
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
		["function"] = "<c-m>",
		["lambda"]   = "<c-l>",
		["class"]    = "<c-k>",
		["struct"]   = "<c-h>",
		["try"]      = "<c-t>",
		["enum"]     = "<c-n>"
	},
	overrides = {
		rust = {
			extra = {
				["<c-j>"] = "#[derive(Debug, Serialize, Deserialize)]<CR>struct  {<CR>}<Esc>kg_hi",
				["<c-u>"] = "loop {<CR>}<Esc>ko",
				["<c-p>"] = "impl  {<CR>}<Esc>kg_hi",
			},
		},
		go = {
			extra = {
				["<c-r>"] = "if err!=nil {<CR>}",
				["<c-p>"] = "if err!=nil {<CR>panic!(\"1) What\")<CR>}",
			},
		},

	},
})
