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

require("which-key").register({
	["<leader>g"] = {
		name = "Git",
		-- this assumes we correctly did `vim.fn.chdir(vim.env.PWD)` in an autocmd earlier. Otherwise this will often try to execute commands one level in the filetree above.
		g = { "<cmd>!git add -A && git commit -m '_' && git push<cr><cr>", "just push", silent = true },
		p = { "<cmd>!git pull<cr><cr>", "pull", silent = true },
		r = { "<cmd>!git reset --hard<cr><cr>", "reset --hard", silent = true },

		d = { gs.diffthis, "diff this" },
		u = { gs.undo_stage_hunk, "undo stage hunk" },
		S = { gs.stage_buffer, "stage buffer" },
		b = { gs.blame_line, "blame line" },
		v = { gs.preview_hunk_inline, "preview hunk" },
		U = { "<cmd>Gitsigns reset_hunk<cr>", "reset hunk" },
		s = { "<cmd>Gitsigns stage_hunk<cr>", "stage hunk" },

		f = { "<cmd>Telescope git_status<cr>", "find modifications" },
	},
})

K('n', 'gt', function()
	if vim.wo.diff then return 'gt' end
	vim.schedule(function() gs.next_hunk() end)
	return '<Ignore>'
end, { expr = true })

K('n', 'gn', function()
	if vim.wo.diff then return 'gn' end
	vim.schedule(function() gs.prev_hunk() end)
	return '<Ignore>'
end, { expr = true })
