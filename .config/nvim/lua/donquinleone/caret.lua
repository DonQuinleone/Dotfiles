local uv = vim.uv or vim.loop

local socket = (vim.env.XDG_RUNTIME_DIR or "")
    .. "/caret-follow.sock"

local pipe
local ready = false

local function disconnect()
    if pipe and not pipe:is_closing() then
        pipe:close()
    end
    pipe = nil
    ready = false
end

local function connect()
    if pipe or vim.env.XDG_RUNTIME_DIR == nil then
        return
    end
    if uv.fs_stat(socket) == nil then
        return
    end
    pipe = uv.new_pipe(false)
    pipe:connect(socket, function(err)
        if err then
            disconnect()
        else
            ready = true
        end
    end)
end

local function report()
    connect()
    if not ready then
        return
    end
    local payload = vim.json.encode({
        row = vim.fn.screenrow(),
        col = vim.fn.screencol(),
        lines = vim.o.lines,
        columns = vim.o.columns,
    })
    pipe:write(payload .. "\n", function(err)
        if err then
            disconnect()
        end
    end)
end

vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "InsertEnter" },
    { callback = report })

vim.api.nvim_create_autocmd("VimLeavePre", { callback = disconnect })
