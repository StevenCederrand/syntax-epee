local SyntaxEpee = {}

SyntaxEpee.namespace = vim.api.nvim_create_namespace('syntax_epee')
SyntaxEpee.ns_id = vim.api.nvim_get_namespaces().syntax_epee

local popup = require('plenary.popup')

local severity = {
  [1] = '<ERROR>',
  [2] = '<WARN>',
  [3] = '<INFO>',
  [4] = '<HINT>',
}

local colors = {
   ERROR = 'DiagnosticError',
   WARNING = 'DiagnosticWarn',
   INFO = 'DiagnosticInfo',
   HINT = 'DiagnosticHint',
}

local syntax_epee_win_id = nil
local syntax_epee_buf_id = nil
local full_diag_data = {}
local diag_lines = {}

local function getDiags()
    local ok, diags = pcall(vim.diagnostic.get, 0)

    if not ok then
        error('unable to get diagnostics')
        return nil
    end

    return diags
end

local function nvim_set_extmark(line, end_line, hl_group)
    vim.api.nvim_buf_set_extmark(syntax_epee_buf_id, SyntaxEpee.ns_id,
        line,
        0,
        {
            end_row = end_line,
            end_col = 0,
            hl_group = hl_group,

        }
    )
end

local function removeNewLine(str)
    local pos = 0
    while true do
        local nl = string.find(str, '\n', pos, true)
        if not nl then break end
        pos = nl + 1
    end
    if pos == 0 then return str end
    return string.sub(str, 1, pos - 2)
end

local function showWindow(opts)
    local height = opts.window_height or 20
    local width = opts.window_width or 30
    local borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }

    syntax_epee_win_id = popup.create(diag_lines, {
        title = 'Syntax-Épée',
        highlight = 'SyntaxEpeeWindow',
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    syntax_epee_buf_id = vim.api.nvim_win_get_buf(syntax_epee_win_id)
end

local function addHighlights()
    vim.api.nvim_command('highlight link SyntaxEpeeErr ' .. colors.ERROR)
    vim.api.nvim_command('highlight link SyntaxEpeeWarn ' .. colors.WARNING)
    vim.api.nvim_command('highlight link SyntaxEpeeInfo ' .. colors.INFO)
    vim.api.nvim_command('highlight link SyntaxEpeeHint ' .. colors.HINT)

    local lines = {
        errors = 0,
        warnings = 0,
        infos = 0,
        hints = 0,
    }

    for i = 1, #full_diag_data do
        if full_diag_data[i].severity == severity[1] then
            lines.errors = lines.errors + 1
        end
        if full_diag_data[i].severity == severity[2] then
            lines.warnings = lines.warnings + 1
        end
        if full_diag_data[i].severity == severity[3] then
            lines.infos = lines.infos + 1
        end
        if full_diag_data[i].severity == severity[4] then
            lines.hints = lines.hints + 1
        end
    end

    nvim_set_extmark(0, lines.errors, 'SyntaxEpeeErr')
    nvim_set_extmark(lines.errors, lines.errors + lines.warnings, 'SyntaxEpeeWarn')
    nvim_set_extmark(lines.errors + lines.warnings, lines.errors + lines.warnings + lines.infos, 'SyntaxEpeeInfo')
    nvim_set_extmark(lines.errors + lines.warnings + lines.infos, lines.errors + lines.warnings + lines.infos + lines.hints, 'SyntaxEpeeHint')
end

function CloseWindow()
    vim.api.nvim_win_close(syntax_epee_win_id, true)
    diag_lines = {}
    full_diag_data = {}
    syntax_epee_win_id = nil
end

function SelectHint()
    local idx = vim.api.nvim_win_get_cursor(syntax_epee_win_id)[1]
    local err_line = full_diag_data[idx]

    CloseWindow()

    if err_line ~= nil then
        pcall(vim.api.nvim_win_set_cursor, 0, { err_line.line, err_line.col })
    end
end

function SyntaxEpee.stab(opts)
    opts = opts or {}

    local diags = getDiags()

    if diags == nil then
        return
    end

    table.sort(diags, function(a,b) return a.severity < b.severity end)

    local window_width = 50;

    for _, diag in ipairs(diags) do
        local tab = ' | '
        local msg = ''

        if diag.severity == 1 then
            msg = '\u{ea87} [' .. diag.lnum + 1 ..':' .. diag.col .. ']' .. tab .. severity[diag.severity] .. tab .. diag.message
        elseif diag.severity == 2 then
            msg = '\u{ea6c} [' .. diag.lnum + 1 ..':' .. diag.col .. ']' .. tab .. severity[diag.severity] .. tab .. diag.message
        elseif diag.severity == 3 then
            msg = '\u{e66a} [' .. diag.lnum + 1 ..':' .. diag.col .. ']' .. tab .. severity[diag.severity] .. tab .. diag.message
        else
            msg = '\u{f400} [' .. diag.lnum + 1 ..':' .. diag.col .. ']' .. tab .. severity[diag.severity] .. tab .. diag.message
        end

        if string.len(msg) > window_width then
            window_width = string.len(msg)
        end

        local diag_data = {
            msg = diag.message,
            severity = severity[diag.severity],
            line = diag.lnum + 1,
            col = diag.col
        }

        table.insert(diag_lines, removeNewLine(msg))
        table.insert(full_diag_data, diag_data) -- TODO: remove duplicate messages on the same line
    end

    if #diag_lines <= 0 then
        local msg = 'no errors found in file'
        table.insert(diag_lines, msg)
        window_width = string.len(msg);
    end

    local widow_opts = {
        window_width = window_width,
        window_height = #diag_lines,
    }

    showWindow(widow_opts)
    addHighlights()

    vim.api.nvim_buf_set_keymap(syntax_epee_buf_id, 'n', '<ESC>', '<cmd>lua CloseWindow()<CR>', { silent=false })
    vim.api.nvim_buf_set_keymap(syntax_epee_buf_id, 'n', '<CR>', '<cmd>lua SelectHint()<CR>', { silent=false })
end

function SyntaxEpee.setup()
    local nvim_version = vim.version()

    if nvim_version.minor <= 7 then
        vim.api.nvim_err_writeln('Incorrect nvim version in use, please use latest')
    end
end

return SyntaxEpee
