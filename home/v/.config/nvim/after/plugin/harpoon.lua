--local mark = require("harpoon.mark")
--local ui = require("harpoon.ui")
---- "," kinda looks like a harpoon
--vim.g.maplocalleader = ","
--
--K("n", "<localleader>add", mark.add_file)
--K("n", "<localleader>ui", ui.toggle_quick_menu)
--
--K("", "<localleader>s", function() ui.nav_file(1) end, { desc = "harpoon: 1" })
--K("", "<localleader>r", function() ui.nav_file(2) end, { desc = "harpoon: 2" })
--K("", "<localleader>n", function() ui.nav_file(3) end, { desc = "harpoon: 3" })
--K("", "<localleader>t", function() ui.nav_file(4) end, { desc = "harpoon: 4" })
--
--K("", "<space><localleader>s", function()
--	vim.cmd("tabe .")
--	ui.nav_file(1)
--end, { desc = "harpoon: 1 + tabe" })
--K("", "<space><localleader>r", function()
--	vim.cmd("tabe .")
--	ui.nav_file(2)
--end, { desc = "harpoon: 2 + tabe" })
--K("", "<space><localleader>n", function()
--	vim.cmd("tabe .")
--	ui.nav_file(3)
--end, { desc = "harpoon: 3 + tabe" })
--K("", "<space><localleader>t", function()
--	vim.cmd("tabe .")
--	ui.nav_file(4)
--end, { desc = "harpoon: 4 + tabe" })
