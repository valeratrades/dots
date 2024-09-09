-- Currently is specifically made for [rust](<https://github.com/rust-lang/rust>) and [tracing](<https://crates.io/crates/tracing>).

local M = {}

--- Parses a log line, assuming `[whitespaces] in [destination] with [contents]` format.
--- @param log_line string The log line to parse.
--- @return string destination The destination part of the log line.
--- @return string contents The contents part of the log line.
function parse_log_line(log_line)
	local destination = log_line:match("in%s+([%w_:]+)%s+with")
	local contents = log_line:match("with%s+(.+)")
	return destination, contents
end

--- Makes a popup with the given text. Sets the filetype to `markdown` to allow for syntax highlighting.
function ShowMarkdownPopup(text)
	local buf = vim.api.nvim_create_buf(false, true)
	local lines = {}

	for line in string.gmatch(text, "([^\n]+)") do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = 0
	for _, line in ipairs(lines) do
		if #line > width then
			width = #line
		end
	end
	width = math.max(width + 4, 30) -- Add padding and ensure a minimum width

	local height = #lines + 2      -- Add padding to height

	local row = (vim.o.lines - height) / 2
	local col = (vim.o.columns - width) / 2

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
		title = " Popup ",
		title_pos = "center",
		zindex = 50
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { nowait = true, noremap = true, silent = true })

	vim.api.nvim_set_option_value('cursorline', true, { win = win })

	-- Set the buffer filetype to Markdown to allow for syntax highlighting
	vim.api.nvim_set_option_value('filetype', 'markdown', { scope = 'local', buf = buf })

	-- Get the actual width and height of the window
	local actual_width = vim.api.nvim_win_get_width(win)
	local actual_height = vim.api.nvim_win_get_height(win)

	print("Actual Width: " .. actual_width)
	print("Actual Height: " .. actual_height)
end

function PopupPrettyfied()
	local current_line = vim.api.nvim_get_current_line()
	local _, contents = parse_log_line(current_line)
	local prettify_cmd = "cat <<EOF | prettify_log -\n" .. contents .. "\nEOF"
	local prettified = vim.fn.system(prettify_cmd)
	local as_rust_block = "```rs\n" .. prettified .. "```"
	ShowMarkdownPopup(as_rust_block)
end

vim.keymap.set("n", "<Space>tp", function() PopupPrettyfied() end, { desc = "Popup with prettified log line" })


function CopyDestination()
	local current_line = vim.api.nvim_get_current_line()
	local destination, _ = parse_log_line(current_line)
	vim.fn.setreg("+", destination)
end

vim.keymap.set("n", "<Space>ty", function() CopyDestination() end, { desc = "+y log-line's destination" })
