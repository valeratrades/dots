vim.cmd [[
  au BufWinLeave * silent! mkview
  au BufWinEnter * silent! loadview
  autocmd FileType * :set formatoptions-=ro
	autocmd VimEnter,WinNew,BufWinEnter * lua vim.fn.chdir(vim.env.PWD)
	autocmd BufRead,BufNewFile *.md set conceallevel=3
	autocmd BufRead,BufNewFile *.txt set conceallevel=3
]]

-- lean doesn't allow tabs
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "lean" },
	callback = function()
		vim.opt_local.expandtab = true
	end,
})

-- Use 'q' to quit from common plugins
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "lir" },
	callback = function()
		vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]])
	end,
})

-- Set wrap and spell in markdown and gitcommit
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "gitcommit", "markdown", "typst" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Just don't see a point, given I'm always visually selecting first (which is the right practice)
---- Highlight Yanked Text
--vim.api.nvim_create_autocmd({ "TextYankPost" }, {
--	callback = function()
--		vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
--	end,
--})

-- Disable undo file for .env files
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*.env" },
	callback = function()
		vim.opt_local.undofile = false
	end,
})
