local gs = require("gitsigns")
gs.setup({
	signs = {
		add          = { text = '│' },
		change       = { text = '│' },
		delete       = { text = '_' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	max_file_length = 40000,
	numhl = false,
})

vim.keymap.set('n', '<Space>gg', "<cmd>!git add -A && git commit -m '_' && git push<cr><cr>",
	{ desc = "Git: just push", silent = true })
vim.keymap.set('n', '<Space>gp', "<cmd>!git pull<cr><cr>", { desc = "Git: pull", silent = true })
vim.keymap.set('n', '<Space>gr', "<cmd>!git reset --hard<cr><cr>", { desc = "Git: reset --hard", silent = true })
-- this assumes we correctly did `vim.fn.chdir(vim.env.PWD)` in an autocmd earlier. Otherwise this will often try to execute commands one level in the filetree above.
vim.keymap.set('n', '<Space>gd', gs.diffthis, { desc = "Git: diff this" })
vim.keymap.set('n', '<Space>gu', gs.undo_stage_hunk, { desc = "Git: undo stage hunk" })
vim.keymap.set('n', '<Space>gS', gs.stage_buffer, { desc = "Git: stage buffer" })
vim.keymap.set('n', '<Space>gb', gs.blame_line, { desc = "Git: blame line" })
vim.keymap.set('n', '<Space>gv', gs.preview_hunk_inline, { desc = "Git: preview hunk" })
vim.keymap.set('n', '<Space>gU', "<cmd>Gitsigns reset_hunk<cr>", { desc = "Git: reset hunk" })
vim.keymap.set('n', '<Space>gs', "<cmd>Gitsigns stage_hunk<cr>", { desc = "Git: stage hunk" })
vim.keymap.set('n', '<Space>gf', "<cmd>Telescope git_status<cr>", { desc = "Git: find modifications" })

K('n', 'gr', function()
	if vim.wo.diff then return 'gr' end
	vim.schedule(function() gs.next_hunk() end)
	return '<Ignore>'
end, { expr = true })

K('n', 'gn', function()
	if vim.wo.diff then return 'gn' end
	vim.schedule(function() gs.prev_hunk() end)
	return '<Ignore>'
end, { expr = true })
