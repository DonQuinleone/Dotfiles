local ui = require("netkit.ui")
local json = require("netkit.json")

local render = {}

local BANNER_CELL_LIMIT = 48

local accent = ui.accent

local function clip(banner)
    if #banner <= BANNER_CELL_LIMIT then return banner end
    return banner:sub(1, BANNER_CELL_LIMIT - 1) .. "…"
end

function render.text(report)
    ui.heading("Ports on " .. report.target ..
        " (" .. report.address .. ")")
    print("")
    local rows = {}
    for _, row in ipairs(report.rows) do
        if row.open then
            rows[#rows + 1] = {
                tostring(row.port), row.service,
                accent("open"), clip(row.banner),
            }
        end
    end
    if #rows == 0 then
        print("  no probed port accepted a connection")
        return
    end
    ui.render_table({ "Port", "Service", "State", "Banner" },
        rows)
    local closed = 0
    for _, row in ipairs(report.rows) do
        if not row.open then closed = closed + 1 end
    end
    print("  " .. #rows .. " open, " .. closed ..
        " closed or filtered")
end

function render.json(report)
    print(json.encode(report))
end

return render
