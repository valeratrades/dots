local cmp = require('cmp')
local _ = { behavior = cmp.SelectBehavior.Select } -- makes cmp not force feed me completeions on 'Enter'
local cmp_action = require('lsp-zero').cmp_action()
local ts_utils = require('nvim-treesitter.ts_utils')
local lspkind = require('lspkind')

vim.opt.completeopt = { "menu", "menuone", "noselect" }
cmp.setup({
	sources = cmp.config.sources({
		{
			name = 'nvim_lsp',
			-- when inputting an argument, suggest only values with this in mind
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
		{ name = 'buffer',  keyword_length = 5 },
		{ name = 'cmdline', keyword_length = 3 },
		{ name = "crates" },
	}),
	formatting = {
		fields = { 'abbr', 'kind', 'menu' },
		format = lspkind.cmp_format({
			mode = 'symbol',
			preset = 'codicons', -- can be either 'default' (requires nerd-fonts font) or 'codicons' for codicon preset (requires vscode-codicons font)
			maxwidth = 50,
			ellipsis_char = '..', -- when exceeds maxwidth

			symbol_map = {
				Text = "",
				Module = "",
				File = "",
				Folder = "",
				Operator = "",
				Color = "",
				Snippet = "",
				Value = "",
				Constructor = "",
				Event = "",
				Constant = "'static",
				Unit = "{}",
				Method = "𝗠",
				Function = "𝗙",
				Field = "𝗳",
				Variable = "𝘃",
				Class = "𝗖",
				Enum = "𝗘",
				Keyword = "𝘄",
				Reference = "𝗿",
				EnumMember = "𝗲",
				Struct = "𝗦",
				TypeParameter = "𝗧",
				Property = "𝗽",
				Interface = "𝗶",
			},

			-- executes before the rest, to add on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			before = function(entry, item)
				local n = entry.source.name
				if n == 'nvim_lsp' then
					item.menu = 'LSP'
				elseif n == 'nvim_lua' then
					item.menu = 'nvim'
				elseif n == 'cmdline' then
					item.mune = ''
				elseif n == 'buffer' then
					item.mune = 'B'
				else
					--item.menu = string.format('[%s]', n)
					item.menu = n
				end
				return item
			end
		})
	},
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

		['<C-n>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.scroll_docs(4)
			end
		end, {
			"i",
			"s",
		}),
		['<C-t>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.scroll_docs(-4)
			end
		end, {
			"i",
			"s",
		}),
	},
})
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})
