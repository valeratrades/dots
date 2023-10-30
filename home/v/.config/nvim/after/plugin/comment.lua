local api = require('Comment.api')
local config = {
	padding = false,
	sticky = true,
	ignore = nil,
	toggler = { line = 'gcc', block = 'gbc' },
	opleader = { line = 'gc', block = 'gb' },
	extra = { above = 'gcO', below = 'gco', eol = 'gcA' },
	mappings = { basic = true, extra = true },
	pre_hook = nil,
	post_hook = nil,
}


require('Comment').setup {
	config
}


function OutlineCodeSection()
	local cs = string.sub(vim.bo.commentstring, 1, -4)
	vim.api.nvim_feedkeys('o' .. cs, 'n', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>`<', true, true, true), 'n', false)
	vim.api.nvim_feedkeys('O' .. cs .. ' ' .. cs .. ' ', 'n', false)
end

vim.keymap.set("v", "ks", "<esc>`><cmd>lua OutlineCodeSection()<cr>", { desc = "outline semantic code section" })


function DrawABigBeautifulLine(symbol)
	local cs = string.sub(vim.bo.commentstring, 1, -4)
	local prefix = (#cs == 1 and cs .. symbol or cs)
	local line = string.rep(symbol, 77)
	vim.api.nvim_feedkeys(prefix .. line, 'n', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>0', true, true, true), 'n', false)
end

vim.keymap.set('n', '<space>-i', "i<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "draw a '-' line" })
vim.keymap.set('n', '<space>=i', "i<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "draw a '=' line" })
vim.keymap.set('n', '<space>-o', "o<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "draw a '-' line" })
vim.keymap.set('n', '<space>-O', "O<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "draw a '-' line" })
vim.keymap.set('n', '<space>=o', "o<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "draw a '=' line" })
vim.keymap.set('n', '<space>=O', "O<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "draw a '=' line" })

--# Linewise
--
--`gcw` - Toggle from the current cursor position to the next word
--`gc$` - Toggle from the current cursor position to the end of line
--`gc}` - Toggle until the next blank line
--`gc5j` - Toggle 5 lines after the current cursor position
--`gc8k` - Toggle 8 lines before the current cursor position
--`gcip` - Toggle inside of paragraph
--`gca}` - Toggle around curly brackets
--
--# Blockwise
--
--`gb2}` - Toggle until the 2 next blank line
--`gbaf` - Toggle comment around a function (w/ LSP/treesitter support)
--`gbac` - Toggle comment around a class (w/ LSP/treesitter support)

--
--{
--    ---Add a space b/w comment and the line
--    padding = true,
--    ---Whether the cursor should stay at its position
--    sticky = true,
--    ---Lines to be ignored while (un)comment
--    ignore = nil,
--    ---LHS of toggle mappings in NORMAL mode
--    toggler = {
--        ---Line-comment toggle keymap
--        line = 'gcc',
--        ---Block-comment toggle keymap
--        block = 'gbc',
--    },
--    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
--    opleader = {
--        ---Line-comment keymap
--        line = 'gc',
--        ---Block-comment keymap
--        block = 'gb',
--    },
--    ---LHS of extra mappings
--    extra = {
--        ---Add comment on the line above
--        above = 'gcO',
--        ---Add comment on the line below
--        below = 'gco',
--        ---Add comment at the end of line
--        eol = 'gcA',
--    },
--    ---Enable keybindings
--    ---NOTE: If given `false` then the plugin won't create any mappings
--    mappings = {
--        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
--        basic = true,
--        ---Extra mapping; `gco`, `gcO`, `gcA`
--        extra = true,
--    },
--    ---Function to call before (un)comment
--    pre_hook = nil,
--    ---Function to call after (un)comment
--    post_hook = nil,
--}
--
--
--  Default:
--`gco` - Insert comment to the next line and enters INSERT mode
--`gcO` - Insert comment to the previous line and enters INSERT mode
--`gcA` - Insert comment to end of the current line and enters INSERT mode
--
--# Linewise
--
--`gcw` - Toggle from the current cursor position to the next word
--`gc$` - Toggle from the current cursor position to the end of line
--`gc}` - Toggle until the next blank line
--`gc5j` - Toggle 5 lines after the current cursor position
--`gc8k` - Toggle 8 lines before the current cursor position
--`gcip` - Toggle inside of paragraph
--
--`gca}` - Toggle around curly brackets
--
--# Blockwise
--
--`gb2}` - Toggle until the 2 next blank line
--`gbaf` - Toggle comment around a function (w/ LSP/treesitter support)
--`gbac` - Toggle comment around a class (w/ LSP/treesitter support)
