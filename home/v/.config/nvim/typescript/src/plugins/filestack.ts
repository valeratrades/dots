export const filestack = {
    1: "jake-stewart/filestack.nvim",
    keys: ["<c-o>", "<c-i>", "<m-o>", "<m-i>"],
    config: () => lua.require("filestack").setup(),
}
