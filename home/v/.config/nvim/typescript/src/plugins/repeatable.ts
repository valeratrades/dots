function input(prompt, onChange) {
    const auId = vim.api.nvim_create_autocmd("CmdlineChanged", {
        pattern: "*",
        callback: () => onChange(vim.fn.getcmdline())
    })
    try {
        const result = vim.fn.input({
            prompt: prompt,
            cancelreturn: false,
        })
        return [true, result]
    }
    catch (error) {
        return [false, undefined]
    }
    finally {
        vim.api.nvim_del_autocmd(auId)
    }
}

export const repeatable = {
    1: "jake-stewart/repeatable.nvim",
    config: () => {
        const repeatable = lua.require("repeatable")

        // paste while leaving cursor in same position
        // vim.keymap.set({"n", "v"}, "mp", repeatable("P`["), {expr = true})

        // change while leaving cursor in same position
        let buffer: string | undefined;

        const pasteChange = repeatable((o) => {
            if (buffer == undefined) {
                buffer = ""
                input("", (txt) => {buffer = txt})
            }
            const esc = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
            if (o.motion == "char") {
                return "`[cv`]" + buffer + esc + "`["
            }
            else {
                return "'[c']" + buffer + esc + "'["
            }
        }, {op: true})

        // vim.keymap.set({"n"}, "mc", function()
        //     buffer = nil
        //     return pasteChange()
        // end, {expr = true})

        // insert while leaving cursor in same position
        const pasteInsert = repeatable(() => {
            if (buffer == undefined) {
                buffer = ""
                input("", (txt) => {buffer = txt})
            }
            const esc = vim.api.nvim_replace_termcodes(
                "<esc>", true, true, true)
            return 'i' + buffer + esc + "`[";
        })

        // vim.keymap.set({"n"}, "mi", function()
        //     buffer = nil
        //     return pasteInsert()
        // end, {expr = true})
    }
}
