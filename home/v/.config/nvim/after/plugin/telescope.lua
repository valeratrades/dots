local builtin = require('telescope.builtin')
-- "s" for "search"
vim.g.maplocalleader = "<Space>s"

-- Special mappings without the "s" prefix
vim.keymap.set('n', '<Space>f', builtin.find_files, { desc="telescope: project files" })
vim.keymap.set('n', "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top<CR>", { desc="telescope: <C-f> remake" })
vim.keymap.set('n', '<Space>map', builtin.keymaps, { desc="telescope: keymaps" })
--

-- following are meant to be prefixed by <localleader>, but it broke for some reason, so munaul for now.
vim.keymap.set('n', '<Space>sg', builtin.git_files, { desc="telescope: git files" })
vim.keymap.set('n', '<Space>ss' ,function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc="telescope: grep string" })
vim.keymap.set('n', '<Space>sd', builtin.diagnostics, { desc="telescope: lsp diagnostics" })
vim.keymap.set('n', '<Space>sr', builtin.lsp_references, { desc="telescope: lsp references" })
vim.keymap.set('n', "<Space>sf", "<cmd>Telescope live_grep<CR>", { desc="telescope: live grep" })

-- Telescope File Browser
--TODO: setup
local fb_actions = require "telescope".extensions.file_browser.actions
require("telescope").setup {
  extensions = {
    file_browser = {
      theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = false,
      mappings = {
        ["i"] = {
          -- your custom insert mode mappings
        },
        ["n"] = {
					["<C-h>"] = fb_actions.goto_home_dir,
					--["t"] = "j",
					--["n"] = "k",
					--["s"] = "l",
        },
      },
    },
  },
}
require("telescope").load_extension "file_browser"
--
