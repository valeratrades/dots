--- https://github.com/notjedi/nvim-rooter.lua
require('nvim-rooter').setup {
	rooter_patterns = { '.git', '.hg', '.svn', '=src', 'run.sh', '^help_scripts', '^s' },
	trigger_patterns = { '*' },
	manual = false,
	fallback_to_parent = false,
}
