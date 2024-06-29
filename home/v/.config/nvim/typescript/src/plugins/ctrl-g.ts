export const ctrlG = {
    1: "jake-stewart/ctrl-g.nvim",
    keys: ["<c-g>"],
    config: () => lua.require("ctrl-g").setup()
}
