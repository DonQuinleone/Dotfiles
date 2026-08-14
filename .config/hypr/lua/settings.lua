-- The desktop settings app writes this file; it is absent
-- until the app has changed something for the first time.
local state = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

local path = state .. "/hypr/settings.lua"

local settings = {}

function settings.load()
    local read, saved = pcall(dofile, path)
    if not read or type(saved) ~= "table" then
        return {}
    end
    return saved
end

return settings
