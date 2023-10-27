require('nvim-rooter').setup {
	rooter_patterns = { '.git', '.hg', '.svn', '=src', 'run.sh' },
	trigger_patterns = { '*' },
	manual = false,
	fallback_to_parent = false,
}
