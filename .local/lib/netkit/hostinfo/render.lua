local net = require("netkit.net")
local tls_lib = require("netkit.tls")
local ui = require("netkit.ui")
local json = require("netkit.json")

local render = {}

local EXPIRY_WARNING_DAYS = 30

local VERIFY_LABELS = {
    [0] = "ok",
    [10] = "expired",
    [18] = "self-signed",
    [19] = "self-signed chain",
    [20] = "unknown issuer",
    [62] = "hostname mismatch",
}

local SNI_LABELS = {
    ["no host"] = "-",
    ["same"] = "same cert",
    ["required"] = "required (no cert)",
    ["different"] = "default cert differs",
}

local accent = ui.accent

local function ttl_text(ttl)
    return ttl and tostring(ttl) or ""
end

local function render_resolution(resolution)
    ui.heading("Resolution")
    local rows = {}
    for _, row in ipairs(resolution.rows) do
        local value = row.value
        if type(value) == "number" then
            value = value ..
                (value == 1 and " record" or " records")
        end
        rows[#rows + 1] =
            { row.name, row.type, value, ttl_text(row.ttl) }
    end
    ui.render_table({ "Name", "Type", "Answer", "TTL" }, rows)
    if resolution.apex then
        print("  records sit at the zone apex; any ALIAS/ANAME")
        print("  flattening is provider-side and invisible in DNS")
    end
end

local function rbl_cell(entry, listings)
    if not entry.rbl then return "n/a" end
    local hits = entry.rbl.hits
    if #hits == 0 then return "clean" end
    for _, hit in ipairs(hits) do
        listings[#listings + 1] =
            { entry.address, hit.zone, hit.code, hit.reason }
    end
    return accent(#hits .. " listed")
end

local function render_addresses(entries)
    ui.heading("Addresses")
    local rows, listings, tagged, refused = {}, {}, {}, {}
    for _, entry in ipairs(entries) do
        local rdns = "none"
        if entry.rdns then
            rdns = entry.rdns.name ..
                (entry.rdns.confirmed and " ✓" or " ✗")
        end
        local asn = entry.network
            and "AS" .. entry.network.asn or "unknown"
        if entry.highlight then
            asn = asn .. " " .. accent("◆ " .. entry.highlight)
            tagged[entry.highlight] = true
        end
        for _, zone in ipairs(entry.rbl
            and entry.rbl.refused or {}) do
            refused[zone] = true
        end
        rows[#rows + 1] = { entry.address, rdns, asn,
            entry.abuse, rbl_cell(entry, listings) }
    end
    ui.render_table(
        { "Address", "rDNS", "ASN", "Abuse", "RBLs" }, rows)
    for label in pairs(tagged) do
        print("  " .. accent("◆ " .. label) ..
            " network (from local highlights)")
    end
    local refused_names = {}
    for zone in pairs(refused) do
        refused_names[#refused_names + 1] = zone
    end
    if #refused_names > 0 then
        print("  (" .. table.concat(refused_names, ", ") ..
            ": refused, needs a direct resolver)")
    end
    if #listings > 0 then
        print("")
        ui.heading("Blacklist listings (" .. net.RBL_COUNT ..
            " checked)")
        ui.render_table(
            { "Address", "Blacklist", "Code", "Reason" },
            listings)
    end
end

local function render_networks(networks)
    ui.heading("Networks")
    local rows = {}
    for _, network in ipairs(networks) do
        rows[#rows + 1] = {
            network.prefix, "AS" .. network.asn, network.name,
            network.country, network.registry,
            network.allocated,
        }
    end
    ui.render_table({ "Prefix", "ASN", "Name", "CC", "Registry",
        "Allocated" }, rows)
end

local function verify_cell(verify)
    if not verify or not verify.code then return "unknown" end
    local label = VERIFY_LABELS[verify.code] or verify.message
    if label == "ok" then return "ok" end
    return accent(label)
end

local function sni_cell(sni)
    local label = SNI_LABELS[sni] or sni
    if sni ~= "same" and sni ~= "no host" then
        label = accent(label)
    end
    return label
end

local function render_certificate(certificate)
    print("")
    ui.heading("Certificate (" ..
        table.concat(certificate.addresses, ", ") .. ")")
    ui.keyed("Subject", certificate.subject or "unknown")
    ui.keyed("SANs", #certificate.sans > 0
        and table.concat(certificate.sans, ", ") or "none")
    ui.keyed("Issuer", certificate.issuer or "unknown")
    local expiry = certificate.not_after or "unknown"
    if certificate.days_left then
        local marker =
            certificate.days_left < EXPIRY_WARNING_DAYS
            and accent(" (!)") or ""
        expiry = ("%s (%d days%s)"):format(expiry,
            certificate.days_left, marker)
    end
    ui.keyed("Expires", expiry)
end

local function render_tls(tls)
    ui.heading("TLS (port " .. tls_lib.HTTPS_PORT .. ")")
    local rows = {}
    for _, probe in ipairs(tls.probes) do
        local row = { probe.address }
        if probe.protocols then
            for _, protocol in ipairs(probe.protocols) do
                row[#row + 1] =
                    protocol.supported and "yes" or "no"
            end
            row[#row + 1] = verify_cell(probe.verify)
            row[#row + 1] = sni_cell(probe.sni)
        else
            for _ in ipairs(tls_lib.PROTOCOL_LABELS) do
                row[#row + 1] = "-"
            end
            row[#row + 1] = "no TLS"
            row[#row + 1] = "-"
        end
        rows[#rows + 1] = row
    end
    local headers = { "Address" }
    for _, label in ipairs(tls_lib.PROTOCOL_LABELS) do
        headers[#headers + 1] = label
    end
    headers[#headers + 1] = "Verify"
    headers[#headers + 1] = "SNI"
    ui.render_table(headers, rows)
    for _, certificate in ipairs(tls.certificates) do
        render_certificate(certificate)
    end
end

local function dnssec_label(facts)
    if facts.ds and facts.servfail then
        return accent("broken (DS present, SOA SERVFAILs)")
    end
    if not facts.ds and not facts.signed then return "unsigned" end
    if not facts.ds then
        return "signed but no DS at the parent (chain incomplete)"
    end
    if not facts.signed then
        return accent("DS at parent but no RRSIG at the zone")
    end
    if facts.validated then
        return "signed (DS + RRSIG), resolver validates"
    end
    return "signed (DS + RRSIG); local resolver does not validate"
end

local function render_zone(zone)
    ui.heading("Zone " .. zone.name)
    for index, entry in ipairs(zone.ns) do
        local glue = table.concat(entry.addresses, " ")
        local value = entry.server ..
            (glue ~= "" and " (" .. glue .. ")" or "")
        if index == 1 and entry.ttl then
            value = value .. " ttl " .. entry.ttl
        end
        ui.keyed("NS", value)
    end
    if zone.soa then
        ui.keyed("SOA", ("%s, contact %s, serial %s ttl %s")
            :format(zone.soa.primary, zone.soa.contact,
                zone.soa.serial, ttl_text(zone.soa.ttl)))
    end
    local mail = {}
    for _, entry in ipairs(zone.mx) do
        mail[#mail + 1] =
            entry.preference .. " " .. entry.exchange
    end
    ui.keyed("MX", #mail > 0
        and table.concat(mail, ", ") or "none")
    ui.keyed("SPF", zone.spf or "none")
    ui.keyed("DMARC", zone.dmarc or "none")
    ui.keyed("CAA", #zone.caa > 0
        and table.concat(zone.caa, ", ") or "none")
    if zone.delegation then
        local delegation = zone.delegation
        if delegation.consistent then
            ui.keyed("Delegation", "consistent (" ..
                #delegation.zone .. " NS)")
        else
            ui.keyed("Delegation", accent("parent: " ..
                table.concat(delegation.parent, ", ") ..
                "; zone: " ..
                table.concat(delegation.zone, ", ")))
        end
    end
    ui.keyed("DNSSEC", dnssec_label(zone.dnssec))
    local blacklists = zone.blacklists
    if #blacklists.hits == 0 then
        ui.keyed("Blacklists", "clean (" ..
            net.DOMAIN_RBL_COUNT .. " checked)")
    end
    for _, hit in ipairs(blacklists.hits) do
        ui.keyed("Blacklists", accent(hit.zone .. " " ..
            hit.code .. (hit.reason ~= ""
                and "  " .. hit.reason or "")))
    end
    if #blacklists.refused > 0 then
        ui.keyed("", "(" ..
            table.concat(blacklists.refused, ", ") ..
            ": refused, needs a direct resolver)")
    end
end

local function render_registration(registration)
    ui.heading("Registration " .. registration.domain)
    ui.keyed("Registrar", registration.registrar)
    ui.keyed("Expires", registration.expires)
    ui.keyed("Status", registration.status)
end

function render.text(report)
    ui.heading("Target " .. report.target)
    local function section(renderer, data)
        if data == nil then return end
        if type(data) == "table" and next(data) == nil then
            return
        end
        print("")
        renderer(data)
    end
    section(render_resolution, report.resolution)
    section(render_addresses, report.addresses)
    section(render_networks, report.networks)
    section(render_tls, report.tls)
    section(render_zone, report.zone)
    section(render_registration, report.registration)
end

function render.json(report)
    print(json.encode(report))
end

return render
