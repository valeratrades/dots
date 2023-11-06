local endwise = require('nvim-autopairs.ts-rule').endwise
local npairs = require('nvim-autopairs')

npairs.setup()
npairs.add_rules({
	-- 'then$' is a lua regex
	-- 'end' is a match pair
	-- 'lua' is a filetype
	-- 'if_statement' is a treesitter name. set it = nil to skip check with treesitter
	endwise('then$', 'end', 'lua', 'if_statement')
})
