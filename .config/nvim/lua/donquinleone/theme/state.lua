local FILE_NAME = "nvim.lua"
local STATE_SUBDIRECTORY = "/donbox/current"
local DEFAULT_STATE_HOME = "/.local/state"

local M = { file_name = FILE_NAME }

local function state_home()
    local home = vim.env.XDG_STATE_HOME
    if home == nil or home == "" then
        return vim.env.HOME .. DEFAULT_STATE_HOME
    end
    return home
end

function M.directory()
    return state_home() .. STATE_SUBDIRECTORY
end

function M.path()
    return M.directory() .. "/" .. FILE_NAME
end

function M.read()
    local path = M.path()
    if vim.fn.filereadable(path) == 0 then
        return nil, path .. " has not been generated yet"
    end
    local ok, state = pcall(dofile, path)
    if not ok then
        return nil, tostring(state)
    end
    if type(state) ~= "table" then
        return nil, path .. " did not return a table"
    end
    if type(state.ui) ~= "table" or type(state.text) ~= "table" then
        return nil, path .. " is missing its colour tables"
    end
    return state, nil
end

return M
