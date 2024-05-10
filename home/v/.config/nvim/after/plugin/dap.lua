local dap = require('dap')
local dapui = require('dapui')
local dap_go = require('dap-go')
local dap_python = require('dap-python')
dap_python.test_runner = "pytest"

local k = vim.keymap.set
vim.g.maplocalleader = "<Space>d"

--TODO: add: showDisassembly = "never" to dap.config.rust

--require('mason-nvim-dap').setup {
--	automatic_setup = true,
--
--	handlers = {},
--
--	ensure_installed = {
--		'delve',
--	}
--}

-- set up in a way so breakpoint can be placed in any file. But need a separately running language debug server to make them do something.
-- HACK localleader doesn't work, so rawdogging it.
k('n', '<F1>', dap.step_back, { desc = 'dap: Step Back' })
k('n', '<F2>', dap.step_into, { desc = 'dap: Step Into' })
k('n', '<F3>', dap.step_over, { desc = 'dap: Step Over' })
k('n', '<F4>', dap.step_out, { desc = 'dap: Step Out' })
k('n', '<F5>', dap.continue, { desc = 'dap: Start/Continue'})
k('n', '<Space>db', dap.toggle_breakpoint, { desc = 'dap: Toggle Breakpoint' })
k('n', '<Space>dB', function()
	dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'dap: Input Breakpoint' })
k('n', '<Space>dr', dap.repl.open, { desc = "dap: Repl Open" })
k('n', "<Space>de", dapui.eval, { desc = "dapui: Eval" })
k('n', "<Space>dE", function()
  dapui.eval(vim.fn.input "[DAP] Expression > ")
end, { desc = 'dapui: Input Expression' })


-- Symbols
vim.fn.sign_define("DapBreakpoint", { text = "ß", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "ς", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "ඞ", texthl = "Error" })

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
vim.keymap.set('n', '<localleader>t', dap_go.debug_test)
--

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
local dap_python = require "dap-python"
dap_python.setup("python", {
  console = "externalTerminal",
  include_configs = true,
})

dap.adapters.lldb = {
  type = "executable",
  command = "/usr/bin/lldb-vscode-11",
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
vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close
--
