K = vim.keymap.set

function F(s)
	vim.api.nvim_feedkeys(s, 'n', false)
end

function Ft(s)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, true, true), 'n', false)
end

function Cs()
	return string.sub(vim.bo.commentstring, 1, -4)
end

-- Note that this takes over 1ms defer
function PersistCursor(fn, ...)
	local args = ...
	local save_cursor = vim.api.nvim_win_get_cursor(0)
	local result = fn(args)
	vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, save_cursor) end, 1)
	return result
end

-- function DebugPrintTable(tbl)
-- 	local str = "{"
-- 	for k, v in pairs(tbl) do
-- 		if type(v) == "table" then
-- 			str = str .. "[" .. k .. "]=" .. DebugPrintTable(v) .. ","
-- 		else
-- 			str = str .. "[" .. k .. "]=" .. tostring(v) .. ","
-- 		end
-- 	end
-- 	local table = str .. "}"
-- 	print(table)
-- end
