-- note that ver{M}; M doesn't affect nothing. As well as blinking values. I can only turn things on and off here. The rest is controlled by alacritty.
local o = vim.opt
local k = vim.keymap.set

o.guicursor =
"n:blinkwait3000-blinkoff50-blinkon400-Cursor/lCursor,i:ver40-blinkwait3000-blinkoff300-blinkon150-Cursor/lCursor"

o.nu = true
o.relativenumber = true

o.tabstop = 2
o.softtabstop = 0
o.shiftwidth = 2
o.expandtab = false

o.smartindent = true
o.wrap = true

o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

vim.o.timeoutlen = 700
vim.o.ttimeoutlen = 2

o.termguicolors = true

o.scrolloff = 8
o.signcolumn = "yes"
o.isfname:append("@-@")

o.updatetime = 50

o.colorcolumn = "80"

o.title = true
o.titlestring = "nvim: %F"

vim.cmd [[
  au BufWinLeave * silent! mkview
  au BufWinEnter * silent! loadview
]]

vim.g.autoformat = true
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
o.showmode = false
o.winminwidth = 5

o.modifiable = true

-- Add undo break-points
k("i", ",", ",<c-g>u")
k("i", ".", ".<c-g>u")
k("i", ";", ";<c-g>u")
--
