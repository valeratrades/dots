export const normon = {
    1: "jake-stewart/normon.nvim",
    dir: "~/clones/normon.nvim",
    keys: [
        { 1: "<leader>n", mode: ["n", "v"] },
        { 1: "<leader>N", mode: ["n", "v"] },
        { 1: "<leader>q", mode: ["n", "v"] },
        { 1: "<leader>Q", mode: ["n", "v"] },
        { 1: "*", mode: ["n", "v"] },
        { 1: "#", mode: ["n", "v"] },
    ],
    config: () => {
        const normon = lua.require("normon")
        normon("<leader>n", "cgn")
        normon("<leader>N", "cgN")
        normon("<leader>q", "q")
        normon("<leader>Q", "q", { backward: true })
        normon("*", "n")
        normon("#", "n", { backward: true })

        vim.keymap.set("v", "g*", "*")
        vim.keymap.set("v", "g#", "#")
    }
}
