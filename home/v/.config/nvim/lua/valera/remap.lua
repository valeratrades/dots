-- Notes for all mappings:
-- 1) never use ':lua', instead use '<cmd>lua', for ':lua' forces us to normal mode.
local k = vim.keymap.set

vim.g.mapleader = " "
k("n", "<space>pv", vim.cmd.Ex)

-- -- "htns" Remaps and the Consequences
-- Basic Movement
k("", "h", "h")
k("", "t", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
k("", "n", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
k("", "s", "l")
k("", "j", "<nop>")
k("", "k", "<nop>")
k("", "l", "<nop>")

-- Jumps
k("", "T", "<C-d>zz")
k("", "N", "<C-u>zz")
k("", "H", "gg")
k("", "S", "G")

-- Quickfix and Location List
-- Defined in (`cmp.lua')
--k("n", "<C-t>", "<cmd>cnext<cr>zz")
--k("n", "<C-n>", "<cmd>cprev<cr>zz")
k("n", "<space>t", "<cmd>lnext<cr>zz")
k("n", "<space>n", "<cmd>lprev<cr>zz")

-- Jump back, jump forward and tag-list back
k("", "<A-h>", "<C-o>")
k("i", "<A-h>", "<esc><C-o>")
k("", "<A-H>", "<C-t>")
k("i", "<A-H>", "<esc><C-t>")
k("", "<A-s>", "<C-i>")
k("i", "<A-s>", "<esc><C-o>")

-- Move line
k("v", "<A-t>", ":m '>+1<cr>gv=gv", { noremap = true })
k("v", "<A-n>", ":m '<-2<cr>gv=gv", { noremap = true })
k("n", "<A-t>", "V:m '>+1<cr>gv=gv", { noremap = true })
k("n", "<A-n>", "V:m '>-2<cr>gv=gv", { noremap = true })
k("i", "<A-t>", "<esc>V:m '>+1<cr>gv=gv", { noremap = true })
k("i", "<A-n>", "<esc>V:m '>-2<cr>gv=gv", { noremap = true })

-- Windows
k('n', '<C-w>h', '<C-W>h', { noremap = true })
k('n', '<C-w>t', '<C-W>j', { noremap = true })
k('n', '<C-w>n', '<C-W>k', { noremap = true })
k('n', '<C-w>s', '<C-W>l', { noremap = true })
k('n', '<C-w>S', '<C-W>s', { noremap = true })
k('n', '<C-w><C-t>', '<C-W>j', { noremap = true })
k('n', '<C-w><C-h>', '<C-W>h', { noremap = true })
k('n', '<C-w><C-n>', '<C-W>k', { noremap = true })
k('n', '<C-w><C-s>', '<C-W>l', { noremap = true })
k('n', '<C-w><C-S>', '<C-W>s', { noremap = true })


-- Consequences
k("n", "j", "nzzzv")
k("n", "k", "Nzzzv")
--
-- --


-- Windows
k("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
k("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
k("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
k("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
--

-- Toggle Options
-- local leader doesn't work, so doing manually. Otherwise it'd be "<space> u"
k("n", "<space>uf", function() Util.format.toggle() end, { desc = "toggle: auto format (global)" })
k("n", "<space>us", function() Util.toggle("spell") end, { desc = "toggle: Spelling" })
--

-- Terminal Mappings
-- Is this the thing that kills my esc? (doesn't seem so)
k("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
k("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
k("t", "<C-t>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
k("t", "<C-n>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
k("t", "<C-s>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
k("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
k("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
--

-- Tabs
k("", "<A-,>", "gT")
k("", "<A-.>", "gt")
k("", "<A-p>", "g<Tab>")
k("", "<A-y>", "<cmd>tablast<cr>")
for i = 1, 9 do
	vim.api.nvim_set_keymap('', '<A-' .. i .. '>', ':tabn ' .. i .. '<cr>', { noremap = true, silent = true })
end
k("i", "<A-,>", "<esc>gT")
k("i", "<A-.>", "<esc>gt")
k("i", "<A-p>", "<esc>g<Tab>")
k("i", "<A-y>", "<esc><cmd>tablast<cr>")
for i = 1, 9 do
	vim.api.nvim_set_keymap('i', '<esc><A-' .. i .. '>', ':tabn ' .. i .. '<cr>', { noremap = true, silent = true })
end
--

-- -- Standards and the Consequences
k("", "<C-j>", "\"+y")
k("", "<C-q>", "\"+ygv\"_d")

-- For some reason this just doesn't work!
k("i", "<C-del>", "X<esc>ce") -- n mappings for <del> below rely on this
k("v", "<bs>", "d")
k("n", "<bs>", "i<bs>")
k("n", "<C-bs>", "i<C-bs>", { noremap = false })
k("n", "<del>", "i<del>")
k("n", "<C-del>", "i<C-del>", { noremap = false })
--test this thing is-it/actually() working?

k('', '<C-a>', 'ggVG', { noremap = true, silent = true })

k('', '<C-z>', '<cmd>undo<cr>', { desc = 'standarts: undo' })
k('i', '<C-z>', '<cmd>undo<cr>', { desc = 'standarts: undo' })

-- Consequences
k('', '<C-S-a>', '<C-a>', { noremap = true, silent = true })
--
-- --

-- FIX
-- Gitui
local function start_gitui()
	local handle = io.popen("git rev-parse --show-toplevel")
	local result = handle:read("*a")
	handle:close()
	result = result:gsub("%s+", "")
	if result ~= "" then
		vim.cmd("term gitui -d " .. result)
	else
		print("Not inside a git repository.")
	end
end
k("n", "<space>gg", [[<Cmd>lua start_gitui()<cr>]], { noremap = true, silent = true })
--

k("i", "<A-w>", "<esc>:w!<cr>")
k("", "<A-w>", "<esc>:w!<cr>")
k("", "<A-q>", ":q!<cr>")
k("i", "<A-q>", "<esc>:q!<cr>")
k("", "<A-a>", ":qa!<cr>")
k("i", "<A-a>", "<esc>:qa!<cr>")

--TODO at some point make this systemwide somehow
k("i", "<A-o>", "<esc>o")
k("i", "<A-O>", "<esc>O")

k("", ";", ":")
k("", ":", "<nop>")
-- Apparently some of these are taken for something else. (Should I then remap those other things?)
--k("v", "i", "<esc>i")
--k("v", "a", "<esc>a")
--k("v", "I", "<esc>I")
--k("v", "A", "<esc>A")
--k("v", "o", "<esc>o")
--k("v", "O", "<esc>O")


k("n", "J", "mzJ`z")
-- I was very excited to map this to <cr> and <S-CR> as in normal Ctrl-F search, but nvim can't detect modifiers on Enter.


k("n", "<space>y", "\"+y")
k("v", "<space>y", "\"+y")
k("n", "<space>Y", "\"+Y")
k("x", "<space>p", "\"_dP")

k("n", "<space>d", "\"_d")
k("v", "<space>d", "\"_d")

k("n", "<C-F>", "<cmd>silent !tmux neww tmux-sessionizer<cr>")

k("n", ",ra", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

local function toggle_diagnostics()
	local state = vim.diagnostic.is_disabled()
	if state then
		vim.diagnostic.enable()
	else
		vim.diagnostic.disable()
	end
end

k("", "<C-d>", toggle_diagnostics)
k("i", "<C-d>", toggle_diagnostics)

k('n', '<space>clr', 'vi""8di\\033[31m<esc>"8pa\\033[0m<Esc>', { desc = "add red escapecode" })
k('n', '<space>clb', 'vi""8di\\033[34m<esc>"8pa\\033[0m<Esc>', { desc = "add blue escapecode" })
k('n', '<space>clg', 'vi""8di\\033[32m<esc>"8pa\\033[0m<Esc>', { desc = "add green escapecode" })



k('', '<space>.', '<cmd>tabe .<cr>')


k('n', 'U', '<C-r>', { desc = "helix: redo" })
k('n', '<C-r>', '<nop>')
k('n', '<tab>', 'i<tab>')
