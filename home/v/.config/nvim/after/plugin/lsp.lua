-- https://www.reddit.com/r/neovim/comments/og1cdv/neovim_lsp_how_do_you_get_diagnostic_mesages_to/

local lspconfig = require('lspconfig')
local lsp_zero = require('lsp-zero')

vim.diagnostic.config({
	virtual_text = false,
	-- if line has say both a .HINT and .WARNING, the "worst" will be shown (as a sign on the left)
	severity_sort = true,
})

-- doesn't do anything and here only as a reminder (as vim.g.maplocalleader doesn't work for some reason).
local leader = 'l'

function ToggleDiagnostics()
	local state = vim.diagnostic.is_disabled()
	if state then
		vim.diagnostic.enable()
	else
		vim.diagnostic.disable()
	end
end

-- -- Open popup or jump to next problem
-- the solution with always showing all errors no the line is here:
-- https://github.com/jake-stewart/dotfiles/blob/main/.config/nvim/lua/plugins/nvim-lspconfig.lua
local function getPopups()
	return vim.fn.filter(vim.api.nvim_tabpage_list_wins(0),
		function(_, e) return vim.api.nvim_win_get_config(e).zindex end)
end
local function popupOpen()
	return #getPopups() > 0
end
local floatOpts = {
	format = function(diagnostic)
		return vim.split(diagnostic.message, "\n")[1]
	end,
	-- source = true,
	-- prefix = "",
	-- suffix = "",
	focusable = false,
	header = ""
}
function JumpToDiagnostic(direction, requestSeverity)
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)
	local line = vim.fn.line(".") - 1
	-- severity is [1:4], the lower the "worse"
	local targetSeverity = { 1, 2, 3, 4 }
	local selectedCasually = false
	if requestSeverity ~= 'all' then -- '~=' is '!=' in this crazy language.
		for _, d in pairs(diagnostics) do
			if d.lnum == line then
				selectedCasually = true
			end
			-- only navigate between errors, if there are any
			if d.severity == 1 then
				targetSeverity = { 1 }
			end
		end
	end

	local search = direction == 1 and "get_next_pos" or "get_prev_pos"
	--TODO:
	local pos = vim.diagnostic[search]()
	print(pos.row)
	--
	local action = direction == 1 and "goto_next" or "goto_prev"
	if popupOpen() then
		vim.diagnostic[action]({ float = floatOpts, severity = targetSeverity })
	elseif selectedCasually then
		vim.diagnostic.open_float(floatOpts)
	else
		vim.diagnostic[action]({
			cursor_position = {
				vim.fn.line("."),
				direction == 1 and 0 or 9999
			},
			float = floatOpts,
			severity = targetSeverity
		})
	end
end

--

lsp_zero.on_attach(function(client, bufnr)
	local function map(lhs, rhs, desc)
		local opts = { buffer = bufnr, noremap = true, desc = "lsp: " .. desc }
		vim.keymap.set("n", lhs, rhs, opts)
	end

	-- can't change these two, as they have same functions without lsp
	map("K", "<cmd>lua vim.lsp.buf.hover()<cr>", "lsp: hover info")
	map("gd", "<cmd>lua vim.lsp.buf.definition()<cr>", "lsp: definition")

	-- map("lk", "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<cr>", "open error like 'K'")
	map("<C-t>", "<cmd>lua JumpToDiagnostic(1, 'max')<cr>", "lsp: next diagnostic")
	map("<C-n>", "<cmd>lua JumpToDiagnostic(-1, 'max')<cr>", "lsp: prev diagnostic")
	map("<C-A-t>", "<cmd>lua JumpToDiagnostic(1, 'all')<cr>", "lsp: next diagnostic")
	map("<C-A-n>", "<cmd>lua JumpToDiagnostic(-1, 'all')<cr>", "lsp: prev diagnostic")
	map("ls", "<cmd>lua ToggleDiagnostics()<cr>", "lsp: toggle diagnostics visibility")
	map("lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "lsp: declaration")
	map("lt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "lsp: type definition")
	map("li", "<cmd>lua vim.lsp.buf.implementation()<cr>", "lsp: implementation")
	map("lr", "<cmd>lua vim.lsp.buf.references()<cr>", "lsp: references")
	map("lR", "<cmd>lua vim.lsp.buf.rename()<cr>", "lsp: rename")
	map("lw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "lsp: workspace symbol")
	map("lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "lsp: format")
	map("lo", "<cmd>lua vim.lsp.buf.open_floating()<cr>", "lsp: open float")
	map("la", "<cmd>lua vim.lsp.buf.code_action()<cr>", "lsp: code action")
	map("lh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "lsp: signature help")
	-- The following is obsolete with the popup jumps available
	-- map("lqw", "<cmd>lua vim.diagnostic.setqflist()<cr>", "lsp: put window diagnostics to qf")
	-- --TODO: check if this thing works:
	-- map("lqb", "<cmd>lua set_qflist({ bufnr })<cr>", "lsp: put buffer diagnostics to qf")
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
