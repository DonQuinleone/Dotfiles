-- 1-9 live on the laptop panel until the dock's monitor
-- descriptions are captured; 11-19/21-29 join then.
for i = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "eDP-1",
        persistent = true,
        default = (i == 1),
    })
end

local scratchpads = {
    { name = "special:term",
      spawn = "ghostty --class=scratch-term" },
    { name = "special:mail",
      spawn = "ghostty --class=scratch-mail -e antiphon" },
}

for _, s in ipairs(scratchpads) do
    hl.workspace_rule({
        workspace = s.name,
        on_created_empty = s.spawn,
    })
end
