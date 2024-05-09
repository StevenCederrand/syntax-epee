local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local SyntaxEpee = {}

SyntaxEpee.namespace = vim.api.nvim_create_namespace("win_err")

local severity = {
  [1] = "ERROR",
  [2] = "WARN",
  [3] = "INFO",
  [4] = "HINT",
}

local function getDiags()
    local ok, diags = pcall(vim.diagnostic.get, 0)

    if not ok then
        error('unable to get diagnostics')
        return
    end

    return diags
end

local function removeLastLine(str)
    local pos = 0
    while true do
        local nl = string.find(str, "\n", pos, true)
        if not nl then break end
        pos = nl + 1
    end
    if pos == 0 then return str end
    return string.sub(str, 1, pos - 2)
end

function SyntaxEpee.stab(opts)
    opts = opts or {}

    local diags = getDiags()

    if diags == nil then
        return
    end

    local diagnostic_lines = {}
    local full_diag_data = {}

    table.sort(diags, function(a,b) return a.severity < b.severity end)

    local t_width = 10;
    for _, diag in ipairs(diags) do
        local tab = " | "
        local msg = ""

        if diag.severity == 1 then
            msg = "\u{ea87} [" .. diag.lnum + 1 ..":" .. diag.col .. "]" .. tab .. severity[diag.severity] .. tab .. diag.message
        elseif diag.severity == 2 then
            msg = "\u{ea6c} [" .. diag.lnum + 1 ..":" .. diag.col .. "]" .. tab .. severity[diag.severity] .. tab .. diag.message
        elseif diag.severity == 3 then
            msg = "\u{e66a} [" .. diag.lnum + 1 ..":" .. diag.col .. "]" .. tab .. severity[diag.severity] .. tab .. diag.message
        else
            msg = "\u{f400} [" .. diag.lnum + 1 ..":" .. diag.col .. "]" .. tab .. severity[diag.severity] .. tab .. diag.message
        end

        if string.len(msg) > t_width then
            t_width = string.len(msg)
        end

        local diag_data = {
            msg = diag.message,
            severity = severity[diag.severity],
            line = diag.lnum + 1,
            col = diag.col
        }

        table.insert(diagnostic_lines, removeLastLine(msg))
        table.insert(full_diag_data, diag_data)
    end

    pickers.new(opts, {
        prompt_title = "Syntax Épée",
        finder = finders.new_table {
            results = diagnostic_lines
        },
        layout_config = {
            width = t_width + 3,
        },
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local currentLine = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if currentLine == nil or currentLine.index < 0 or #full_diag_data <= 0 then
                    return
                end
                local err_line = full_diag_data[currentLine.index]
                pcall(vim.api.nvim_win_set_cursor, 0, { err_line.line, err_line.col })
            end)
            return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

function SyntaxEpee.setup()
    if vim.fn.has("nvim-0.7.0") ~= 1 then
        vim.api.nvim_err_writeln("Incorrect nvim version in use, please use lates")
    end
end

return SyntaxEpee
