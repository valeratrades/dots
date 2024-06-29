export const codeActionMenu = {
    1: "weilbith/nvim-code-action-menu",
    keys: [
        [ "<leader>f", vim.cmd.CodeActionMenu ]
    ],
    init: () => {
        vim.g.code_action_menu_window_border = "none";
        vim.g.code_action_menu_show_details = false;
        vim.g.code_action_menu_show_diff = false;
        vim.g.code_action_menu_show_action_kind = false;
    },
}
