vim.g.copilot_filetypes = {
	markdown = false,
	gitcommit = false,
	typst = false,
	latex = false,
	json = false,
	text = false,
}

K('i', '<Left>', 'copilot#Accept("<CR>")', {
	expr = true,
	replace_keycodes = false,
	silent = true,
})
vim.g.copilot_no_tab_map = true -- currently doesn't work, hence the mapping below
K("i", "<Tab>", "<Tab>")

K("i", "<Right>", "<Plug>(copilot-accept-word)")
K("i", "<Down>", "<Plug>(copilot-accept-line)")
