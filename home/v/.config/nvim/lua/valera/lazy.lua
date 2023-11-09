local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ' ' -- ensure mappings are correct

return require('lazy').setup({
	-- Cornerstone
	'theprimeagen/harpoon',
	'mbbill/undotree',
	'L3MON4D3/LuaSnip',
	"lewis6991/gitsigns.nvim",
	'lukas-reineke/indent-blankline.nvim',
	{ -- Treesitter
		{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
		"nvim-treesitter/nvim-treesitter-textobjects",
		"JoosepAlviste/nvim-ts-context-commentstring",
		"windwp/nvim-ts-autotag",
		"windwp/nvim-autopairs",
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			"nvim-telescope/telescope-live-grep-args.nvim"
		}
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			{ 'nvim-tree/nvim-web-devicons', lazy = true },
			"lewis6991/gitsigns.nvim",
			"nvim-lua/lsp-status.nvim",
		}
	},
	{
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {}
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
	},
	{
		'stevearc/oil.nvim',
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{ -- Jake
		-- 2q and then Q for recursive macro
		'jake-stewart/recursive-macro.nvim',
		-- helix for poor people
		'jake-stewart/normon.nvim',
		'jake-stewart/shnip.nvim',
		-- adds <M-o> and <M-i> to jump across files
		{
			"jake-stewart/filestack.nvim",
			config = function()
				require("filestack").setup()
			end
		},
	},
	{ -- simple swap of items like (arg1, arg2, arg3)
		'machakann/vim-swap',
		keys = {
			{ "g<", "<plug>(swap-prev)" },
			{ "g>", "<plug>(swap-next)" },
		},
	},
	{ -- https://github.com/tpope/vim-abolish/blob/master/doc/abolish.txt
		'tpope/vim-abolish',
		keys = {
			{ "cr" },
		},
		-- ex: :%S/facilit{y,ies}/building{,s}/g
		cmd = { "S", "Subvert" },
	},
	{ -- CamelCaseACRONYMWords_underscore1234
		--w --->w-->w----->w---->w-------->w->w
		--e -->e-->e----->e--->e--------->e-->e
		--b < ---b<--b<-----b<----b<--------b<-b
		'chaoren/vim-wordmotion',
		keys = {
			{ "w", mode = { "n", "v", "o", "x" } },
			{ "b", mode = { "n", "v", "o", "x" } },
			{ "e", mode = { "n", "v", "o", "x" } },
		},
	},
	-- similar to helix's match
	"wellle/targets.vim",
	{ -- Cmp
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-cmdline',
		'saadparwaiz1/cmp_luasnip',
		'hrsh7th/cmp-nvim-lua',
	},
	{ -- Dap
		'mfussenegger/nvim-dap',
		'leoluz/nvim-dap-go',
		'mfussenegger/nvim-dap-python',
		{ 'rcarriga/nvim-dap-ui', name = 'dapui' },
		'theHamsta/nvim-dap-virtual-text',
		'nvim-telescope/telescope-dap.nvim',
		'jay-babu/mason-nvim-dap.nvim',
	},
	{ -- Lsp
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		dependencies = {
			-- LSP Support
			'neovim/nvim-lspconfig',          -- Cornerstone. lsp-zero is built on top of it.
			'williamboman/mason.nvim',        -- lsp-servers file-manager
			'williamboman/mason-lspconfig.nvim', -- lsp-servers file-manager
			'lukas-reineke/lsp-format.nvim',  -- Auto-Formatting
			'onsails/lspkind.nvim',
		}
	},
	{ -- Rust
		'Saecki/crates.nvim',
	},
	{ -- Colorschemes
		{ 'rose-pine/neovim',      name = 'rose-pine' },
		{ "catppuccin/nvim",       name = "catppuccin" },
		{ "folke/tokyonight.nvim", name = "tokyonight" },
		"projekt0n/github-nvim-theme",
	},
	--

	-- If something breaks, it's likely below here:

	'lervag/vimtex',
	'olimorris/persisted.nvim',
	'nvim-telescope/telescope-file-browser.nvim',
	'nvim-telescope/telescope-media-files.nvim',
	"folke/persistence.nvim",
	"folke/todo-comments.nvim",
	'jbyuki/instant.nvim',
	{
		'kaarmu/typst.vim',
		ft = 'typst',
		lazy = false,
	},
	{
		'kawre/leetcode.nvim',
		build = ":TSUpdate html",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim", -- required by telescope
			"MunifTanjim/nui.nvim",

			-- optional
			"rcarriga/nvim-notify",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"folke/which-key.nvim",
		},
	},

})
