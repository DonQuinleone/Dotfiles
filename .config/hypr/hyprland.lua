local source = debug.getinfo(1, "S").source:sub(2)
local root = source:match("(.*/)") .. "lua/"

local modules = {
    "env.lua",
    "monitors.lua",
    "input.lua",
    "look.lua",
    "workspaces.lua",
    "rules.lua",
    "binds.lua",
    "autostart.lua",
}

for _, module in ipairs(modules) do
    dofile(root .. module)
end
