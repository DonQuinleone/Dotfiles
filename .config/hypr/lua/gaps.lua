local actions = require("actions")

local NO_GAP = 0

-- Held rather than hardcoded, so the gaps the theme and the
-- layout modules choose are what comes back.
local saved = nil

local gaps = {}

function gaps.toggle()
    if saved ~= nil then
        hl.config({
            general = {
                gaps_in = saved.inner,
                gaps_out = saved.outer,
            },
        })
        saved = nil
        actions.notify("Gaps on")
        return
    end

    saved = {
        inner = hl.get_config("general:gaps_in"),
        outer = hl.get_config("general:gaps_out"),
    }
    hl.config({
        general = { gaps_in = NO_GAP, gaps_out = NO_GAP },
    })
    actions.notify("Gaps off")
end

return gaps
