-- "<space>sp" to search for session with Telescope
require("persisted").setup({
	save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"),
	silent = true,
	autosave = false, -- what would you know, doesn't work properly. Currently manually adding `SessionSave` on my quit shortcuts
	autoload = false,
	follow_cwd = true,
	allowed_dirs = nil,
	ignored_dirs = { "tmp", "s", ".config" },
	telescope = {
		reset_prompt_after_deletion = true,
	},
})
K('n', '<space>sl', '<cmd>SessionLoad<cr>', { desc = "session: load" })
