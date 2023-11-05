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
		{ name = 'buffer', keyword_length = 5 },
	}),
	formatting = {
		fields = { 'abbr', 'kind', 'menu' },
		format = lspkind.cmp_format({
			mode = 'symbol_text', -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
			preset = 'codicons', -- can be either 'default' (requires nerd-fonts font) or 'codicons' for codicon preset (requires vscode-codicons font)
			--maxwidth = 50,
			ellipsis_char = '...', -- when exceeds maxwidth

			symbol_map = {
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "ﳑ",
				Value = "",
				Enum = "",
				Keyword = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Snippet = "",
				Color = "",
				Operator = "",
				TypeParameter = "",
			},

			-- executes before the rest, to add on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			before = function(entry, vim_item)
				return vim_item
			end
		})
		-- -- These are the defaults of lsp_zero
		--format = function(entry, item)
		--    local n = entry.source.name
		--    if n == 'nvim_lsp' then
		--      item.menu = '[LSP]'
		--    elseif n == 'nvim_lua'  then
		--      item.menu = '[nvim]'
		--    else
		--      item.menu = string.format('[%s]', n)
		--    end
		--    return item
		--  end,
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
