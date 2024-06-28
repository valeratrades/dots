function createPreHook() {
    return (ctx) => {
        const commentUtil = lua.require('comment.utils')
        const tsContextUtil = lua.require('ts_context_commentstring.utils')
        const tsContext = lua.require('ts_context_commentstring')

        const type = ctx.ctype == commentUtil.ctype.linewise
            ? '__default' : '__multiline';

        let location: number[] | undefined;

        if (ctx.ctype == commentUtil.ctype.blockwise) {
            location = [
                ctx.range.srow - 1,
                ctx.range.scol,
            ]
        }
        else if (ctx.cmotion == commentUtil.cmotion.v
            || ctx.cmotion == commentUtil.cmotion.V)
        {
            location = tsContextUtil.get_visual_start_location()
        }

        return tsContext.calculate_commentstring({
            key: type,
            location: location,
        })
    }
}

export const comment = {
    1: "https://github.com/jake-stewart/comment.nvim",
    dependencies: "JoosepAlviste/nvim-ts-context-commentstring",
    keys: [{ 1: "gc", mode: ["n", "v"] }],
    config: () => lua.require("comment").setup({
        pre_hook: createPreHook(),
    })
}
