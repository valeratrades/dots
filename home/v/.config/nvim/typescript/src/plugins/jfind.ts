const preview = "bat --color always --theme custom --style plain"

function filePicker(query) {
    const Key = lua.require("jfind.key")
    lua.require("jfind").findFile({
        formatPaths: true,
        preview: preview,
        query: query,
        previewPosition: "right",
        previewPercent: 0.6,
        previewMinWidth: 60,
        queryPosition: "top",
        hidden: true,
        callback: {
            [Key.DEFAULT]: vim.cmd.edit,
            [Key.CTRL_B]: vim.cmd.split,
            [Key.CTRL_N]: vim.cmd.vsplit,
        }
    })
}

function cmdFilePicker() {
    const Key = lua.require("jfind.key")
    lua.require("jfind").findFile({
        formatPaths: true,
        preview: preview,
        previewPosition: "right",
        previewPercent: 0.6,
        previewMinWidth: 60,
        queryPosition: "top",
        hidden: true,
        callback: {
            [Key.DEFAULT]: vim.fn.feedkeys,
        }
    })
}

function liveGrepPicker() {
    const jfind = lua.require("jfind")
    const Key = lua.require("jfind.key")
    jfind.liveGrep({
        exclude: [".git"],
        include: [],
        query: "",
        hidden: true,
        preview: preview,
        previewPosition: "bottom",
        queryPosition: "top",
        caseSensitivity: "smart",
        callback: {
            [Key.DEFAULT]: jfind.editGotoLine,
            [Key.CTRL_B]: jfind.splitGotoLine,
            [Key.CTRL_N]: jfind.vsplitGotoLine,
        }
    })
}

function bufferPicker() {
    const jfind = lua.require("jfind")
    const Key = lua.require("jfind.key")
    const bufs = vim.api.nvim_list_bufs()
        .filter(buf => vim.api.nvim_buf_is_loaded(buf))
    const input: any[] = [];
    bufs.forEach((buf) => {
        const name = vim.api.nvim_buf_get_name(buf)
        input.push(name == "" ? "[No Name]" : jfind.formatPath(name))
        input.push(buf + " " + name)
    })

    jfind.jfind({
        input: input,
        hints: true,
        formatPaths: true,
        showQuery: true,
        acceptNonMatch: true,
        // should be able to pass hint or item with {item} & {hint}
        preview: preview + " $(echo {} | awk '{$1=\"\"; print $0}')",
        previewPosition: "right",
        previewPercent: 0.6,
        previewMinWidth: 60,
        queryPosition: "top",
        hidden: true,
        // this should be called formatItem() which returns string instead of calling callback
        callbackWrapper: (callback, item: string, query: string) => {
            callback(item.split(" ")[0], query)
        },
        callback: {
            [Key.ESCAPE]: () => {},
            [Key.DEFAULT]: (result) => vim.cmd.buffer(result),
            [Key.CTRL_B]: (result) => {vim.cmd.split(); vim.cmd.buffer(result)},
            [Key.CTRL_N]: (result) => {vim.cmd.vsplit(); vim.cmd.buffer(result)},
            [Key.CTRL_F]: (_, query) => {
                filePicker(query)
            },
        }
    })
}

function liveGrepQfListPicker() {
    const jfind = lua.require("jfind")
    const Key = lua.require("jfind.key")
    jfind.liveGrep({
        exclude: [".git"],
        include: [],
        query: "",
        hidden: true,
        preview: preview,
        previewPosition: "bottom",
        queryPosition: "top",
        caseSensitivity: "smart",
        selectAll: true,
        callback: {
            [Key.DEFAULT]: (results: [string, number][]) => {
                const qflist = results.map((result, i) => ({
                    filename: result[0],
                    lnum: result[1]
                }))
                // for i, v in pairs(results) do
                //     qflist[i] = {filename: v[1], lnum: v[2]}
                // end
                if (results[0]) {
                    jfind.editGotoLine(results[0][0], results[0][1])
                }
                vim.fn.setqflist(qflist)
            },
        }
    })
}

export const jfind = {
    1: "jake-stewart/jfind.nvim",
    branch: "2.0",
    dir: "~/clones/jfind.nvim",
    keys: [
        [ "<c-f>", filePicker ],
        { 1: "<c-f>", 2: cmdFilePicker, mode: "c" },
        [ "<c-b>", bufferPicker ],
        [ "<leader><c-f>", liveGrepPicker ],
        [ "<leader><c-a>", liveGrepQfListPicker ],
    ],
    config: () => lua.require("jfind").setup({
        exclude: [
            ".git*",
            ".idea",
            ".cache",
            ".vscode",
            ".settings",
            ".classpath",
            ".gradle",
            ".project",
            ".sass-cache",
            ".class",
            "__pycache__",
            "node_modules",
            "target",
            "build",
            "tmp",
            "assets",
            "ci",
            "dist",
            "public",
            "*.iml",
            "*.meta"
        ],
        key: "<c-f>",
        tmux: true,
    })
}
