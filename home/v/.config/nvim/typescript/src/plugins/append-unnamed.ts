export const appendUnnamed = {
    1: "jake-stewart/append-unnamed.nvim",
    dependencies: [ "jake-stewart/repeatable.nvim" ],
    dir: "~/clones/append-unnamed.nvim",
    config: () => lua.require("append-unnamed").setup({
        extra: false,
        keys: ["t", "d"]
    })
}

