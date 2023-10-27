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
	'lukas-reineke/indent-blankline.nvim',
	{ -- Treesitter
		{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true }
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
	{ -- Cmp
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
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
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		dependencies = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' },          -- Cornerstone. lsp-zero is built on top of it.
			{ 'williamboman/mason.nvim' },        -- lsp-servers file-manager
			{ 'williamboman/mason-lspconfig.nvim' }, -- lsp-servers file-manager
			{ 'lukas-reineke/lsp-format.nvim' }   -- Auto-Formatting
		}
	},
	--

	-- Colorschemes
	{ 'rose-pine/neovim',      name = 'rose-pine' },
	{ "catppuccin/nvim",       name = "catppuccin" },
	{ "folke/tokyonight.nvim", name = "tokyonight" },
	"projekt0n/github-nvim-theme",
	--

	'lervag/vimtex',
	--'jose-elias-alvarez/null-ls.nvim',
	'nvim-telescope/telescope-file-browser.nvim',
	'nvim-telescope/telescope-media-files.nvim',
	"folke/persistence.nvim",
	"folke/todo-comments.nvim",
	"notjedi/nvim-rooter.lua",
	--"ahmedkhalf/project.nvim",
})
