export const firestore = {
    1: "delphinus/vim-firestore",
    ft: "firestore",
    init: () => {
        vim.api.nvim_create_autocmd("BufEnter", {
            pattern: "*.rules",
            callback: () => {
                vim.o.filetype = "firestore"
            }
        })
    }
}
