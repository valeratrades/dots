local builtin = require('telescope.builtin')

require("which-key").register({
	f = { builtin.find_files, "search files" },
	z = { builtin.live_grep, "live grep" },
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

-- Default mappings reference {{{
--<C-n>/<Down>	Next item
--<C-p>/<Up>	Previous item
--j/k	Next/previous (in normal mode)
--<cr>	Confirm selection
--<C-q>	Confirm selection and open quickfix window
--<C-x>	Go to file selection as a split
--<C-v>	Go to file selection as a vsplit
--<C-t>	Go to a file in a new tab
--<C-u>	Scroll up in preview window
--<C-d>	Scroll down in preview window
--<C-/>/?	Show picker mappings (in insert & normal mode, respectively)
--<C-c>	Close telescope
--<Esc>	Close telescope (in normal mode)
-- }}}
