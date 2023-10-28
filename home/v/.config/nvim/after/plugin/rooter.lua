--- https://github.com/notjedi/nvim-rooter.lua
require('nvim-rooter').setup {
	rooter_patterns = { '.git', '.hg', '.svn', '=src', 'run.sh', '^help_scripts', '^s' },
	trigger_patterns = { '*' },
	manual = false,
	fallback_to_parent = false,
}
--
---- https://github.com/ahmedkhalf/project.nvim
--require("nvim-tree").setup({
--	sync_root_with_cwd = true,
--	respect_buf_cwd = true,
--	update_focused_file = {
--		enable = true,
--		update_root = true
--	},
--})
