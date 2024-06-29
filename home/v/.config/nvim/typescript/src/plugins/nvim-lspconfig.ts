function references() {
    const line = vim.fn.line(".");
    vim.lsp.buf.references(undefined, {
        on_list: (qflist: {items: any[]}) => {
            vim.fn.setqflist(qflist.items.filter(qf => qf.lnum != line));
            vim.cmd.copen();
        }
    })
}

export const nvimLspconfig = {
    1: 'neovim/nvim-lspconfig',
    dependencies: [ "hrsh7th/nvim-cmp", "folke/neodev.nvim" ],
    ft: [
        "c",
        "cpp",
        "java",
        "python",
        "typescript",
        "typescriptreact",
        "javascript",
        // "cs",
        "php",
        "blade",
        "lua",
    ],
    config: () => {
        lua.require("neodev").setup({})

        const capabilities = lua.require('cmp_nvim_lsp').default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = false

        const on_attach = (client, bufnr, opts) => {
            client.server_capabilities.semanticTokensProvider = undefined;
            const bufopts = { remap: false, silent: true, buffer: bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', 'gr', references, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<c-r>', vim.cmd.LspRestart, bufopts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

            vim.keymap.set('n', 'g<up>', () => {
                vim.diagnostic.open_float({ focusable: false })
            }, bufopts)
            if (opts.commentstring) {
                vim.cmd.setlocal("commentstring=" + opts.commentstring)
            }
        }

        const setup = (server, opts) => {
            lua.require('lspconfig')[server].setup({
                capabilities: capabilities,
                inlay_hints: { enabled: false },
                on_attach: (client, bufnr) => {
                    on_attach(client, bufnr, opts)
                },
                init_options: {
                    preferences: {
                        disableSuggestions: true,
                    },
                },
                settings: {
                    Lua: {
                        diagnostics: { globals: [ 'vim' ] }
                    },
                }
            })
        }

        const cStyleComment = { commentstring: "//\\ %s" }
        setup("clangd", cStyleComment)
        setup("jdtls", cStyleComment)
        setup("tsserver", cStyleComment)
        setup("intelephense", cStyleComment)
        // setup("csharp_ls", cStyleComment)
        setup("lua_ls", {})
        setup("pyright", {})
    },
}
