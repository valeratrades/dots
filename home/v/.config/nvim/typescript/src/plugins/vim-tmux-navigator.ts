export const vimTmuxNavigator = {
    1: 'christoomey/vim-tmux-navigator',
    keys: [
        { 1: "<m-h>", 2: ":<C-U>TmuxNavigateLeft<cr>", mode: "n", silent: true },
        { 1: "<m-j>", 2: ":<C-U>TmuxNavigateDown<cr>", mode: "n", silent: true },
        { 1: "<m-k>", 2: ":<C-U>TmuxNavigateUp<cr>", mode: "n", silent: true },
        { 1: "<m-l>", 2: ":<C-U>TmuxNavigateRight<cr>", mode: "n", silent: true },
        { 1: "<m-h>", 2: ":<C-U>TmuxNavigateLeft<cr>gv", mode: "v", silent: true },
        { 1: "<m-j>", 2: ":<C-U>TmuxNavigateDown<cr>gv", mode: "v", silent: true },
        { 1: "<m-k>", 2: ":<C-U>TmuxNavigateUp<cr>gv", mode: "v", silent: true },
        { 1: "<m-l>", 2: ":<C-U>TmuxNavigateRight<cr>gv", mode: "v", silent: true },
        { 1: "<m-h>", 2: "<c-o>:<C-U>TmuxNavigateLeft<cr>", mode: "i", silent: true },
        { 1: "<m-j>", 2: "<c-o>:<C-U>TmuxNavigateDown<cr>", mode: "i", silent: true },
        { 1: "<m-k>", 2: "<c-o>:<C-U>TmuxNavigateUp<cr>", mode: "i", silent: true },
        { 1: "<m-l>", 2: "<c-o>:<C-U>TmuxNavigateRight<cr>", mode: "i", silent: true },
    ],
    init: () => {
        vim.g.tmux_navigator_no_mappings = 1
    }
}
