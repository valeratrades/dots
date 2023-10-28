vim.g.maplocalleader = "\\"
-- As pre usual, it doesn't work for shit, so using its value manually instead

require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "lua", "rust", "go", "python", "javascript", "typescript", "gitignore", "markdown" },
	sync_install = true,
	auto_install = true,
	indent = { enable = true },
	highlight = {
		enable = true,
		--disable = { 'rust', 'go' },
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "\\,",
			node_incremental = "\\,",
			scope_incremental = false,
			node_decremental = "\\.",
		},
	},
	textobjects = {
		lsp_interop = {
			enable = true,
			border = 'none',
			floating_preview_opts = {},
			peek_definition_code = {
				["\\f"] = "@function.outer",
				["\\F"] = "@class.outer",
			},
		},
	},
	--textobjects = {
	--	select = {
	--		enable = true,
	--
	--		-- Automatically jump forward to textobj, similar to targets.vim
	--		lookahead = true,
	--
	--		keymaps = {
	--			-- You can use the capture groups defined in textobjects.scm
	--			["af"] = "@function.outer",
	--			["if"] = "@function.inner",
	--			["ac"] = "@class.outer",
	--			["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
	--			-- You can also use captures from other query groups like `locals.scm`
	--			["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
	--		},
	--	},
	--	selection_modes = {
	--		['@parameter.outer'] = 'v', -- charwise
	--		['@function.outer'] = 'V', -- linewise
	--		['@class.outer'] = '<c-v>', -- blockwise
	--	},
	--	include_surrounding_whitespace = false,
	--}
}
















-- -- I'm assuming this is taken care of already by the `auto_install = true`
-- local parsers = require'nvim-treesitter.parsers'
-- function _G.ensure_treesitter_language_installed()
--   local lang = parsers.get_buf_lang()
--   if parsers.get_parser_configs()[lang] and not parsers.has_parser(lang) then
--     vim.schedule_wrap(function()
--     vim.cmd("TSInstallSync "..lang)
--     vim.cmd[[e!]]
--     end)()
--   end
-- end
--
-- vim.cmd[[autocmd FileType * :lua ensure_treesitter_language_installed()]]
