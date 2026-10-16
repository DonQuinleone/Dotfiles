local state = {}

local configured = os.getenv("XDG_STATE_HOME") or ""

state.root = configured ~= "" and configured
    or (os.getenv("HOME") .. "/.local/state")

function state.writer(relative)
    local path = state.root .. "/" .. relative
    os.execute("mkdir -p '" .. path:match("(.*)/") .. "'")
    return io.open(path, "w")
end

return state
