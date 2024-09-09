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

function PopupPrettified()
	local current_line = vim.api.nvim_get_current_line()
	local _, contents = parse_log_line(current_line)
	local prettify_cmd = "echo " .. contents .. " | prettify_log -"
	local prettified = vim.fn.system(prettify_cmd)
	print(prettified)
end

vim.keymap.set("n", "<Space>tp", function() PopupPrettified() end, { desc = "Popup with prettified log line" })


function CopyDestination()
	local current_line = vim.api.nvim_get_current_line()
	local destination, _ = parse_log_line(current_line)
	vim.fn.setreg("+", destination)
end

vim.keymap.set("n", "<Space>ty", function() CopyDestination() end, { desc = "+y log-line's destination" })
