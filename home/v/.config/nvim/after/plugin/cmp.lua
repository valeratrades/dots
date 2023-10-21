local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()
local _ = { behavior = cmp.SelectBehavior.Select } -- somehow forces cmp into the right behavior.
local cmp_action = require('lsp-zero').cmp_action()


vim.opt.completeopt = { "menu", "menuone", "noselect" }
cmp.setup({
	--timeout = cmp.config.performance.fetching_timeout({
	--	300
	--}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer', keyword_length = 5, option = { keyword_length = 5 } }, -- `option` is defined by the source itself, and currently is useless, as keyword_lenght is above 4. But keeping just in case.
	}),
	-- Show source name in completion menu.
	formatting = cmp_format,
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<Tab>'] = cmp_action.luasnip_supertab(),
		['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
		['<C-e>'] = cmp.mapping.abort(),                  -- if esc in insert mode is not instantenious, change this (my estimation is this thing takes about 40ms)
		['<CR>'] = cmp.mapping.confirm({ select = false }), -- `select = false` to only confirm explicitly selected items.

		['<C-t>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.scroll_docs(4)
			else
				vim.api.nvim_command('cprev')
				vim.api.nvim_command('normal zz')
			end
		end, {
			"i",
			"s",
		}),
		['<C-n>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.scroll_docs(-4)
			else
				vim.api.nvim_command('cprev')
				vim.api.nvim_command('normal zz')
			end
		end, {
			"i",
			"s",
		}),
	}),
})
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'git', keyword_length = 5 }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = 'buffer', keyword_length = 5, option = { keyword_length = 5 } },
	})
})
