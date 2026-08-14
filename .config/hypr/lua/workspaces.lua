-- 1-9 live on the laptop panel until the dock's monitor
-- descriptions are captured; 11-19/21-29 join then.
for index = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(index),
        monitor = "eDP-1",
        persistent = true,
        default = (index == 1),
    })
end

-- Ghostty only honours --class when it is a valid GTK
-- application id and it is not folding into a running
-- instance, and -e swallows every argument after it.
local scratchpads = {
    { workspace = "special:term",
      class = "com.donquinleone.scratchterm" },
    { workspace = "special:mail",
      class = "com.donquinleone.scratchmail",
      exec = "antiphon" },
}

for _, pad in ipairs(scratchpads) do
    local command = "ghostty --gtk-single-instance=false --class="
        .. pad.class
    if pad.exec then
        command = command .. " -e " .. pad.exec
    end
    hl.workspace_rule({
        workspace = pad.workspace,
        on_created_empty = command,
    })
end

return scratchpads
