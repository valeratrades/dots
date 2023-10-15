local persistence = require('persistence')

vim.g.maplocalleader = "<Space>q"

persistence.setup{
	event = "BufReadPre",
	opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
	--HACK local leader doesn't work, so improvising.
	keys = {
		{ "<Space>qs", persistence.load, desc = "Restore Session" },
		{ "<Space>ql", function() persistence.load({ last = true }) end, desc = "Restore Last Session" },
		{ "<Space>qd", persistence.stop, desc = "Don't Save Current Session" },
	},
}

