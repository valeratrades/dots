vim.keymap.set('n', '<Space>re', function()
	vim.cmd.RustLsp('expandMacro')
end, { desc = "Rustacean: Expand Macro" })
