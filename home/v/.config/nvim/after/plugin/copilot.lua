vim.g.copilot_filetypes = {
	markdown = false,
	gitcommit = false,
	typst = false,
	latex = false,
	json = false,
	text = false,
}

K('i', '<Right>', 'copilot#Accept("<Up>")', {
	expr = true,
	replace_keycodes = false,
	silent = true,
})
vim.g.copilot_no_tab_map = true -- currently doesn't work, hence the next line
K("i", "<Tab>", "<Tab>")

K("i", "<Down>", "<Plug>(copilot-accept-word)")
K("i", "<Left>", "<Plug>(copilot-accept-line)")
K("i", "<M-\\>", "<Plug>(copilot-suggest)")
