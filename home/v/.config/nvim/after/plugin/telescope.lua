local builtin = require('telescope.builtin')
-- "s" for "search". Doesn't work, so adding it manually to each mapping
vim.g.maplocalleader = "<Space>s"

K('n', '<Space>f', builtin.find_files, { desc = "telescope: project files" })
K('n', "<C-f>",
	"<cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top<CR>",
	{ desc = "telescope: <C-f> remake" })

-- -- standard mappings
K('n', '<Space>sg', builtin.git_files, { desc = "telescope: git files" })
K('n', "<Space>sf", builtin.live_grep, { desc = "telescope: live grep" })
K('n', "<Space>sp", "<cmd>Telescope persisted<cr>", { desc = "telescope: persisted: sessions" })
K('n', '<Space>sm', builtin.keymaps, { desc = "telescope: keymaps" })
K({ 'n', 'v' }, '<Space>ss', builtin.grep_string, { desc = "telescope: grep visual selection or word under cursor" })
K('n', '<Space>st', function()
	FindTodo()
	require('telescope.builtin').quickfix({ wrap_results = true, fname_width = 999 })
end, { desc = "telescope: project's TODOs" })

--

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

--TODO!: one in telescope
