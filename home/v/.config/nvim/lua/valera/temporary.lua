---- README:
---- , for change
---- . for scrolling to the next
---- ' to prev
--
--
-- local path = os.getenv("HOME") .. "/s/training-data/line_checkpoint.txt"
--
-- function dump_line_number()
--   local line_number = vim.fn.line(".")
--   local file = io.open(path, "w")
--   file:write(tostring(line_number))
--   file:close()
-- end
--
-- function go_to_checkpoint()
--   local file = io.open(path, "r")
--   local line_number = file:read("*l")
--   file:close()
--   vim.api.nvim_command(":" .. line_number)
-- end
--
-- vim.api.nvim_set_keymap('n', "'", 'a<BS>0<Esc>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '.', '/\\"classification\\":\\s\\"\\+<CR>f"A<Esc>hi<cmd>lua dump_line_number()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', ",", 'k?\\"classification\\":\\s\\"\\+<CR>f"Ahi<cmd>lua dump_line_number()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', "p", ':lua go_to_checkpoint()<CR>A<Esc>', { noremap = true, silent = true })
--
--
----TODO: make a keybind to source this file from normal mode, and remove its mention from the local init.lua.

vim.api.nvim_create_user_command(
	'Ansi',
	function()
		vim.cmd('source ~/.local/share/nvim/lazy/AnsiEsc.vim/autoload/AnsiEsc.vim')
	end,
	{ desc = "Enable AnsiEsc for current buffer" }
)

-- #558817
