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
local register = require("which-key").register
register({
	d = { gs.diffthis, "Diff this" },
	u = { gs.undo_stage_hunk, "Undo stage hunk" },
	S = { gs.stage_buffer, "Stage buffer" },
	b = { gs.blame_line, "Blame line" },
	p = { gs.preview_hunk_inline, "Preview hunk" },
}, { prefix = "<leader>g" })
register({
	U = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk" },
	s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
}, { mode = { "n", "v" }, prefix = "<space>g" })
