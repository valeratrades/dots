const LEADER = "<c-f>";

const KEYS = {
    print: "<down>",
    debug: "<c-d>",
    error: "<c-x>",
    while: "<c-w>",
    for: "<c-f>",
    if: "<c-i>",
    elseif: "<c-o>",
    else: "<c-e>",
    switch: "<c-s>",
    case: "<c-v>",
    default: "<c-b>",
    function: "<c-m>",
    lambda: "<c-l>",
    class: "<c-k>",
    struct: "<c-h>",
    try: "<c-t>",
    enum: "<c-n>"
}

export const shnip = {
    1: "jake-stewart/shnip.nvim",
    keys: Object.values(KEYS).map((key) => ({
        1: LEADER + key,
        mode: "i"
    })),
    config: () => {
        lua.require("shnip").setup({
            leader: LEADER,
            keys: KEYS
        })
        lua.require("shnip").snippet("<c-p>", "()<left>")
    }
}
