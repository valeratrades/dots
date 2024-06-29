export const treeSJ = {
    1: "Wansmer/treesj",
    keys: [
        [ "gJ", vim.cmd.TSJJoin ],
        [ "gS", vim.cmd.TSJSplit ],
    ],
    config: () => {
        lua.require("treesj").setup({
            use_default_keymaps: false,
            check_syntax_error: true,
            max_join_length: Infinity,
            cursor_behavior: "start",
            notify: false,
            dot_repeat: true,
        })
    },
}
