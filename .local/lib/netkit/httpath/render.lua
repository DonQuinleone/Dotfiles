local ui = require("netkit.ui")
local json = require("netkit.json")

local render = {}

local URL_CELL_LIMIT = 44
local SLOW_HOP_SECONDS = 1.0

local accent = ui.accent

local function clip(text)
    if #text <= URL_CELL_LIMIT then return text end
    return text:sub(1, URL_CELL_LIMIT - 1) .. "…"
end

local function code_cell(code)
    if code:match("^[45]") then return accent(code) end
    return code
end

local function time_cell(time)
    if not time then return "-" end
    local text = ("%.2fs"):format(time)
    if time >= SLOW_HOP_SECONDS then return accent(text) end
    return text
end

function render.text(report)
    ui.heading("HTTP path for " .. report.url)
    print("")
    local rows = {}
    for index, hop in ipairs(report.hops) do
        rows[#rows + 1] = {
            tostring(index),
            code_cell(hop.code),
            clip(hop.url),
            hop.ip or "-",
            hop.asn and "AS" .. hop.asn or "-",
            time_cell(hop.time),
        }
    end
    ui.render_table(
        { "#", "Code", "URL", "IP", "ASN", "Time" }, rows)
    local final = report.hops[#report.hops]
    print("")
    ui.heading("Final hop")
    ui.keyed("URL", final.url)
    ui.keyed("Status", final.code)
    ui.keyed("Server", final.server or "unknown")
    if final.scheme == "https" then
        ui.keyed("Transport", "https (encrypted)")
    else
        ui.keyed("Transport",
            accent((final.scheme or "http") .. " (plaintext)"))
    end
    if final.network then
        ui.keyed("Network", "AS" .. (final.asn or "?") ..
            " " .. final.network)
    end
    ui.keyed("CDN/WAF", final.cdn
        and accent(final.cdn .. " (origin is masked)")
        or "none detected (likely the origin)")
    if report.truncated then
        print("  " ..
            accent("stopped at the hop limit; chain continues"))
    end
end

function render.json(report)
    print(json.encode(report))
end

return render
