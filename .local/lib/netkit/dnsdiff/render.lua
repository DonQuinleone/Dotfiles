local ui = require("netkit.ui")
local json = require("netkit.json")

local render = {}

local accent = ui.accent

local ROLE_LABELS = {
    authoritative = "auth",
    public = "public",
    ["local"] = "local",
}

function render.text(report)
    ui.heading("DNS for " .. report.target ..
        " (zone " .. report.zone .. ")")
    print("")
    local rows = {}
    for _, row in ipairs(report.rows) do
        local server = row.server
        if row.label then
            server = server .. " (" .. row.label .. ")"
        end
        rows[#rows + 1] = {
            server,
            ROLE_LABELS[row.role] or row.role,
            row.serial or accent("no answer"),
            row.answers,
        }
    end
    local headers = { "Server", "Role", "Serial" }
    if report.compared_answers then
        headers[#headers + 1] = "Answers"
    end
    ui.render_table(headers, rows)
    if report.serials_agree == true then
        print("  authoritative serials agree")
    elseif report.serials_agree == false then
        print("  " ..
            accent("authoritative serials differ (stale NS?)"))
    else
        print("  " .. accent(
            "too few nameservers answered to compare serials"))
    end
    if report.answers_agree == true then
        print("  answers agree everywhere")
    elseif report.answers_agree == false then
        print("  " .. accent(
            "answers differ (propagation or split view)"))
    elseif report.compared_answers then
        print("  " .. accent(
            "too few servers answered to compare records"))
    end
end

function render.json(report)
    print(json.encode(report))
end

return render
