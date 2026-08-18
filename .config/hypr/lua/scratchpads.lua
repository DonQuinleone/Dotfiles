local apps = require("apps")

local ARRANGE_DELAY_MS = 200

local donbox = os.getenv("HOME") .. "/.local/bin/donbox"

-- A pad is a workspace of its own laid over the desktop, and its
-- panes divide it in the order they are written. They are tiled
-- rather than each one placed, so the gaps, and the switch that
-- turns them off, reach a pad as they reach anywhere else.
--
-- A class is matched whole, so a name that is not the entire
-- application id matches nothing and says nothing about it.
local pads = {
    {
        name = "term",
        panes = {
            {
                class = apps.classes.scratchpad,
                share = 1,
            },
        },
    },
    {
        name = "comms",
        panes = {
            {
                class   = "com.slack.Slack",
                command = "flatpak run com.slack.Slack",
                share   = 2 / 3,
            },
            {
                class   = "TeamSpeak 3",
                command = "env QT_SCALE_FACTOR=1.5 teamspeak3",
                share   = 1 / 3,
            },
        },
    },
    {
        name = "secrets",
        panes = {
            {
                class   = "1password",
                command = "1password",
                share   = 2 / 3,
            },
            {
                class   = "com.yubico.yubioath",
                command = "flatpak run com.yubico.yubioath",
                share   = 1 / 3,
            },
        },
    },
}

local function workspace_of(pad)
    return "special:" .. pad.name
end

local function command_for(pane)
    if pane.command then
        return pane.command
    end
    return donbox .. " term --class " .. pane.class
end

local function windows_for(pane)
    return hl.get_windows({ class = pane.class })
end

-- A program can be running with no window of its own yet, or
-- none left, and starting a second copy of it fails rather than
-- filling the pane.
local function start_missing(pad)
    for _, pane in ipairs(pad.panes) do
        hl.exec_cmd(donbox .. " pad-run '" .. pane.class
            .. "' -- " .. command_for(pane))
    end
end

-- A shown pad does not become the active workspace: the one it
-- covers stays active and the monitor carries the pad alongside
-- it, so asking for the active workspace answers about the wrong
-- one.
local function shown_special()
    local monitor = hl.get_active_monitor()
    if monitor == nil then
        return nil
    end
    local special = monitor.active_special_workspace
    if special == nil or special == false then
        return nil
    end
    return special
end

local function showing(pad)
    local special = shown_special()
    return special ~= nil and special.name == workspace_of(pad)
end

-- The master layout keeps one share per workspace, so the split
-- belongs to the pad rather than to the whole session, and the
-- first pane is moved into the master position so the wide side
-- is always the same window. A layout message lands on whichever
-- workspace is focused, which is why none is sent unless the pad
-- is the one on screen.
-- Which window holds the master area is read from where it sits
-- rather than asked for after a dispatch, since a focus sent and
-- a focus answered for are not the same moment.
local function master_window(pad)
    local best
    for _, window in
        ipairs(hl.get_workspace_windows(workspace_of(pad))) do
        if not window.floating
            and (best == nil or window.at.x < best.at.x) then
            best = window
        end
    end
    return best
end

local function on_pad(pad, window)
    return window ~= nil and window.workspace ~= nil
        and window.workspace.name == workspace_of(pad)
end

local function arrange(pad)
    if #pad.panes < 2 or not showing(pad) then
        return
    end
    local first = windows_for(pad.panes[1])[1]
    local master = master_window(pad)
    if first == nil or master == nil then
        return
    end
    local focused = hl.get_active_window()
    -- Focusing into the pad is what puts the messages that
    -- follow on its workspace rather than on the one behind it.
    hl.dispatch(hl.dsp.focus({
        window = "address:" .. first.address,
    }))
    if master.address ~= first.address then
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
    end
    hl.dispatch(hl.dsp.layout(string.format(
        "mfact exact %.4f", pad.panes[1].share)))
    -- Arranging is about the layout, not about focus.
    if on_pad(pad, focused)
        and focused.address ~= first.address then
        hl.dispatch(hl.dsp.focus({
            window = "address:" .. focused.address,
        }))
    end
end

local function pad_on_screen()
    local special = shown_special()
    if special == nil then
        return nil
    end
    for _, pad in ipairs(pads) do
        if special.name == workspace_of(pad) then
            return pad
        end
    end
    return nil
end

local function pad_owns(pad, window)
    for _, pane in ipairs(pad.panes) do
        if pane.class == window.class then
            return true
        end
    end
    return false
end

-- A window opened over a pad is work of its own, so it
-- goes behind the pad; a floating one is a dialog and
-- belongs to whatever opened it.
local function on_window_open(window)
    local pad = pad_on_screen()
    if pad == nil or window == nil or window.floating then
        return
    end
    if pad_owns(pad, window) then
        arrange(pad)
        return
    end
    local monitor = hl.get_active_monitor()
    local behind = monitor ~= nil and monitor.active_workspace
    if behind then
        hl.dispatch(hl.dsp.window.move({
            window = "address:" .. window.address,
            workspace = behind.name,
        }))
    end
    hl.dispatch(hl.dsp.workspace.toggle_special(pad.name))
end

for _, pad in ipairs(pads) do
    hl.workspace_rule({
        workspace = workspace_of(pad),
        layout = "master",
    })
    for _, pane in ipairs(pad.panes) do
        hl.window_rule({
            match = { class = pane.class },
            workspace = workspace_of(pad) .. " silent",
        })
    end
end

hl.on("window.open", on_window_open)

local scratchpads = {}

scratchpads.pads = pads

function scratchpads.toggle(pad)
    return function()
        start_missing(pad)
        hl.dispatch(hl.dsp.workspace.toggle_special(pad.name))
        hl.timer(function()
            arrange(pad)
        end, { timeout = ARRANGE_DELAY_MS, type = "oneshot" })
    end
end

return scratchpads
