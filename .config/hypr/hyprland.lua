local source = debug.getinfo(1, "S").source:sub(2)
local root = source:match("(.*/)") .. "lua/"

local config = os.getenv("XDG_CONFIG_HOME")
    or (os.getenv("HOME") .. "/.config")

package.path = root .. "?.lua;"
    .. config .. "/donbox/?.lua;"
    .. package.path

local modules = {
    "env",
    "monitors",
    "input",
    "look",
    "workspaces",
    "scratchpads",
    "rules",
    "binds",
    "switches",
    "reload",
    "apply",
    "autostart",
}

for _, module in ipairs(modules) do
    require(module)
end
