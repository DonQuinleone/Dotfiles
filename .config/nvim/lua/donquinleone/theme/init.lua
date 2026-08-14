local groups = require("donquinleone.theme.groups")
local state = require("donquinleone.theme.state")

local COLOURSCHEME = "palette"
local SETTLE_MILLISECONDS = 40
local TERMINAL_PREFIX = "terminal_color_"

local M = {}

local watcher

local function warn(message)
    vim.notify("theme: " .. message, vim.log.levels.WARN)
end

local function paint_terminal(ui, text)
    for slot, colour in pairs(groups.terminal(ui, text)) do
        vim.g[TERMINAL_PREFIX .. slot] = colour
    end
end

function M.paint()
    local current, err = state.read()
    if current == nil then
        return warn(err)
    end
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = COLOURSCHEME
    for name, spec in pairs(groups.build(current.ui, current.text)) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    paint_terminal(current.ui, current.text)
end

function M.apply()
    local current, err = state.read()
    if current == nil then
        return warn(err)
    end
    vim.o.background = current.background
    vim.cmd.colorscheme(COLOURSCHEME)
end

function M.watch()
    if watcher ~= nil then
        return
    end
    local directory = state.directory()
    if vim.fn.isdirectory(directory) == 0 then
        return
    end
    local queued = false
    local function repaint()
        queued = false
        M.apply()
    end
    watcher = (vim.uv or vim.loop).new_fs_event()
    watcher:start(directory, {}, function(err, name)
        if err ~= nil or name ~= state.file_name or queued then
            return
        end
        queued = true
        vim.defer_fn(repaint, SETTLE_MILLISECONDS)
    end)
end

return M
