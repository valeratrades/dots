-- Currently is specifically made for [rust](<https://github.com/rust-lang/rust>) and [tracing](<https://crates.io/crates/tracing>).
local utils = require("valera.utils")
local M = {}

--- Parses a log line, assuming `[whitespaces] in [destination] with [contents]` format.
--- @param log_line string The log line to parse.
--- @return string destination The destination part of the log line.
--- @return string contents The contents part of the log line.
local function parse_log_line(log_line)
	if log_line:match("in%s+([%w_:]+)%s+with") then
		local destination = log_line:match("in%s+([%w_:]+)%s+with")
		local contents = log_line:match("with%s+(.+)")
		return destination, contents
	elseif log_line:match("at%s+([%w_/]+%.rs:%d+)") then
		local destination = log_line:match("at%s+([%w_/]+%.rs:%d+)")
		return destination, nil
	else
		return nil, nil
	end
end

function M.PopupExpandedLog()
	local current_line = vim.api.nvim_get_current_line()
	local _, contents = parse_log_line(current_line)
	local prettify_cmd = "cat <<EOF | prettify_log -\n" .. contents .. "\nEOF"
	local prettified = vim.fn.system(prettify_cmd)
	local as_rust_block = "```rs\n" .. prettified .. "```"
	utils.ShowMarkdownPopup(as_rust_block)
end

vim.keymap.set("n", "<Space>tp", function() M.PopupExpandedLog() end, { desc = "Popup with prettified log line" })


function M.CopyDestination()
	local current_line = vim.api.nvim_get_current_line()
	local destination, _ = parse_log_line(current_line)
	vim.fn.setreg("+", destination)
end

vim.keymap.set("n", "<Space>ty", function() M.CopyDestination() end, { desc = "+y log-line's destination" })

return M
