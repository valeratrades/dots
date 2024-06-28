import * as plugins from "./plugins";

const lazypath = vim.fn.stdpath("data") + "/lazy/lazy.nvim"
if (!vim.loop.fs_stat(lazypath)) {
    vim.fn.system([
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    ])
};
vim.opt.runtimepath.prepend(lazypath)

lua.require("lazy").setup(Object.values(plugins), {
    install: {
        colorscheme: ["custom"]
    },
    defaults: {
        lazy: false,
    },
    change_detection: {
        enabled: false,
        notify: false,
    },
    performance: {
        cache: {
            enabled: true,
        },
        reset_packpath: true,
        rtp: {
            reset: true,
            disabled_plugins: [
                "gzip",
                // "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            ],
        },
    },
});
