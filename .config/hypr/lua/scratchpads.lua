-- A pad is a floating panel over the desktop, and its panes
-- divide that panel's width in the order they are written.
-- Shares are of the panel rather than of the screen, and a pane
-- with no command of its own is given a terminal.
--
-- A class is matched whole, so a name that is not the entire
-- application id matches nothing and says nothing about it.
-- Brave builds a web app's id out of its URL, which is why the
-- two sit next to each other here: neither can be changed
-- alone.
local pads = {
    {
        name   = "term",
        width  = 0.80,
        height = 0.82,
        panes = {
            {
                class = "com.donquinleone.scratchterm",
                share = 1,
            },
        },
    },
    {
        name   = "comms",
        width  = 0.96,
        height = 0.94,
        panes = {
            {
                class   = "com.slack.Slack",
                command = "flatpak run com.slack.Slack",
                share   = 2 / 3,
            },
            {
                class   = "TeamSpeak 3",
                command = "teamspeak3",
                share   = 1 / 3,
            },
        },
    },
    {
        name   = "mail",
        width  = 0.96,
        height = 0.94,
        panes = {
            {
                class   = "brave-mail.google.com"
                    .. "__mail_u_0_-Default",
                command = "brave-origin --app="
                    .. "https://mail.google.com/mail/u/0/",
                share   = 2 / 3,
            },
            {
                class   = "brave-calendar.google.com"
                    .. "__calendar_u_0_r-Default",
                command = "brave-origin --app="
                    .. "https://calendar.google.com/calendar/u/0/r",
                share   = 1 / 3,
            },
        },
    },
    {
        name   = "secrets",
        width  = 0.96,
        height = 0.94,
        panes = {
            {
                class   = "1password",
                command = "flatpak run "
                    .. "com.onepassword.OnePassword",
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

-- Ghostty only honours --class when it is a valid GTK
-- application id and it is not folding into a running instance.
local function command_for(pane)
    if pane.command then
        return pane.command
    end
    return "ghostty --gtk-single-instance=false --class="
        .. pane.class
end

-- Starting only what is missing is what lets a pad be opened
-- while one of its applications is already running without a
-- second copy of it appearing beside the first.
local function start_missing(pad)
    for _, pane in ipairs(pad.panes) do
        if #hl.get_windows({ class = pane.class }) == 0 then
            hl.exec_cmd(command_for(pane))
        end
    end
end

local scratchpads = {}

scratchpads.pads = pads

function scratchpads.workspace_of(pad)
    return "special:" .. pad.name
end

function scratchpads.toggle(pad)
    return function()
        start_missing(pad)
        hl.dispatch(hl.dsp.workspace.toggle_special(pad.name))
    end
end

return scratchpads
