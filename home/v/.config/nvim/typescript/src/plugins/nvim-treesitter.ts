export const nvimTreesitter = {
    1: 'nvim-treesitter/nvim-treesitter',
    ft: [ "c", "lua", "php", "cpp", "javascript", "typescript", "cs", "python", "typescriptreact" ],
    config: () => lua.require('nvim-treesitter.configs').setup({
        ensure_installed: [
            "c",
            "c_sharp",
            "lua",
            "php",
            "cpp",
            "javascript",
            "typescript",
        ],
        sync_install: false,
        auto_install: true,
        indent: {
            enable: true,
            disable: [
                "python",
            ],
        },
        highlight: {
            enable: true,
            additional_vim_regex_highlighting: false,
            disable: [
                "vimdoc", "vim", "css", "markdown"
            ],
        },
    })
}
