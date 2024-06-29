export const diagnosticJump = {
    1: "jake-stewart/diagnostic-jump.nvim",
    keys: [
        [",", () => lua.require("diagnostic-jump").prev()],
        ["<c-m>", () => lua.require("diagnostic-jump").next()]
    ],
    config: () => lua.require("diagnostic-jump").setup({
        float: {
            format: (diagnostic: vim.diagnostic.Diagnostic) => 
                diagnostic.message.split("\n")[0],
            prefix: "",
            suffix: "",
            focusable: false,
            header: ""
        }
    })
}
