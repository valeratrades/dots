function Dark()
	vim.cmd.colorscheme("default")
	vim.cmd.colorscheme("rose-pine")
	--vim.cmd.colorscheme("tokyonight")

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

function Light()
	--vim.cmd.colorscheme("github_light_high_contrast")
	vim.cmd.colorscheme("github_light")
	--vim.cmd.colorscheme("catppuccin-latte")
end

function SetSystemTheme()
	local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
	local result = handle:read("*a")
	handle:close()

	if string.match(string.lower(result), "dark") then
		Dark()
	else
		Light()
	end
end

SetSystemTheme()
