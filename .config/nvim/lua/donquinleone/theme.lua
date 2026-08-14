local FALLBACK_COLOURSCHEME = "kanagawa"
local FALLBACK_BACKGROUND = "dark"
local BACKGROUNDS = { dark = true, light = true }

local M = {}

local function state_file()
    local state_home = vim.env.XDG_STATE_HOME
    if state_home == nil or state_home == "" then
        state_home = vim.env.HOME .. "/.local/state"
    end
    return state_home .. "/theme/nvim.lua"
end

local function read_state()
    local path = state_file()
    if vim.fn.filereadable(path) == 0 then
        return nil, nil
    end
    local ok, state = pcall(dofile, path)
    if not ok then
        return nil, tostring(state)
    end
    if type(state) ~= "table" then
        return nil, path .. " did not return a table"
    end
    return state, nil
end

local function warn(message)
    vim.notify("theme: " .. message, vim.log.levels.WARN)
end

local function background_of(state)
    if BACKGROUNDS[state.background] then
        return state.background
    end
    return FALLBACK_BACKGROUND
end

local function apply_fallback()
    vim.o.background = FALLBACK_BACKGROUND
    pcall(vim.cmd.colorscheme, FALLBACK_COLOURSCHEME)
    return vim.g.colors_name
end

function M.apply()
    local state, err = read_state()
    if err ~= nil then
        warn(err)
    end
    state = state or {}

    vim.o.background = background_of(state)
    local wanted = state.colourscheme
    if wanted == nil then
        return apply_fallback()
    end
    if pcall(vim.cmd.colorscheme, wanted) then
        return vim.g.colors_name
    end

    warn(("colourscheme %q is unavailable"):format(wanted))
    return apply_fallback()
end

return M
