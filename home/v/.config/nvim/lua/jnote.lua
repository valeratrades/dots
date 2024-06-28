










-- go away
-- this isnt finished











local Array = require("Array")
local String = require("String")
local Object = require("Object")
local range = require("range")

local cb_nsid = vim.api.nvim_create_namespace("md")

local codeStartRegex = vim.regex([[^\s*```.*$]])
local codeEndRegex = vim.regex([[^.*```.*$]])

if codeStartRegex == nil or codeEndRegex == nil then
    print("abort: invalid regex")
    return
end

local extMarkId = 0

local cbMarks = Array({})

local function deleteMark(id)
    return vim.api.nvim_buf_del_extmark(0, cb_nsid, id)
end

local function getMark(id, opts)
    return Array(vim.api.nvim_buf_get_extmark_by_id(0, cb_nsid, id, opts or {}))
end

local function setMark(line, opts)
    return vim.api.nvim_buf_set_extmark(0, cb_nsid, line, 0, opts or {})
end

local function getMarks(start, _end, opts)
    return Array(vim.api.nvim_buf_get_extmarks(
        0,
        cb_nsid,
        {start, 0},
        {_end, 0},
        opts or {}
    ))
end

local function parseMark(line, idx)
    local eof = vim.fn.line("$")
    local line_text = vim.fn.getline(line)
    local startLine = line
    local title = string.sub(line_text, 4, #line_text)
    line = line + 1
    local matched = false
    while line <= eof do
        if codeEndRegex:match_str(vim.fn.getline(line)) then
            matched = true
            break
        end
        line = line + 1
    end

    if not matched then
        return line
    end

    extMarkId = extMarkId + 1
    local start_mark_id = setMark(startLine - 1, {
        id = extMarkId,
        end_row = line,
        -- virt_text = {{extMarkId .. " " .. title, "CodeBlock"}},
        virt_text = {{title, "CodeBlock"}},
        virt_text_pos = 'right_align',
        line_hl_group = "CodeBlock",
        hl_group = "CodeBlock",
        hl_eol = true,
    })

    extMarkId = extMarkId + 1
    local end_mark_id = setMark(line - 1, {
        id = extMarkId,
        line_hl_group = "CodeBlock",
        hl_group = "CodeBlock",
        hl_eol = true,
    })

    if idx == nil then
        cbMarks:push(Array({start_mark_id, end_mark_id}))
    else
        cbMarks:splice(idx, 0, Array({start_mark_id, end_mark_id}))
    end
    return line
end

local function generateExtMarks(line, endLine, idx)
    while line <= endLine do
        if codeStartRegex:match_str(vim.fn.getline(line)) then
            line = parseMark(line, idx)
            if idx ~= nil then
                idx = idx + 1
            end
        end
        line = line + 1
    end
end

local function max(a, b)
    if a == nil or b == nil then return a or b end
    if a > b then return a else return b end
end

local function min(a, b)
    if a == nil or b == nil then return a or b end
    if a < b then return a else return b end
end

local function checkLine(start, _end)
    local dirtyIdx = nil
    local dirtyEndIdx = nil
    local dirtyLine = nil

    local marks = getMarks(max(1, start - 1), _end - 1)
    for _, mark in marks do
        local idx = cbMarks:findIndex(function(cbMark)
            return cbMark:at(0) == Array(mark):at(0)
                or cbMark:at(1) == Array(mark):at(0)
        end)
        if idx == -1 then
            return
        end
        local cbMark = cbMarks:at(idx)
        local cbStart = getMark(cbMark:at(0))
        local cbEnd = getMark(cbMark:at(0))
        local cbStartValid = codeStartRegex:match_str(
            vim.fn.getline(cbStart:at(0) + 1))
        local cbEndValid = codeEndRegex:match_str(
            vim.fn.getline(cbEnd:at(0) + 1))
        if cbStart:at(0) ~= cbEnd:at(0) and cbStartValid and cbEndValid then
            dirtyIdx = min(dirtyIdx, idx)
            dirtyEndIdx = max(dirtyEndIdx, idx)
        else
            dirtyIdx = min(dirtyIdx, idx)
            dirtyEndIdx = #cbMarks - 1
        end
    end

    for line = max(1, start), _end do
        if codeEndRegex:match_str(vim.fn.getline(line)) then
            if #getMarks(line - 1, line - 1, {limit = 1}) == 0 then
                local newMarks = getMarks(line - 2, 0, {limit = 1})
                if #newMarks ~= 0 then
                    local mark = newMarks:at(0)
                    local idx = cbMarks:findIndex(function(cbMark)
                        return cbMark:at(0) == mark:at(0)
                            or cbMark:at(1) == mark:at(0)
                    end)
                    dirtyIdx = min(dirtyIdx, idx)
                    dirtyEndIdx = #cbMarks - 1
                else
                    dirtyIdx = 0
                    dirtyEndIdx = #cbMarks - 1
                    dirtyLine = line
                    break
                end
            end
        end
    end

    if dirtyIdx and dirtyEndIdx then
        local startLine = dirtyLine or getMark(cbMarks:at(dirtyIdx):at(0)):at(0) + 1
        if dirtyEndIdx == #cbMarks - 1 then
            for _ in range(dirtyIdx, dirtyEndIdx + 1) do
                local cbMark = cbMarks:splice(dirtyIdx, 1):at(0)
                deleteMark(cbMark:at(0))
                deleteMark(cbMark:at(1))
            end
            generateExtMarks(startLine, vim.fn.line("$"))
        else
            local endLine = getMark(cbMarks:at(dirtyEndIdx):at(1)):at(0)
            for i in range(dirtyIdx, dirtyEndIdx + 1) do
                local cbMark = cbMarks:at(i)
                deleteMark(cbMark:at(0))
                deleteMark(cbMark:at(1))
            end
            generateExtMarks(startLine, endLine, dirtyIdx)
        end
    end
end

generateExtMarks(1, vim.fn.line("$"))

vim.api.nvim_create_augroup("CodeBlocks", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.md",
    group = "CodeBlocks",
    callback = function()
        generateExtMarks(1, vim.fn.line("$"))
    end
})

local insertStartLookup = {}

vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*.md",
    group = "CodeBlocks",
    callback = function()
        insertStartLookup[vim.fn.winnr()] = vim.fn.line('.')
    end
})

vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*.md",
    group = "CodeBlocks",
    callback = function()
        local winnr = vim.fn.winnr()
        local start = insertStartLookup[winnr]
        local _end = vim.fn.line('.')
        insertStartLookup[winnr] = _end
        checkLine(min(start, _end), max(start, _end))
    end
})

vim.api.nvim_create_autocmd("TextChanged", {
    group = "CodeBlocks",
    pattern = "*.md",
    callback = function()
        local start = Array(vim.fn.getpos("'[")):at(1)
        local _end = Array(vim.fn.getpos("']")):at(1)
        checkLine(min(start, _end), max(start, _end))
    end
})




-------------------------------------------------------
local glyphs = Array({
    "\u{0305}", "\u{030D}", "\u{030E}", "\u{0310}", "\u{0312}", "\u{033D}", "\u{033E}", "\u{033F}",
    "\u{0346}", "\u{034A}", "\u{034B}", "\u{034C}", "\u{0350}", "\u{0351}", "\u{0352}", "\u{0357}",
    "\u{035B}", "\u{0363}", "\u{0364}", "\u{0365}", "\u{0366}", "\u{0367}", "\u{0368}", "\u{0369}",
    "\u{036A}", "\u{036B}", "\u{036C}", "\u{036D}", "\u{036E}", "\u{036F}", "\u{0483}", "\u{0484}",
    "\u{0485}", "\u{0486}", "\u{0487}", "\u{0592}", "\u{0593}", "\u{0594}", "\u{0595}", "\u{0597}",
    "\u{0598}", "\u{0599}", "\u{059C}", "\u{059D}", "\u{059E}", "\u{059F}", "\u{05A0}", "\u{05A1}",
    "\u{05A8}", "\u{05A9}", "\u{05AB}", "\u{05AC}", "\u{05AF}", "\u{05C4}", "\u{0610}", "\u{0611}",
    "\u{0612}", "\u{0613}", "\u{0614}", "\u{0615}", "\u{0616}", "\u{0617}", "\u{0657}", "\u{0658}",
    "\u{0659}", "\u{065A}", "\u{065B}", "\u{065D}", "\u{065E}", "\u{06D6}", "\u{06D7}", "\u{06D8}",
    "\u{06D9}", "\u{06DA}", "\u{06DB}", "\u{06DC}", "\u{06DF}", "\u{06E0}", "\u{06E1}", "\u{06E2}",
    "\u{06E4}", "\u{06E7}", "\u{06E8}", "\u{06EB}", "\u{06EC}", "\u{0730}", "\u{0732}", "\u{0733}",
    "\u{0735}", "\u{0736}", "\u{073A}", "\u{073D}", "\u{073F}", "\u{0740}", "\u{0741}", "\u{0743}",
    "\u{0745}", "\u{0747}", "\u{0749}", "\u{074A}", "\u{07EB}", "\u{07EC}", "\u{07ED}", "\u{07EE}",
    "\u{07EF}", "\u{07F0}", "\u{07F1}", "\u{07F3}", "\u{0816}", "\u{0817}", "\u{0818}", "\u{0819}",
    "\u{081B}", "\u{081C}", "\u{081D}", "\u{081E}", "\u{081F}", "\u{0820}", "\u{0821}", "\u{0822}",
    "\u{0823}", "\u{0825}", "\u{0826}", "\u{0827}", "\u{0829}", "\u{082A}", "\u{082B}", "\u{082C}",
    "\u{082D}", "\u{0951}", "\u{0953}", "\u{0954}", "\u{0F82}", "\u{0F83}", "\u{0F86}", "\u{0F87}",
    "\u{135D}", "\u{135E}", "\u{135F}", "\u{17DD}", "\u{193A}", "\u{1A17}", "\u{1A75}", "\u{1A76}",
    "\u{1A77}", "\u{1A78}", "\u{1A79}", "\u{1A7A}", "\u{1A7B}", "\u{1A7C}", "\u{1B6B}", "\u{1B6D}",
    "\u{1B6E}", "\u{1B6F}", "\u{1B70}", "\u{1B71}", "\u{1B72}", "\u{1B73}", "\u{1CD0}", "\u{1CD1}",
    "\u{1CD2}", "\u{1CDA}", "\u{1CDB}", "\u{1CE0}", "\u{1DC0}", "\u{1DC1}", "\u{1DC3}", "\u{1DC4}",
    "\u{1DC5}", "\u{1DC6}", "\u{1DC7}", "\u{1DC8}", "\u{1DC9}", "\u{1DCB}", "\u{1DCC}", "\u{1DD1}",
    "\u{1DD2}", "\u{1DD3}", "\u{1DD4}", "\u{1DD5}", "\u{1DD6}", "\u{1DD7}", "\u{1DD8}", "\u{1DD9}",
    "\u{1DDA}", "\u{1DDB}", "\u{1DDC}", "\u{1DDD}", "\u{1DDE}", "\u{1DDF}", "\u{1DE0}", "\u{1DE1}",
    "\u{1DE2}", "\u{1DE3}", "\u{1DE4}", "\u{1DE5}", "\u{1DE6}", "\u{1DFE}", "\u{20D0}", "\u{20D1}",
    "\u{20D4}", "\u{20D5}", "\u{20D6}", "\u{20D7}", "\u{20DB}", "\u{20DC}", "\u{20E1}", "\u{20E7}",
    "\u{20E9}", "\u{20F0}", "\u{2CEF}", "\u{2CF0}", "\u{2CF1}", "\u{2DE0}", "\u{2DE1}", "\u{2DE2}",
    "\u{2DE3}", "\u{2DE4}", "\u{2DE5}", "\u{2DE6}", "\u{2DE7}", "\u{2DE8}", "\u{2DE9}", "\u{2DEA}",
    "\u{2DEB}", "\u{2DEC}", "\u{2DED}", "\u{2DEE}", "\u{2DEF}", "\u{2DF0}", "\u{2DF1}", "\u{2DF2}",
    "\u{2DF3}", "\u{2DF4}", "\u{2DF5}", "\u{2DF6}", "\u{2DF7}", "\u{2DF8}", "\u{2DF9}", "\u{2DFA}",
    "\u{2DFB}", "\u{2DFC}", "\u{2DFD}", "\u{2DFE}", "\u{2DFF}", "\u{A66F}", "\u{A67C}", "\u{A67D}",
    "\u{A6F0}", "\u{A6F1}", "\u{A8E0}", "\u{A8E1}", "\u{A8E2}", "\u{A8E3}", "\u{A8E4}", "\u{A8E5}",
    "\u{A8E6}", "\u{A8E7}", "\u{A8E8}", "\u{A8E9}", "\u{A8EA}", "\u{A8EB}", "\u{A8EC}", "\u{A8ED}",
    "\u{A8EE}", "\u{A8EF}", "\u{A8F0}", "\u{A8F1}", "\u{AAB0}", "\u{AAB2}", "\u{AAB3}", "\u{AAB7}",
    "\u{AAB8}", "\u{AABE}", "\u{AABF}", "\u{AAC1}", "\u{FE20}", "\u{FE21}", "\u{FE22}", "\u{FE23}",
    "\u{FE24}", "\u{FE25}", "\u{FE26}",
    "\u{00010A0F}", "\u{00010A38}", "\u{0001D185}", "\u{0001D186}", "\u{0001D187}",
    "\u{0001D188}", "\u{0001D189}", "\u{0001D1AA}", "\u{0001D1AB}", "\u{0001D1AC}",
    "\u{0001D1AD}", "\u{0001D242}", "\u{0001D243}", "\u{0001D244}"
})


local function enableTmuxPassthrough()
    vim.fn.system("tmux set -p allow-passthrough on")
end

local function kittyGraphicsDelete(id)
    return "\x1b_Ga=d,q=2,d=I,i=" .. id .. "\x1b\\"
end

local function kittyGraphics(filename, kwargs)
    return Array({
        "\x1b_G",
        Object.entries(kwargs):map(function(e)
            return e:at(0) .. "=" .. e:at(1)
        end):join(","),
        ";",
        vim.fn.system({"base64"}, filename),
        "\x1b\\"
    }):join("")
end

local function tmuxPassthrough(string)
    string = vim.fn.substitute(string, "\x1b", "\x1b\x1b", "g")
    return "\x1bPtmux;" .. string .. "\x1b\\"
end

local function prepare(id, filename, cols, rows)
    local width = cols
    local height = rows

    enableTmuxPassthrough()
    local deleteCmd = kittyGraphicsDelete(id)
    local cmd = kittyGraphics(filename, {
        f=100, q=2, U=1, X=0, i=id, a="T", c=width, r=height, t="f"
    })

    local stdout = io.open("/dev/stdout", "w")
    if (stdout) then
        stdout:write(tmuxPassthrough(deleteCmd))
        stdout:flush()
        stdout:write(tmuxPassthrough(cmd))
        stdout:flush()
    end
end

local function createLines(cols, rows)
    return range(rows):map(function(row)
        return range(cols):map(function(col)
            return "\u{0010EEEE}" .. glyphs:at(row) .. glyphs:at(col)
        end):join("")
    end)
end

local rows = 10

--
-- lines = vim.fn.map(createLines(cols, rows), function(i, line)
--     return {{line, "Image70"}}
-- end)
--
-- -- vim.print(lines)
-- setMark(1, {
--     virt_lines = lines
-- })

local img_nsid = vim.api.nvim_create_namespace("md_images")

-- [id, path][]
local imgMarks = Array({})

-- [path, id, cols, listeners][]
local images = Array({})

local imgRegex = vim.regex("^\\s*!\\[[^\\[\\]]*\\]([a-zA-Z0-9._\\/ -]\\+)$")
local imgPathRegex = vim.regex("(\\zs[a-zA-Z0-9._\\/ -]\\+\\ze)$")

if imgPathRegex == nil or imgRegex == nil then
    print("abort: invalid regex")
    return
end

local function generateImgMark(lnum, idx)
    local str = vim.fn.getline(lnum)
    local start, _end = imgPathRegex:match_str(str)
    if start == nil then
        if idx ~= -1 then
            vim.api.nvim_buf_del_extmark(0, img_nsid, imgMarks:at(idx):at(0))
            imgMarks:splice(idx, 1)
        end
        return
    end

    local path = vim.fn.expand("%:p:h") .. "/" .. string.sub(str, start + 1, _end)
    local imageIdx = images:findIndex(function(image) return image:at(0) == path end)

    if imageIdx == -1 then
        local id = 1
        while true do
            local match = images:findIndex(function(image)
                return image:at(1) == id
            end)
            if match == -1 then
                break
            end
            id = id + 1
        end
        if id >= 256 then
            return
        end
        local info = String(vim.fn.system({"identify", path}))
        if vim.v.shell_error ~= 0 then
            return
        end
        local dimensions = info:split(" "):at(2)
        local w, h = unpack(dimensions:split("x"))
        local ratio = tonumber(w) / tonumber(h)
        local cols = math.floor(ratio * rows * 2.5)
        prepare(id, path, cols, rows)
        imageIdx = #images
        images:push(Array({path, id, cols, 1}))

        local idHex = string.format("%x", id)
        if #idHex == 1 then idHex = "0" .. idHex end
        vim.cmd.hi("Image" .. id, "ctermfg=" .. id, "guifg=#0000" .. idHex)
    end

    local image = images:at(imageIdx)
    local lines = createLines(image:at(2), rows)
        :map(function(line) return {{line, "Image" .. image:at(1)}} end)

    local id = vim.api.nvim_buf_set_extmark(0, img_nsid, lnum - 1, 0, {
        virt_lines = lines
    })
    imgMarks:push(Array({id, path}))
end

local function generateImgExtMarks(line, endLine)
    while line <= endLine do
        if imgRegex:match_str(vim.fn.getline(line)) then
            generateImgMark(line, -1)
        end
        line = line + 1
    end
end

local function checkLineImg(start, _end)
    local marks = Array(vim.api.nvim_buf_get_extmarks(
        0, img_nsid, {max(1, start - 1), 0}, {_end - 1, 0}, {}))

    for _, mark in marks do
        local idx = imgMarks:findIndex(function(imgMark)
            return imgMark:at(0) == Array(mark):at(0)
        end)
        generateImgMark(mark:at(1), idx)
    end

    function getMarks(line)
        return Array(vim.api.nvim_buf_get_extmarks(
            0,
            img_nsid,
            {line - 1, 0},
            {line - 1, 0},
            {limit = 1}
        ))
    end

    range(max(1, start), _end + 1)
        :filter(function(line)
            return imgRegex:match_str(vim.fn.getline(line))
                and #getMarks(line) == 0
        end)
        :forEach(function(line)
            generateImgMark(line, -1)
        end)
end

generateImgExtMarks(1, vim.fn.line("$"))

vim.api.nvim_create_augroup("MarkdownImages", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.md",
    group = "MarkdownImages",
    callback = function()
        generateImgExtMarks(1, vim.fn.line("$"))
    end
})

local imgsInsertStartLookup = {}

vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*.md",
    group = "MarkdownImages",
    callback = function()
        imgsInsertStartLookup[vim.fn.winnr()] = vim.fn.line('.')
    end
})

vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*.md",
    group = "MarkdownImages",
    callback = function()
        local winnr = vim.fn.winnr()
        local start = imgsInsertStartLookup[winnr]
        local _end = vim.fn.line('.')
        imgsInsertStartLookup[winnr] = _end
        checkLineImg(min(start, _end), max(start, _end))
    end
})

vim.api.nvim_create_autocmd("TextChanged", {
    group = "MarkdownImages",
    pattern = "*.md",
    callback = function()
        local start = Array(vim.fn.getpos("'[")):at(1)
        local _end = Array(vim.fn.getpos("']")):at(1)
        checkLineImg(min(start, _end), max(start, _end))
    end
})
