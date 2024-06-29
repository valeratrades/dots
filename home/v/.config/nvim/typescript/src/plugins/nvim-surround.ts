export const nvimSurround = {
    1: "kylechui/nvim-surround",
    version: "*",
    keys: [
        "ys",
        "cs",
        "ds",
        {1: "ys", mode: "v"},
    ],
    config: () => lua.require("nvim-surround").setup({
        keymaps: {
            insert: false,
            insert_line: false,
            normal: "ys",
            normal_cur: false,
            normal_line: false,
            normal_cur_line: false,
            visual: "ys",
            visual_line: false,
            delete: "ds",
            change: "cs",
        }
    })
}
