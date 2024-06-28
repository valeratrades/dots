export const nvimBqf = {
    1: "kevinhwang91/nvim-bqf",
    ft: "qf",
    config: () => {
        vim.api.nvim_create_augroup("BqfCustomKeybinds", { clear: true })

        // remove auto commenting
        vim.api.nvim_create_autocmd("FileType", {
            pattern: "qf",
            group: "BqfCustomKeybinds",
            callback: () => vim.keymap.set('n', '<esc>', ":q<CR>",
                    { silent: true, buffer: true })
        })

        lua.require('bqf').setup({
            preview: {
                winblend: 0,
                show_title: true,
                win_height: 999,
                border_chars: [
                    '│', '│', '─', '─', '┌', '┐', '└', '┘', '█'
                ],
            },
            func_map: {
                open: "o",
                openc: "<CR>",
            },
        })
    }
}
