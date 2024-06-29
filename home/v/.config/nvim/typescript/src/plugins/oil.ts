vim.cmd.highlight("OilFile", "ctermfg=15")

function echoerr(message) {
    if (message) {
        vim.api.nvim_echo([[message, "Error"]], false, {})
    }
}

export const oil = {
    1: "jake-stewart/oil.nvim",
    dir: "~/clones/oil.nvim",
    config: () => {
        const oil = lua.require("oil")

        oil.save = (opts, callback) => {
            opts = opts || {}
            if (!callback) {
                callback = (err) => {
                    if (err && err != "Canceled") {
                        echoerr(err)
                    }
                }
            }
            const mutator = lua.require("oil.mutator");
            mutator.try_write_changes(opts.confirm, (message) => {
                if (message) {
                    echoerr(message)
                }
                else {
                    callback()
                }
            })
        }

        oil.setup({
            skip_confirm_for_simple_edits: true,
            skip_confirm_for_complex_edits: true,
            use_default_keymaps: false,
            prompt_save_on_select_new_entry: true,
            keymaps: {
                ["<CR>"]: () => {
                    let expected = vim.fn.getline(".");
                    const spaceIdx = expected.indexOf(" ");
                    if (spaceIdx != -1) {
                        expected = expected.substring(spaceIdx + 1)
                    }
                    const slashIdx = expected.indexOf("/")
                    if (slashIdx != -1) {
                        expected = expected.substring(0, slashIdx)
                    }
                    oil.select()
                },
                ["<C-p>"]: "actions.preview",
                ["<C-c>"]: "actions.close",
                ["<C-l>"]: "actions.refresh",
                ["<BS>"]: "actions.parent",
                ["_"]: "actions.open_cwd",
                ["`"]: "actions.cd",
                ["~"]: "actions.tcd",
                ["gx"]: "actions.open_external",
                ["g."]: "actions.toggle_hidden",
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern: "oil",
            callback: () => {
                vim.defer_fn(() => {
                    vim.cmd.syn("match", "DiffAdd", "/\\v(^\\/[0-9]* )@!<.*/")
                }, 100)
            }
        })
        vim.keymap.set("n", "<BS>", "<CMD>Oil<CR>")
    }
}
