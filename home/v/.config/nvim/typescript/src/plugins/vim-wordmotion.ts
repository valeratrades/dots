export const wordMotion = {
    1: 'chaoren/vim-wordmotion',
    init: () => {
        vim.g.wordmotion_prefix = "<leader>";
    },
    keys: [
        { 1: "<leader>w", mode: ["n", "x", "o"] },
        { 1: "<leader>b", mode: ["n", "x", "o"] },
        { 1: "<leader>e", mode: ["n", "x", "o"] },
    ],
}
