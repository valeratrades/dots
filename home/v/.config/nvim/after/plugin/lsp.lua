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

function ToggleVirtualText()
	local config = vim.diagnostic.config
	local virtual_text = config().virtual_text

	if virtual_text then
		config({ virtual_text = false })
	else
		config({ virtual_text = true })
	end
end

-- -- Open popup or jump to next problem
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
	pcall(function()
		local bufnr = vim.api.nvim_get_current_buf()
		local diagnostics = vim.diagnostic.get(bufnr)
		if #diagnostics == 0 then
			Echo("no diagnostics in 0", "Comment")
		end
		local line = vim.fn.line(".") - 1
		-- severity is [1:4], the lower the "worse"
		local allSeverity = { 1, 2, 3, 4 }
		local targetSeverity = allSeverity
		for _, d in pairs(diagnostics) do
			if d.lnum == line and not BoolPopupOpen() then
				-- meaning we selected casually
				vim.diagnostic.open_float(floatOpts)
				return
			end
			-- only navigate between errors, if there are any
			if d.severity == 1 and requestSeverity ~= 'all' then
				targetSeverity = { 1 }
			end
		end


		local go_action = direction == 1 and "goto_next" or "goto_prev"
		local get_action = direction == 1 and "get_next" or "get_prev"
		if targetSeverity ~= allSeverity then
			vim.diagnostic[go_action]({ float = floatOpts, severity = targetSeverity })
			return
		else
			-- jump over all on current line
			local nextOnAnotherLine = false
			while not nextOnAnotherLine do
				local d = vim.diagnostic[get_action]({ severity = allSeverity })
				-- this piece of shit is waiting until the end of the function before execution for some reason
				vim.api.nvim_win_set_cursor(0, { d.lnum + 1, d.col })
				if d.lnum ~= line then
					nextOnAnotherLine = true
					break
				end
				if #diagnostics == 1 then
					return
				end
			end
			-- if not, nvim_win_set_cursor will execute after it.
			vim.defer_fn(function() vim.diagnostic.open_float(floatOpts) end, 1)
			return
		end
	end)
end

function YankDiagnosticPopup()
	local popups = GetPopups()
	if #popups == 1 then
		local popup_id = popups[1]
		local bufnr = vim.api.nvim_win_get_buf(popup_id)
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local content = table.concat(lines, "\n")
		vim.fn.setreg('+', content)
	else
		return
	end
end

--

local on_attach = function(client, bufnr)
	local function map(lhs, rhs, desc)
		local opts = { buffer = bufnr, noremap = true, desc = "lsp: " .. desc }
		vim.keymap.set("n", lhs, rhs, opts)
	end

	-- can't change names of these two, as they have same functions without lsp
	map("K", "<cmd>lua vim.lsp.buf.hover()<cr>", "hover info")
	map("gd", "<cmd>lua vim.lsp.buf.definition()<cr>", "definition")

	map("<C-r>", "<cmd>lua JumpToDiagnostic(1, 'max')<cr>", "next: errors only")
	map("<C-n>", "<cmd>lua JumpToDiagnostic(-1, 'max')<cr>", "prev: errors only")
	map("<C-A-r>", "<cmd>lua JumpToDiagnostic(1, 'all')<cr>", "next: whatever")
	map("<C-A-n>", "<cmd>lua JumpToDiagnostic(-1, 'all')<cr>", "prev: whatever")

	map("<Space>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "declaration")
	map("<Space>lt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "type definition")
	map("<Space>li", "<cmd>Telescope lsp_implementations<cr>", "implementations")
	map("<Space>lr", "<cmd>Telescope lsp_references<cr>", "references")
	map("<Space>ld", "<cmd>Telescope diagnostics<cr>", "diagnostics")
	map("<Space>ll", "<cmd>Telescope diagnostics bufnr=0<cr>", "local diagnostics")
	map("<Space>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", "rename")
	map("<Space>lw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "workspace symbol")
	map("<Space>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "format")
	map("<Space>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", "code action")
	map("<Space>lz", "<cmd>lua vim.cmd.LspRestart()<cr>", "restart")

	map("<Space>ly", "<cmd>lua YankDiagnosticPopup()<cr>", "\"+y the popup")
	map("<Space>ls", "<cmd>lua ToggleDiagnostics()<cr>", "toggle diagnostics on/off")
	map("<Space>lv", "<cmd>lua ToggleVirtualText()<cr>", "toggle virtual text")

	map("<Space>l2", "<cmd>lua vim.opt.shiftwidth=2<cr><cmd>lua vim.opt.tabstop=2<cr>", "tab := 2")
	map("<Space>l4", "<cmd>lua vim.opt.shiftwidth=4<cr><cmd>lua vim.opt.tabstop=4<cr>", "tab := 4")


	if client.supports_method('textDocument/formatting') then
		require('lsp-format').on_attach(client)
	end

	vim.bo.tabstop = 2
	vim.bo.softtabstop = 0
	vim.bo.shiftwidth = 2
	vim.bo.expandtab = false
end


lsp_zero.on_attach(on_attach)


-- Language setups
local lspconfig_servers = { 'lua_ls', 'gopls', 'rust_analyzer', 'pyright', 'bashls' }
lsp_zero.setup_servers(lspconfig_servers)
lsp_zero.setup()

vim.g.rust_recommended_style = false


local lua_opts = lsp_zero.nvim_lua_ls()
lspconfig.lua_ls.setup(lua_opts)
lspconfig.htmx.setup {
	on_attach = on_attach,
}
lspconfig.leanls.setup {
	on_attach = on_attach,
}
--lspconfig.typst_lsp.setup {
--	on_attach = on_attach,
--	settinsg = {
--		exportPdf = "onType",
--		serverPath = "/usr/local/bin/typst-lsp",
--	}
--}

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
