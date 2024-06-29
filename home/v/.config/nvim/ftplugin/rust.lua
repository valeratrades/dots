require('which-key').register({
	name = "Rustacean",
	e = { "<cmd>lua vim.cmd.RustLsp('expandMacro')<cr>", "Expand Macro" },
}, { prefix = "<Space>r" })
