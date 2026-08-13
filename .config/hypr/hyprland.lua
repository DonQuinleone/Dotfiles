local home = os.getenv("HOME")
local conf = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local root = conf .. "/hypr/lua/"

local modules = {
    "env.lua",
    "monitors.lua",
    "input.lua",
    "look.lua",
    "workspaces.lua",
    "rules.lua",
    "binds.lua",
}

for _, module in ipairs(modules) do
    dofile(root .. module)
end
