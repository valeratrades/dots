vim.api.nvim_create_augroup("NvimCustomAutocommands", {clear: true})

// remove auto commenting
vim.api.nvim_create_autocmd("BufEnter", {
    pattern: "*",
    group: "NvimCustomAutocommands",
    callback: (e) => {
        let fo = vim.bo.formatoptions;
        [fo] = lua.string.gsub(fo, "c", "");
        [fo] = lua.string.gsub(fo, "r", "");
        [fo] = lua.string.gsub(fo, "o", "");
        vim.bo.formatoptions = fo;
    }
})

// restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern: "*",
    group: "NvimCustomAutocommands",
    callback: () => {
        if (vim.fn.line("'\"") > 0 && vim.fn.line("'\"") <= vim.fn.line("$")) {
            vim.cmd.normal("g'\"")
            vim.fn.feedkeys("zz")
        }
    }
})

// comment string
vim.api.nvim_create_autocmd("FileType", {
    pattern: "c,cpp,cs,java,php",
    group: "NvimCustomAutocommands",
    callback: () => {
        vim.cmd.setlocal("commentstring=//\\ %s")
    }
})

// json quote
vim.api.nvim_create_autocmd("FileType", {
    pattern: "json",
    group: "NvimCustomAutocommands",
    callback: () => {
        vim.cmd.hi("jsonQuote", "ctermfg=243")
    }
})

// tablescript
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern: "*.tbl",
    group: "NvimCustomAutocommands",
    callback: () => {
        vim.cmd.setf("tablescript")
    }
})
vim.api.nvim_create_autocmd("BufRead", {
    pattern: "*.tbl",
    group: "NvimCustomAutocommands",
    callback: () => {
        vim.cmd.setf("tablescript")
    }
})
