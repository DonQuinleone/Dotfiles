local tls_lib = require("netkit.tls")
local ui = require("netkit.ui")
local json = require("netkit.json")
local maildiag_collect = require("netkit.maildiag.collect")

local render = {}

local EXPIRY_WARNING_DAYS = tls_lib.EXPIRY_WARNING_DAYS
local ADDRESS_CELL_LIMIT = 2

local accent = ui.accent

local function address_cell(addresses)
    if #addresses <= ADDRESS_CELL_LIMIT then
        return table.concat(addresses, " ")
    end
    local shown = {}
    for index = 1, ADDRESS_CELL_LIMIT do
        shown[index] = addresses[index]
    end
    return table.concat(shown, " ") ..
        " (+" .. (#addresses - ADDRESS_CELL_LIMIT) .. ")"
end

local function render_spf(spf)
    local records = spf.records
    if #records == 0 then
        ui.keyed("SPF", accent("missing"))
        return
    end
    if #records > 1 then
        ui.keyed("SPF", accent(#records ..
            " records (permerror, only one is allowed)"))
    end
    for _, record in ipairs(records) do
        local value = record
        if record:lower():match("%+all") then
            value = value .. " " .. accent("(+all allows anyone)")
        end
        ui.keyed("SPF", value)
    end
end

local function render_dmarc(dmarc)
    if not dmarc then
        ui.keyed("DMARC", accent("missing"))
        return
    end
    ui.keyed("DMARC", dmarc.record)
    local notes = {}
    if dmarc.policy == "none" then
        notes[#notes + 1] = accent("p=none (monitoring only)")
    end
    if dmarc.percent and dmarc.percent < 100 then
        notes[#notes + 1] =
            accent("pct=" .. dmarc.percent .. " (partial)")
    end
    if not dmarc.reporting then
        notes[#notes + 1] = "no rua reporting address"
    end
    if #notes > 0 then
        ui.keyed("", table.concat(notes, "; "))
    end
end

local function render_policy(report)
    ui.heading("Policy " .. report.domain)
    render_spf(report.spf)
    render_dmarc(report.dmarc)
    if report.mta_sts then
        ui.keyed("MTA-STS", report.mta_sts.mode
            and "mode " .. report.mta_sts.mode
            or report.mta_sts.record)
    else
        ui.keyed("MTA-STS", "none")
    end
    ui.keyed("TLS-RPT", report.tlsrpt or "none")
end

local function render_dkim(selectors)
    ui.heading("DKIM")
    if #selectors == 0 then
        ui.keyed("Selectors", accent("none of " ..
            maildiag_collect.DKIM_SELECTOR_COUNT ..
            " common selectors answered"))
        return
    end
    ui.keyed("Selectors", table.concat(selectors, ", "))
end

local function starttls_cell(starttls)
    if not starttls then
        return accent("none")
    end
    local label = tls_lib.verify_label(starttls.verify_code,
        starttls.verify_message)
    if label ~= "ok" then return accent(label) end
    if starttls.days_left
        and starttls.days_left < EXPIRY_WARNING_DAYS then
        return accent(("ok, %d days left"):format(
            starttls.days_left))
    end
    return "ok"
end

local function rbl_mx_cell(entry)
    if not entry.rbl then return "n/a" end
    if #entry.rbl.hits > 0 then
        return accent(#entry.rbl.hits .. " listed")
    end
    if #entry.rbl.refused > 0 then return accent("refused") end
    return "clean"
end

local function render_mx(report)
    ui.heading("MX")
    if #report.mx == 0 then
        print("  no MX records and no fallback address")
        return
    end
    local rows = {}
    for _, entry in ipairs(report.mx) do
        local exchange = entry.exchange ..
            (entry.implicit and " (implicit)" or "")
        rows[#rows + 1] = {
            tostring(entry.preference), exchange,
            address_cell(entry.addresses),
            entry.rdns or "none",
            starttls_cell(entry.starttls),
            entry.dane and "yes" or "no",
            rbl_mx_cell(entry),
        }
    end
    ui.render_table({ "Pref", "Exchange", "Addresses", "rDNS",
        "STARTTLS", "DANE", "RBLs" }, rows)
    for _, entry in ipairs(report.mx) do
        if entry.banner ~= "" then
            ui.keyed(entry.exchange, entry.banner)
        end
    end
    for _, entry in ipairs(report.mx) do
        for _, hit in ipairs(entry.rbl and entry.rbl.hits
            or {}) do
            ui.keyed(entry.exchange, accent(hit.zone .. " " ..
                hit.code))
        end
        local refused = entry.rbl and entry.rbl.refused or {}
        if #refused > 0 then
            ui.keyed(entry.exchange, "(" ..
                table.concat(refused, ", ") ..
                ": refused, needs a direct resolver)")
        end
    end
end

function render.text(report)
    ui.heading("Mail for " .. report.domain)
    if report.spf then
        print("")
        render_policy(report)
    end
    if report.dkim then
        print("")
        render_dkim(report.dkim)
    end
    if report.mx then
        print("")
        render_mx(report)
    end
end

function render.json(report)
    print(json.encode(report))
end

return render
