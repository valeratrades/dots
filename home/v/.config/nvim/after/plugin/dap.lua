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

require("which-key").register({
	--["<F1>"] = { "<cmd>lua require('dap').step_back()<CR>", "Step Back" },
	["<F2>"] = { "<cmd>lua require('dap').step_into()<CR>", "Step Into" },
	["<F3>"] = { "<cmd>lua require('dap').step_over()<CR>", "Step Over" },
	["<F4>"] = { "<cmd>lua require('dap').step_out()<CR>", "Step Out" },
	["<F5>"] = { "<cmd>lua require('dap').continue()<CR>", "Start/Continue" },
	["<F6>"] = { "<cmd>lua require('dapui').toggle()<CR>", "Toggle Windows" },
	["<Space>d"] = {
		name = "DAP",
		d = { "<cmd>lua RustLsp debug", "Start" }, --HACK: definitely not the right place to specify a dap implementation
		b = { "<cmd>lua require('dap').toggle_breakpoint()<CR>", "Toggle Breakpoint" },
		B = { "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", "Input Breakpoint" },
		i = { "<cmd>lua require('dap').repl.open()<CR>", "Repl Open" },
		r = { "<cmd>lua require('dapui').open()({reset = true})<CR>", "Restore Windows Layout" },
		e = { "<cmd>lua require('dapui').eval()<CR>", "Eval" },
		E = { "<cmd>lua require('dapui').eval(vim.fn.input('[DAP] Expression > '))<CR>", "Input Expression" },
	},
})

require("telescope").load_extension("dap")
require("which-key").register({
	name = "Telescope: DAP",
	c = { "<cmd>Telescope dap commands<cr>", "commands" },
	g = { "<cmd>Telescope dap configurations<cr>", "configurations" },
	b = { "<cmd>Telescope dap list_breakpoints<cr>", "breakpoints" },
	v = { "<cmd>Telescope dap variables<cr>", "variables" },
	f = { "<cmd>Telescope dap frames<cr>", "frames" },
}, { prefix = "<Space>td" })

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
