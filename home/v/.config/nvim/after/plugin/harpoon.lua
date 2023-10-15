local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
-- "," kinda looks like a harpoon
vim.g.maplocalleader = ","

vim.keymap.set("n", "<localleader>add", mark.add_file)
vim.keymap.set("n", "<localleader>ui", ui.toggle_quick_menu)

vim.keymap.set("", "<localleader>h", function() ui.nav_file(1) end, { desc="harpoon: 1" })
vim.keymap.set("", "<localleader>t", function() ui.nav_file(2) end, { desc="harpoon: 2" })
vim.keymap.set("", "<localleader>n", function() ui.nav_file(3) end, { desc="harpoon: 3" })
vim.keymap.set("", "<localleader>s", function() ui.nav_file(4) end, { desc="harpoon: 4" })
