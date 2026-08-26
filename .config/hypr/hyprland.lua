local here = debug.getinfo(1, "S").source:sub(2):match("(.*)/")

local MODULES = {
    "env", "input", "look", "monitors", "rules",
    "actions", "gaps", "layouts", "binds", "autostart",
}

package.path = here .. "/lua/?.lua;" .. package.path

for _, name in ipairs(MODULES) do
    package.loaded[name] = nil
end

require("env")
require("input")
require("look")
require("monitors")
require("rules")
require("binds")
require("autostart")
