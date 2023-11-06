vim.g.maplocalleader = "\\"

require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "lua", "rust", "go", "python", "javascript", "typescript", "gitignore", "markdown" },
	sync_install = true,
	auto_install = true,
	indent = { enable = true },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	autopairs = {
		enable = true,
	},
	autotag = { -- html tags
		enable = true,
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
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
			},
		},
		swap = {
			enable = true,
			swap_previous = {
				["<space><left>"] = "@parameter.inner",
			},
			swap_next = {
				["<space><right>"] = "@parameter.inner",
			},
		},
		lsp_interop = {
			enable = true,
			border = 'none',
			lookahead = true,
			floating_preview_opts = {},
			peek_definition_code = {
				["\\f"] = "@function.inner",
				["\\c"] = "@class.inner",
			},
		},
	},
}
