local api = require('Comment.api')
local config = {
	padding = false,
	sticky = true,
	ignore = nil,
	toggler = { line = 'gcc', block = 'gbc' }, -- can't turn it off. So just a note to follow the good practice of doing 'Vgc' and 'Vgb' instead.
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

-- s for surround
K("v", "gcs", "<esc>`><cmd>lua OutlineCodeSection()<cr>", { desc = "outline semantic code section" })


-- -- Draw a line thingie
function DrawABigBeautifulLine(symbol)
	local cs = string.sub(vim.bo.commentstring, 1, -4)
	local prefix = (#cs == 1 and cs .. symbol or cs)
	local line = string.rep(symbol, 77)
	vim.api.nvim_feedkeys(prefix .. line, 'n', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>0', true, true, true), 'n', false)
end

K('n', 'gc-i', "i<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "comment: draw a '-' line here" })
K('n', 'gc=i', "i<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "comment: draw a '=' line here" })
K('n', 'gc-o', "o<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "comment: draw a '-' line below" })
K('n', 'gc-O', "O<cmd>lua DrawABigBeautifulLine('-')<cr>", { desc = "comment: draw a '-' line above" })
K('n', 'gc=o', "o<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "comment: draw a '=' line below" })
K('n', 'gc=O', "O<cmd>lua DrawABigBeautifulLine('=')<cr>", { desc = "comment: draw a '=' line above" })
--


local function removeEndOfLineComment()
	local cs = string.sub(vim.bo.commentstring, 1, -4)
	local save_cursor = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$?" .. " " .. cs .. "<cr>", true, true, true), 'n', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("vg_d", true, true, true), 'n', false)
	vim.defer_fn(function() vim.cmd([[s/\s\+$//e]]) end, 1)
	vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, save_cursor) end, 2)
	vim.defer_fn(function() vim.cmd.noh() end, 3)
end
-- Note that if no `<space>{comment_string}` found on the current line, it will go searching through the rest of the file with `?`
K('n', 'gcr', function() removeEndOfLineComment() end, { desc = "comment: remove end-of-line comment" })

local function debugComment(action)
	local cs = string.sub(vim.bo.commentstring, 1, -4)
	if action == 'add' then
		local save_cursor = vim.api.nvim_win_get_cursor(0)
		Ft('A ' .. cs .. 'dbg' .. '<esc>')
		vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, save_cursor) end, 1)
	elseif action == 'remove' then
		vim.cmd("g/" .. " " .. cs .. "dbg$/d")
		vim.cmd.noh()
	end
end
K('n', 'gcda', function() debugComment('add') end, { desc = "comment: add dbg comment" })
K('n', 'gcdr', function() debugComment('remove') end, { desc = "comment: remove all debug lines" })

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
