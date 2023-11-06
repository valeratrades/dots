local builtin = require('telescope.builtin')
vim.g.maplocalleader = "<Space>s"

K('n', '<Space>f', builtin.find_files, { desc = "telescope: project files" })
K('n', "<C-f>",
	"<cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top<CR>",
	{ desc = "telescope: <C-f> remake" })
K({ 'n', 'v' }, '<Space>ss', builtin.grep_string, { desc = "telescope: grep visual selection or word under cursor" })

require("which-key").register({
	s = {
		name = "Telescope",
		f = { builtin.live_grep, "Live grep" },
		m = { builtin.keymaps, "Keymaps" },
		g = { builtin.git_files, "Git files" },
		p = { "<cmd>Telescope persisted<cr>", "persisted: sessions" },
		b = { builtin.buffers, "Find buffers" },
		h = { builtin.help_tags, "Neovim documentation" },
		t = { function()
			FindTodo()
			require('telescope.builtin').quickfix({ wrap_results = true, fname_width = 999 })
		end, "Project's TODOs" },
	},
}, { prefix = "<space>" })


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
