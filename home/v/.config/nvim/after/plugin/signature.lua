cfg = {
	debug = false,
	log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
	-- default is  ~/.cache/nvim/lsp_signature.log
	verbose = false,                                           -- show debug line number

	bind = true,                                               -- This is mandatory, otherwise border config won't get registered.
	-- If you want to hook lspsaga or other signature handler, pls set to false
	doc_lines = 10,                                            -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
	-- set to 0 if you DO NOT want any API comments be shown
	-- This setting only take effect in insert mode, it does not affect signature help in normal
	-- mode, 10 by default

	max_height = 12,
	max_width = 80,                       -- max_width of signature floating_window
	wrap = true,                          -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long

	floating_window = true,               -- show hint in a floating window, set to false for virtual text only mode

	floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
	-- will set to true when fully tested, set to false will use whichever side has more space
	-- this setting will be helpful if you do not want the PUM and floating win overlap

	floating_window_off_x = 1, -- adjust float windows x position.
	-- can be either a number or function
	floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
	-- can be either number or function, see examples

	hint_enable = true, -- virtual hint enable
	hint_prefix = "🐼 ",
	hint_scheme = "String",
	hint_inline = function() return false end, -- should the hint be inline(nvim 0.10 only)?  default false
	hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight

	always_trigger = false,                  -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

	extra_trigger_chars = {},                -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}

	padding = '',                            -- character to pad on left and right of signature can be ' ', or '|'  etc

	timer_interval = 200,                    -- default timer check interval set to lower value if you want to reduce latency

	select_signature_key = nil,              -- cycle to next signature, e.g. '<M-n>' function overloading
}

require 'lsp_signature'.setup(cfg)
