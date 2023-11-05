local cmp = require('cmp')
local _ = { behavior = cmp.SelectBehavior.Select } -- makes cmp not force feed me completeions on 'Enter'
local cmp_action = require('lsp-zero').cmp_action()
local ts_utils = require('nvim-treesitter.ts_utils')

vim.opt.completeopt = { "menu", "menuone", "noselect" }
cmp.setup({
	sources = cmp.config.sources({
		{
			name = 'nvim_lsp',
			entry_filter = function(entry, context)
				local kind = entry:get_kind()
				local node = ts_utils.get_node_at_cursor():type()
				--log(node)
				if node == "arguments" then
					if kind == 6 then -- `6` corresponds to variables
						return true
					else
						return false
					end
				end

				return true
			end,
		},
		{ name = 'luasnip' },
		{ name = 'buffer', keyword_length = 5 },
	}),
	-- Show source name in completion menu.
	formatting = require('lsp-zero').cmp_format(),
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = {
		['<Tab>'] = cmp_action.luasnip_supertab(),
		['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
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
	},
})
