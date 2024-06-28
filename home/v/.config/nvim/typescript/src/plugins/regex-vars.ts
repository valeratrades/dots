export const regexVars = {
    1: "jake-stewart/regex-vars.nvim",
    dir: "~/clones/regex-vars.nvim",
    config: () => {
        const rv = lua.require("regex-vars")
        rv.setup({
            [rv.escape(":email:")]:
                "[a-z0-9_.+-]\\+@[a-z0-9-]\\+\\.[a-z0-9.-]\\+",
        })
    }
}
