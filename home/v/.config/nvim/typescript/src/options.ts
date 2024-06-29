vim.g.mapleader = " "

// PERFORMANCE
vim.o.ttimeoutlen = 1
vim.o.lazyredraw = true
vim.o.updatetime = 300

// SPLITS
vim.o.splitright = true
vim.o.splitbelow = true

// MOUSE
vim.o.mouse = "a"
vim.o.mousescroll = "ver:2,hor:0"
vim.o.mousemodel = "extend"

// TITLE
vim.o.title = true
vim.o.titlestring = "%t%( %M%)"

// UI
vim.o.guicursor = "a:block,i:ver1,r:hor1"
vim.o.laststatus = 0
vim.o.cursorline = true
vim.o.shortmess = vim.o.shortmess + "I"
vim.o.ruler = true
vim.o.listchars = vim.o.listchars + ",eol:$"
vim.o.number = true
vim.o.signcolumn = "number"
vim.o.showmode = false
vim.o.belloff = "all"
// vim.o.guioptions="c"
vim.g.netrw_banner = 0;
vim.diagnostic.config({
  virtual_text: false,
  // if line has say both a .HINT and .WARNING, the "worst" will be shown (as a sign on the left)
    severity_sort: true,
})

// LONG LINES
vim.o.wrap = false
// vim.o.cpoptions = vim.o.cpoptions + "n"
vim.o.breakindent = true
vim.o.breakindentopt = "shift:8,sbr"
vim.o.linebreak = true
vim.o.showbreak = ""
vim.o.sidescroll = 0
// vim.o.sidescrolloff = 10

// SEARCH
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.magic = false

// TAB
vim.o.tabstop = 8
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 1
vim.o.smarttab = true

// UNDO
vim.o.undofile = true;

vim.o.undodir = lua.os.getenv("HOME") + "/.cache/nvim/undo";

vim.o.undolevels = 5000
if (!vim.fn.isdirectory(vim.fn.expand(vim.o.undodir))) {
    vim.fn.mkdir(vim.fn.expand(vim.o.undodir), "p", 770)
}

// OTHER
vim.o.hidden = true
vim.o.swapfile = false
vim.o.jumpoptions = "stack"
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.nrformats = "bin,hex,unsigned"
vim.o.virtualedit = "block"
vim.o.foldmethod = "marker"
vim.o.path = "**"
vim.o.showmatch = true
vim.o.joinspaces = false
