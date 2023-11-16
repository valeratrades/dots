-- Notes for all mappings:
-- 1) never use ':lua', instead use '<cmd>lua', for ':lua' forces us to normal mode.

vim.g.mapleader = " "
--K("n", "<space>e", vim.cmd.Ex)
--K("", "<space>e", "<cmd>Oil<cr>", { desc = "Oil equivalent to vim.cmd.Ex" })
K({ "n", "v" }, "-", "<cmd>Oil<cr>")

K("i", "<Esc>", "<Esc><Esc>", { desc = "Allow quick exit from cmp suggestions by doubling <Esc>" })

-- -- -- "hjkl" -> "htns" Remaps and the Consequences
-- Basic Movement
function MultiplySidewaysMovements(movement)
	if vim.v.count == 0 then
		F(movement)
	else
		local multiplied_count = vim.v.count * 10
		F(multiplied_count .. movement)
	end
end

K("", "j", "<nop>")
K("", "k", "<nop>")
K("", "l", "<nop>")
K("", "h", "<cmd>lua MultiplySidewaysMovements('h')<cr>", { silent = true })
K("", "t", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
K("", "n", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
K("", "s", "<cmd>lua MultiplySidewaysMovements('l')<cr>", { silent = true })

-- Jumps
K("", "T", "<C-d>zz")
K("", "N", "<C-u>zz")
K("", "H", "<C-b>zz")
K("", "S", "<C-f>zz")

-- Jump back, jump forward and tag-list back
K({ "", "i" }, "<C-t>", "<nop>", { desc = "have this on Alt+h" })
K("", "<A-h>", "<C-o>")
K("i", "<A-h>", "<esc><C-o>")
K("", "<A-H>", "<C-t>")
K("i", "<A-H>", "<esc><C-t>")
K("", "<C-t>", "<nop>")
K("", "<A-s>", "<C-i>")
K("i", "<A-s>", "<esc><C-o>")

-- Move line
K("v", "<A-t>", ":m '>+1<cr>gv=gv")
K("v", "<A-n>", ":m '<-2<cr>gv=gv")
K("n", "<A-t>", "V:m '>+1<cr>gv=gv")
K("n", "<A-n>", "V:m '>-2<cr>gv=gv")
K("i", "<A-t>", "<esc>V:m '>+1<cr>gv=gv")
K("i", "<A-n>", "<esc>V:m '>-2<cr>gv=gv")

-- Windows
K('n', '<C-w>h', '<C-W>h')
K('n', '<C-w>t', '<C-W>j')
K('n', '<C-w>n', '<C-W>k')
K('n', '<C-w>s', '<C-W>l')

-- Other
K("i", "<C-v>", "<C-k>", { desc = "Dvorak things" })

-- -- Consequences
K("n", "j", "nzzzv")
K("n", "k", "Nzzzv")
--
-- --


-- Windows
K("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "windows: decrease width" })
K("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "windows: decrease height" })
K("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "windows: increase height" })
K("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "windows: increase width" })
K("n", "<C-w><C-h>", "<C-w><C-s><C-w>w", { desc = "windows: new horizontal and focus" })
K("n", "<C-w><C-v>", "<C-w><C-v><C-w>w", { desc = "windows: new vertical and focus" })
K("n", "<C-w>v", "<C-w>v<C-w>w", { desc = "windows: new vertical and focus" })
K("n", "<C-w>f", "<cmd>tab split<cr>", { desc = "windows: focus current by `:tab split`" })
--

-- Toggle Options
-- local leader doesn't work, so doing manually. Otherwise it'd be "<space> u"
--K("n", "<space>uf", function() Util.format.toggle() end, { desc = "toggle: auto format (global)" })
--K("n", "<space>us", function() Util.toggle("spell") end, { desc = "toggle: Spelling" })
--

-- Just use tmux
-- Terminal Mappings
-- Is this the thing that kills my esc? (doesn't seem so)
--K("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
--K("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
--K("t", "<C-t>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
--K("t", "<C-n>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
--K("t", "<C-s>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
--K("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
--K("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
--

-- Tabs
K({ "i", "" }, "<A-,>", "<esc>gT")
K({ "i", "" }, "<A-.>", "<esc>gt")
K({ "i", "" }, "<A-p>", "<esc>g<Tab>")
K({ "i", "" }, "<A-y>", "<esc><cmd>tablast<cr>")
for i = 1, 9 do
	K("", '<A-' .. i .. '>', '<esc><cmd>tabn ' .. i .. '<cr>', { noremap = true, silent = true })
end
for i = 1, 9 do
	K("i", '<A-' .. i .. '>', '<esc><cmd>tabn ' .. i .. '<cr>', { noremap = true, silent = true })
end
K({ "i", "" }, "<A-c>", "<esc><cmd>tabmove -<cr>")
K({ "i", "" }, "<A-r>", "<esc><cmd>tabmove +<cr>")
K({ "i", "" }, "<A-f>", "<esc><cmd>tabmove 0<cr>")
K({ "i", "" }, "<A-g>", "<esc><cmd>tabmove $<cr>") -- for some reason doesn't work.

K("n", "gt", "<nop>")
--

-- -- Standards and the Consequences
K("", "<C-j>", "\"+y")
K("", "<C-q>", "\"+ygv\"_d")

K("i", "<C-del>", "X<esc>ce") -- n mappings for <del> below rely on this
K("v", "<bs>", "d")
K("n", "<bs>", "i<bs>")
K("n", "<del>", "i<del>")
K("n", "<C-del>", "a<C-del>", { remap = true })

K('', '<C-a>', 'ggVG')
-- Consequences
K('', '<C-z>', '<C-a>')
--
-- --

-- FIX
-- Gitui
--local function start_gitui()
--	local handle = io.popen("git rev-parse --show-toplevel")
--	local result = handle:read("*a")
--	handle:close()
--	result = result:gsub("%s+", "")
--	if result ~= "" then
--		vim.cmd("term gitui -d " .. result)
--	else
--		print("Not inside a git repository.")
--	end
--end
--K("n", "<space>gg", [[<Cmd>lua start_gitui()<cr>]], { noremap = true, silent = true })
--

local function saveSessionIfOpen(cmd, hook_before)
	hook_before = hook_before or ""
	return function()
		if vim.g.persisting then
			vim.cmd("SessionSave")
		end
		Ft('<esc>', 'm')
		if hook_before ~= "" then
			vim.cmd("wa!")
		end
		vim.cmd(cmd)
	end
end

K({ "", "i" }, "<A-q>", "<cmd>q!<cr>")
K({ "", "i" }, "<A-a>", saveSessionIfOpen('qa!', 'wa!'), { desc = "save everything and exit" })
K({ "", "i" }, "<A-;>", '<cmd>qa!<cr>')
K({ "", "i" }, "<A-w>", saveSessionIfOpen('w!'))

--TODO at some point make this systemwide somehow
K("i", "<A-o>", "<esc>o")
K("i", "<A-O>", "<esc>O")

K("", ";", ":")
K("", ":", "<nop>")

K("n", "J", "mzJ`z")

K("n", "<space>y", "\"+y")
K("v", "<space>y", "\"+y")
K("n", "<space>Y", "\"+Y")
K("x", "<space>p", "\"_dP")

K("n", "<space>d", "\"_d")
K("v", "<space>d", "\"_d")

--K("n", "<C-F>", "<cmd>silent !tmux neww tmux-sessionizer<cr>")

K("n", "<space>ra", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- select the pasted
K("n", "gp", function()
	return "`[" .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. "`]"
end, { expr = true })

K("n", "H", "H^")
K("n", "M", "M^")
K("n", "L", "L^")

-- Tries to correct spelling of the word under the cursor
K("n", "z1", "mx1z=`x", { silent = true })
K("n", "z2", "umx2z=`x", { silent = true })
K("n", "z3", "umx3z=`x", { silent = true })
K("n", "z4", "umx4z=`x", { silent = true })
K("n", "z5", "umx5z=`x", { silent = true })
K("n", "z6", "umx6z=`x", { silent = true })
K("n", "z7", "umx7z=`x", { silent = true })
K("n", "z8", "umx8z=`x", { silent = true })
K("n", "z9", "umx9z=`x", { silent = true })

K('n', '<space>clr', 'vi""8di\\033[31m<esc>"8pa\\033[0m<Esc>', { desc = "add red escapecode" })
K('n', '<space>clb', 'vi""8di\\033[34m<esc>"8pa\\033[0m<Esc>', { desc = "add blue escapecode" })
K('n', '<space>clg', 'vi""8di\\033[32m<esc>"8pa\\033[0m<Esc>', { desc = "add green escapecode" })
-- and now color rust, because they decided to have different escape codes...
K('n', '<space>clrr', 'vi""8di\\x1b[31m<esc>"8pa\\x1b[0m<Esc>', { desc = "add red escapecode" })
K('n', '<space>clrb', 'vi""8di\\x1b[34m<esc>"8pa\\x1b[0m<Esc>', { desc = "add blue escapecode" })
K('n', '<space>clrg', 'vi""8di\\x1b[32m<esc>"8pa\\x1b[0m<Esc>', { desc = "add green escapecode" })


K('', '<space>.', '<cmd>tabe .<cr>')

-- zero width space digraph
vim.cmd.digraph("zs " .. 0x200b)

K('n', 'U', '<C-r>', { noremap = true, desc = "helix: redo" })
K('n', '<C-r>', '<nop>') -- later changed to `lsp refresh` in lsp.lua
K('n', '<tab>', 'i<tab>')

-- trying out:
K("i", "<c-r><c-r>", "<c-r>\"");
K("n", "<space>`", "~hi");
K("v", "<space>`", "~gvI");

local function getPopups()
	return vim.fn.filter(vim.api.nvim_tabpage_list_wins(0),
		function(_, e) return vim.api.nvim_win_get_config(e).zindex end)
end
local function killPopups()
	vim.fn.map(getPopups(), function(_, e)
		vim.api.nvim_win_close(e, false)
	end)
end
-- clear search highlight & kill popups
K("n", "<esc>", function()
	vim.cmd.noh()
	killPopups()
end)
