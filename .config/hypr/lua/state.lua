local state = {}

state.root = os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")

function state.writer(relative)
    local path = state.root .. "/" .. relative
    os.execute("mkdir -p '" .. path:match("(.*)/") .. "'")
    return io.open(path, "w")
end

return state
