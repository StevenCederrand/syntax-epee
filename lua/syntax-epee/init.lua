local SyntaxEpee = {}

SyntaxEpee.namespace = vim.api.nvim_create_namespace("win_err")

local severity = { -- NOTE: Add color based on warning/error/info would be cool
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

--local function removeLastLine(str)
--    local pos = 0
--    while true do
--        local nl = string.find(str, "\n", pos, true)
--        if not nl then break end
--        pos = nl + 1
--    end
--    if pos == 0 then return str end
--    return string.sub(str, 1, pos - 2)
--end

function SyntaxEpee.stab(opts)
    opts = opts or {}

    local diags = getDiags()
    local diagnostic_lines = {}
    local full_diag_data = {}

    if diags == nil then
        return
    end

    table.sort(diags, function(a,b) return a.severity < b.severity end)

    local window_width = 50;
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

        if string.len(msg) > window_width then
            window_width = string.len(msg)
        end

        local diag_data = {
            msg = diag.message,
            severity = severity[diag.severity],
            line = diag.lnum + 1,
            col = diag.col
        }

        table.insert(diagnostic_lines, msg)--removeLastLine(msg))
        table.insert(full_diag_data, diag_data) -- NOTE: remove duplicate messages
    end


     if #diagnostic_lines <= 0 then
         local msg = "no errors found in file"
         table.insert(diagnostic_lines, msg)
         window_width = string.len(msg) + 4;
     end

    print(vim.inspect(diagnostic_lines))
    -- print(vim.inspect(full_diag_data))
end

function SyntaxEpee.setup()
    local nvim_version = vim.version()

    if nvim_version.minor <= 7 then
        vim.api.nvim_err_writeln("Incorrect nvim version in use, please use latest")
    end

end

return SyntaxEpee
