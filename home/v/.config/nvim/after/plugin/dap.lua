local dap = require('dap')
local dapui = require('dapui')
local dap_go = require('dap-go')
local dap_python = require('dap-python')
dap_python.test_runner = "pytest"

-- uhm, so do I need this?
require('mason-nvim-dap').setup {
	automatic_setup = true,

	handlers = {},
}

-- DAP keymaps
vim.keymap.set('n', '<F2>', function() require('dap').step_into() end, { desc = "DAP: Step Into" })
vim.keymap.set('n', '<F3>', function() require('dap').step_over() end, { desc = "DAP: Step Over" })
vim.keymap.set('n', '<F4>', function() require('dap').step_out() end, { desc = "DAP: Step Out" })
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "DAP: Start/Continue" })
vim.keymap.set('n', '<F6>', function() require('dapui').toggle() end, { desc = "DAP: Toggle Windows" })

-- DAP space commands
vim.keymap.set('n', '<Space>dd', function() vim.cmd('RustLsp debug') end, { desc = "DAP: Start (RustLsp)" })
vim.keymap.set('n', '<Space>db', function() require('dap').toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set('n', '<Space>dB', function()
	require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "DAP: Input Breakpoint" })
vim.keymap.set('n', '<Space>di', function() require('dap').repl.open() end, { desc = "DAP: Repl Open" })
vim.keymap.set('n', '<Space>dr', function() require('dapui').open({ reset = true }) end,
	{ desc = "DAP: Restore Windows Layout" })
vim.keymap.set('n', '<Space>de', function() require('dapui').eval() end, { desc = "DAP: Eval" })
vim.keymap.set('n', '<Space>dE', function()
	require('dapui').eval(vim.fn.input('[DAP] Expression > '))
end, { desc = "DAP: Input Expression" })

require("telescope").load_extension("dap")
vim.keymap.set('n', '<Space>tdc', "<cmd>Telescope dap commands<cr>", { desc = "Telescope DAP: Commands" })
vim.keymap.set('n', '<Space>tdg', "<cmd>Telescope dap configurations<cr>", { desc = "Telescope DAP: Configurations" })
vim.keymap.set('n', '<Space>tdb', "<cmd>Telescope dap list_breakpoints<cr>", { desc = "Telescope DAP: Breakpoints" })
vim.keymap.set('n', '<Space>tdv', "<cmd>Telescope dap variables<cr>", { desc = "Telescope DAP: Variables" })
vim.keymap.set('n', '<Space>tdf', "<cmd>Telescope dap frames<cr>", { desc = "Telescope DAP: Frames" })

-- Symbols
vim.fn.sign_define("DapBreakpoint", { text = "ß", texthl = "Breakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "ς", texthl = "ConditionalBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "ඞ", texthl = "Error" })

--vim.g.rustaceanvim = function()
--	local cfg = require('rustaceanvim.config')
--	return {
--		dap = {
--			adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
--		},
--	}
--end


require("nvim-dap-virtual-text").setup {
	enabled = true,

	-- DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, DapVirtualTextForceRefresh
	enabled_commands = false,

	-- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
	highlight_changed_variables = true,
	highlight_new_as_changed = true,

	-- prefix virtual text with comment string
	commented = false,

	show_stop_reason = true,
}
--

-- Lua
dap.configurations.lua = {
	{
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
		host = function()
			return "127.0.0.1"
		end,
		port = function()
			-- local val = tonumber(vim.fn.input('Port: '))
			-- assert(val, "Please provide a port number")
			local val = 54231
			return val
		end,
	},
}
--

-- Golang
--  https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.go = function(callback, _)
	local stdout = vim.loop.new_pipe(false)
	local handle, pid_or_err
	local port = 38697

	handle, pid_or_err = vim.loop.spawn("dlv", {
		stdio = { nil, stdout },
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}, function(code)
		stdout:close()
		handle:close()

		print("[delve] Exit Code:", code)
	end)

	assert(handle, "Error running dlv: " .. tostring(pid_or_err))

	stdout:read_start(function(err, chunk)
		assert(not err, err)

		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
				print("[delve]", chunk)
			end)
		end
	end)

	-- wait for delve to start
	vim.defer_fn(function()
		callback { type = "server", host = "127.0.0.1", port = port }
	end, 100)
end

dap.configurations.go = {
	{
		type = "go",
		name = "Debug",
		request = "launch",
		program = "${file}",
		showLog = true,
	},
	{
		name = "Test Current File",
		type = "go",
		request = "launch",
		showLog = true,
		mode = "test",
		program = ".",
		dlvToolPath = vim.fn.exepath "dlv",
	},
	{
		type = "go",
		name = "Run lsif-clang indexer",
		request = "launch",
		showLog = true,
		program = ".",
		args = {
			"--indexer",
			"lsif-clang compile_commands.json",
			"--dir",
			vim.fn.expand "~/sourcegraph/lsif-clang/functionaltest",
			"--debug",
		},
		dlvToolPath = vim.fn.exepath "dlv",
	},
}
dap_go.setup()
--should be done in attach and using which-key
--vim.keymap.set('n', '<localleader>t', dap_go.debug_test)
--

dap.configurations.rust = {
	{
		type = "lldb",
		name = "Debug",
		request = "launch",
		program = "${workspaceFolder}/target/debug/${workspaceFolderBasename}",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
		runInTerminal = false,
		showDisassembly = "never",
	}
}

-- Python
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Build api",
		program = "${file}",
		args = { "--target", "api" },
		console = "integratedTerminal",
	},
	{
		type = "python",
		request = "launch",
		name = "lsif",
		program = "src/lsif/__main__.py",
		args = {},
		console = "integratedTerminal",
	},
}
dap_python.setup("python", {
	console = "externalTerminal",
	include_configs = true,
})

dap.adapters.lldb = {
	type = "executable",
	command = "/usr/bin/codelldb",
	name = "lldb",
}
--

-- Ui
dapui.setup {
	icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
	controls = {
		icons = {
			pause = '⏸',
			play = '▶',
			step_into = '⏎',
			step_over = '⏭',
			step_out = '⏮',
			step_back = 'b',
			run_last = '▶▶',
			terminate = '⏹',
			disconnect = '⏏',
		},
	},
	mappings = {
		expand = "<CR>",
		open = "o",
		remove = "d",
		repl = "r",
		toggle = "t",
		edit = "e",
	},
	sidebar = {
		elements = {
			"scopes",
			"scopes",
			"watches",
		},
		width = 40,
		position = "left",
	},
}
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
--dap.listeners.before.event_terminated['dapui_config'] = dapui.close
--dap.listeners.before.event_exited['dapui_config'] = dapui.close
--
