local builtin = require('telescope.builtin')

require("which-key").register({
	f = { builtin.find_files, "search files" },
	g = { builtin.live_grep, "live grep" },
	s = {
		name = "Telescope",
		s = { builtin.grep_string, "grep visual selection or word under cursor", mode = { "n", "v" } },
		m = { builtin.keymaps, "keymaps" },
		g = { builtin.git_files, "git files" },
		p = { "<cmd>Telescope persisted<cr>", "persisted: sessions" },
		b = { builtin.buffers, "find buffers" },
		h = { builtin.help_tags, "neovim documentation" },
		t = { function()
			FindTodo()
			require('telescope.builtin').quickfix({ wrap_results = true, fname_width = 999 })
		end, "Project's TODOs" },
	},
}, { prefix = "<space>" })
K("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top<CR>",
	{ desc = "Ctrl+f remake" })


-- -- open new tab, then...
K('n', '<Space>tf', "<cmd>tabe .<cr><cmd>Telescope find_files<cr>", { desc = "telescope + new tab: project files" })
K('n', "<Space>ts", "<cmd>tabe .<cr><cmd>Telescope live_grep<cr>", { desc = "telescope + new tab: live grep" })
K('n', '<Space>tg', "<cmd>tabe .<cr><cmd>Telescope git_files<cr>", { desc = "telescope + new tab: git files" })
--

require('telescope').load_extension('media_files')
require("telescope").setup {
	extensions = {
		media_files = {
			filetypes = { "png", "webp", "jpg", "jpeg" },
			find_cmd = "rg"
		},
	},
}
--
