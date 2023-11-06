local lsp_status = require('lsp-status')
local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " }, -- E and W
	always_visible = true,
}
local function hide_in_width()
	return vim.fn.winwidth(0) > 80
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end
local spaces = function()
	return ".." .. vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
end
local location = {
	"location",
	padding = 0,
}
local diff = {
	"diff",
	symbols = { added = " ", modified = " ", removed = " " },
	cond = hide_in_width,
	source = diff_source,
}


require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		}
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { { "b:gitsigns_head", icon = "" } },
		lualine_c = { diagnostics },
		lualine_x = { diff, spaces, 'encoding', 'filename' },
		lualine_y = { 'progress' },
		lualine_z = { location }
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { 'filename' },
		lualine_x = { location },
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {}
}
