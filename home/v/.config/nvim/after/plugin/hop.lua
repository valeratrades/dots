local hop = require("hop")
local directions = require("hop.hint").HintDirection
local function _f()
	hop.hint_char1({
		direction = directions.AFTER_CURSOR,
		current_line_only = true,
	})
end

local function _F()
	hop.hint_char1({
		direction = directions.BEFORE_CURSOR,
		current_line_only = true,
	})
end

local function _t()
	hop.hint_char1({
		direction = directions.AFTER_CURSOR,
		current_line_only = true,
		hint_offset = -1,
	})
end

local function _T()
	hop.hint_char1({
		direction = directions.BEFORE_CURSOR,
		current_line_only = true,
		hint_offset = 1,
	})
end

local function next_word()
	hop.hint_words({
		direction = directions.AFTER_CURSOR,
	})
end

local function prev_word()
	hop.hint_words({
		direction = directions.BEFORE_CURSOR,
	})
end

local register = require("which-key").register
register({
	f = { _f, "Hop forward to char" },
	F = { _F, "Hop back to char" },
	l = { _t, "Hop forward before char" },
	L = { _T, "Hop back before char" },
	["<leader>/"] = { next_word, "Hop forward to word" },
	["<leader>?"] = { prev_word, "Hop back to word" },
})

hop.setup()
