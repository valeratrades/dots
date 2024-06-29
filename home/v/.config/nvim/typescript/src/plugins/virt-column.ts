function toggleColorColumn() {
    vim.o.colorcolumn = vim.o.colorcolumn == "" ? "80" : ""
}

export const virtColumn = {
    1: "lukas-reineke/virt-column.nvim",
    keys: [
        { 1: "<space>8", 2: toggleColorColumn, mode: "n" }
    ],
    config: () => {
        lua.require("virt-column").setup()
    }
}
