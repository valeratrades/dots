-- https://www.reddit.com/r/neovim/comments/og1cdv/neovim_lsp_how_do_you_get_diagnostic_mesages_to/

local lspconfig = require('lspconfig')
local lsp_zero = require('lsp-zero')

vim.diagnostic.config({
	virtual_text = false,
})

-- doesn't do anything and here only as a reminder (as vim.g.maplocalleader doesn't work for some reason).
local leader = 'l'

lsp_zero.on_attach(function(client, bufnr)
	local function map(lhs, rhs, desc)
		local opts = { buffer = bufnr, noremap = true, desc = "lsp: " .. desc }
		vim.keymap.set("n", lhs, rhs, opts)
	end

	-- can't change these two, as they have same functions without lsp
	map("K", "<cmd>lua vim.lsp.buf.hover()<cr>", "hover info")
	map("gd", "<cmd>lua vim.lsp.buf.definition()<cr>", "definition")

	map("lk", "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<cr>", "open error like 'K'")
	map("lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "declaration")
	map("lt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "type definition")
	map("li", "<cmd>lua vim.lsp.buf.implementation()<cr>", "implementation")
	map("lr", "<cmd>lua vim.lsp.buf.references()<cr>", "references")
	map("lR", "<cmd>lua vim.lsp.buf.rename()<cr>", "rename")
	-- TODO: If possible, make it ignore all warnings if there are any errors.
	--// probably, want to adjust the level of scrutiny of the lsp engine itself. So it doesn't even show them warnings until I ask it to.
	map("lt", "<cmd>lua vim.diagnostic.goto_next()<cr>", "next diagnostic")
	map("ln", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "prev diagnostic")
	map("ls", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "workspace symbol")
	map("lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "format")
	map("lo", "<cmd>lua vim.lsp.buf.open_floating()<cr>", "open float")
	map("la", "<cmd>lua vim.lsp.buf.code_action()<cr>", "code action")
	map("lh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "signature help")
	map("lqw", "<cmd>lua vim.diagnostic.setqflist()<cr>", "put window diagnostics to qf")
	--TODO: check if this thing works:
	map("lqb", "<cmd>lua set_qflist({ bufnr })<cr>", "put buffer diagnostics to qf")
	map('<c-r>', "<cmd>lua vim.cmd.LspRestart()<cr>", "lsp: restart")

	if client.supports_method('textDocument/formatting') then
		require('lsp-format').on_attach(client)
	end

	vim.bo.tabstop = 2
	vim.bo.softtabstop = 0
	vim.bo.shiftwidth = 2
	vim.bo.expandtab = false
end)

-- Language setups
local lspconfig_servers = { 'lua_ls', 'gopls', 'rust_analyzer', 'pyright', 'bashls' }
lsp_zero.setup_servers(lspconfig_servers)
lsp_zero.setup()

vim.g.rust_recommended_style = false


local lua_opts = lsp_zero.nvim_lua_ls()
lspconfig.lua_ls.setup(lua_opts)

require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = lspconfig_servers,
	handlers = { lsp_zero.default_setup },
	settings = {
		["rust-analyzer"] = {
			cmd = {
				"rustup", "run", "nightly", "rust-analyzer",
			},
			rustfmt = {
				overrideCommand = { "rustfmt" },
			},
			cargo = {
				runBuildScripts = true,
				loadOutDirsFromCheck = true,
			},
			procMacro = {
				enable = true,
			},
			checkOnSave = {
				enable = true,
				command = "clippy",
			}
		},
		["gopls"] = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
		["pyright"] = {
			analysis = {
				typeCheckingMode = "strict",
				autoSearchPaths = true,
				diagnosticMode = 'openFilesOnly',
			},
			before_init = function(params)
				params.initializationOptions = {
					cmd = {
						"pyright-langserver",
						"--stdio",
					},
				}
			end,
		},
	},
})
