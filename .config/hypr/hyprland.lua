local source = debug.getinfo(1, "S").source:sub(2)
local root = source:match("(.*/)") .. "lua/"

package.path = root .. "?.lua;" .. package.path

local modules = {
    "env",
    "monitors",
    "input",
    "look",
    "workspaces",
    "rules",
    "binds",
    "autostart",
}

for _, module in ipairs(modules) do
    require(module)
end
