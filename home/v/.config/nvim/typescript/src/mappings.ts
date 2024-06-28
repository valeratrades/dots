function forceGoFile() {
    const fname = vim.fn.expand("<cfile>");
    const path = vim.fn.expand("%:p:h") + "/" + fname;
    vim.print(vim.fn.filereadable(path));
    if (vim.fn.filereadable(path) == 0) {
        vim.cmd("silent! !touch " + path);
    }
    vim.cmd.norm("gf");
}

function getPopups() {
    return vim.api.nvim_tabpage_list_wins(0)
        .filter(win => vim.api.nvim_win_get_config(win).zindex);
}

function killPopups() {
    for (const popup of getPopups()) {
        vim.api.nvim_win_close(popup, false);
    }
}

function yankPopup() {
    const popups = getPopups();
    if (popups.length == 1) {
        const popup_id = popups[1];
        const bufnr = vim.api.nvim_win_get_buf(popup_id);
        const lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false);
        const content = lines.join("\n");
        vim.fn.setreg("+", content);
    }
    else {
        return;
    }
}

function fixSpelling() {
    const cword: string = vim.fn.expand("<cword>");
    let spelling: string = vim.fn.spellsuggest("_" + cword)[0] || "";
    spelling = (cword.toLowerCase() == cword) && spelling.toLowerCase() || spelling;
    let output = '"_yiw';;
    if (lua.string.match(spelling, "^[a-zA-Z -]+$") && cword != spelling) {
        output = '"_ciw' + spelling + "\x1b" + output;
    }
    return output;
}

function scanTscErrors(level, callback: (output: any[]) => void) {
    const cmd = ["tsc", "--noEmit"];
    if (level != vim.diagnostic.severity.ERROR) {
        cmd.push("--noUnusedLocals");
        cmd.push("--noUnusedParameters");
    }
    const output: string[] = [];
    let results: any[] = [];
    vim.fn.jobstart(cmd, {
        stdout_buffered: true,
        on_exit: () => callback(results),
        on_stdout: (_, stdout: string[]) => {
            stdout = stdout.filter((line) =>
                line.length > 0 && line[0] != " ");
            results = stdout.map((line) => {
                const file = line.substring(0, line.indexOf(":"));
                const text = line.substring(file.length + 1).trim();
                const filename = file.substring(0, file.indexOf("("));
                const commaIdx = file.indexOf(",", filename.length);
                const closeParenIdx = file.indexOf(")", commaIdx);
                const lnum = file.substring(filename.length + 1, commaIdx);
                const cnum = file.substring(commaIdx + 1, closeParenIdx);
                return {
                    filename,
                    lnum,
                    col: cnum,
                    text,
                };
            })
        }
    });
}

const ERROR_SCANNERS: {[key: string]: any} = {
    javascript: scanTscErrors,
    typescript: scanTscErrors,
    typescriptreact: scanTscErrors
};

const SPINNER_CHARS = ["⠇", "⠋", "⠙", "⠸", "⠴", "⠦"];
function spinner(timer) {
    let i = 0;
    timer.start(timer, 100, 100, vim.schedule_wrap(() => {
        vim.api.nvim_echo([[SPINNER_CHARS[i] + " scanning"]], false, {});
        i = (i + 1) % SPINNER_CHARS.length;
    }));
}

let scanning = false;
function scanErrors(level) {
    if (vim.o.filetype == "") {
        vim.api.nvim_err_writeln("No filetype set");
        return;
    }
    if (scanning) {
        vim.api.nvim_err_writeln("Already scanning for errors");
        return;
    }
    const callback = ERROR_SCANNERS[vim.o.filetype];
    if (!callback) {
        vim.api.nvim_err_writeln("No error scanner for " + vim.o.filetype);
        return;
    }
    scanning = true;
    const timer = vim.loop.new_timer();
    spinner(timer);
    callback(level, (errors: any[]) => {
        timer.stop();
        scanning = false;
        if (errors.length == 0) {
            vim.api.nvim_echo([["No issues found", "DiffAdd"]], false, {});
            return;
        }
        vim.api.nvim_echo([], false, {});
        vim.fn.setqflist(errors);
        vim.cmd.copen();
    });
}

vim.keymap.set("n", "<leader>gf", forceGoFile);

// repeat <c-r> to use unnamed register analogous to ""
vim.keymap.set("i", "<c-r><c-r>", "<c-r>\"");

// U makes more sense than <c-r> for redo
vim.keymap.set("n", "U", "<c-r>");

// my <c-k> is mapped <up> in tmux
vim.keymap.set(["i", "c"], "<up>", "<c-k>");

// default <c-u> and <c-d> are disorientating
vim.keymap.set("n", "<c-u>", "10k");
vim.keymap.set("n", "<c-d>", "10j");

// zero width space digraph
vim.cmd.digraphs("zs " + 0x200b);

// toggle cursor column
vim.keymap.set("n", "<leader>cc", () => {
    vim.o.cursorcolumn = !vim.o.cursorcolumn;
});

// last changed region (works for paste, too)
vim.keymap.set("v", ".", () =>
    "v`[" + vim.fn.strpart(vim.fn.getregtype(), 0, 1) + "`]",
    {expr: true}
);
vim.keymap.set("o", ".", () => {
    vim.cmd.norm("`[" + vim.fn.strpart(vim.fn.getregtype(), 0, 1) + "`]");
});

vim.keymap.set("n", "tp", yankPopup);


vim.keymap.set("n", "<esc>", () => {
    vim.cmd.noh();
    killPopups();
});

// ^, $, and %, <c-^> are motions I use all the time
// however, the keys are in awful positions
vim.keymap.set(["n", "v", "o"], "gh", "^");
vim.keymap.set(["n", "v", "o"], "gl", "$");
vim.keymap.set(["n", "v", "o"], "gm", "%");

// 'A' is annoying because you have to release shift
// this causes me to type ':' instead of ';' very often
vim.keymap.set(["n", "v"], "ga", "A");

vim.keymap.set("n", "H", "H^");
// vim.keymap.set("n", "M", "M^");
vim.keymap.set("n", "L", "L^");

// I center screen all the time, zz is slow and hurts my finger
vim.keymap.set(["n", "v"], "gb", "zz");
vim.keymap.set("n", "<c-o>", "<c-o>zz");
vim.keymap.set("n", "<c-i>", "<c-i>zz");

// fix spelling for cursor word
vim.keymap.set("n", "<leader>s", fixSpelling, { expr: true });

// dd, yy, cc, etc all take too long since the same key is pressed twice
// use dl, yl, cl etc instead
vim.keymap.set("o", "l", "_");
vim.keymap.set("o", "L", "_");
vim.keymap.set("o", "c", "l");

// y is one of the hardest keys to press yet yanking is very common
// t is easier to press yet t is never used outside of operator pending mode
vim.keymap.set(["n", "v"], "t", "y");
vim.keymap.set(["n"], "T", "Y");
vim.keymap.set(["n", "v"], "y", "<NOP>");

vim.keymap.set("n", "<leader>i", "~hi");

vim.keymap.set("n", "<leader>E", () =>
    scanErrors(vim.diagnostic.severity.ERROR));
vim.keymap.set("n", "<leader>W", () =>
    scanErrors(vim.diagnostic.severity.WARN));

vim.keymap.set("n", "<leader>o", vim.cmd.copen);
vim.keymap.set("n", "<leader>h", () => {
    try {
        vim.cmd.cprevious();
    }
    catch {}
});
vim.keymap.set("n", "<leader>l", () => {
    try {
        vim.cmd.cnext();
    }
    catch {}
});

vim.keymap.set(["n", "v"], "gK", "ga");
vim.keymap.set(["n", "v"], "-c", '"_c');
vim.keymap.set(["n", "v"], "-d", '"_d');
vim.keymap.set(["n", "v"], "-x", '"_x');
