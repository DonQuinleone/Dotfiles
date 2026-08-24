local net = require("netkit.net")
local tls_lib = require("netkit.tls")

local collect = {}

local function load_highlights()
    local config_home = os.getenv("XDG_CONFIG_HOME")
        or ((os.getenv("HOME") or "") .. "/.config")
    local loader =
        loadfile(config_home .. "/hostinfo/highlights.lua")
    if not loader then return {} end
    local ok, rules = pcall(loader)
    if ok and type(rules) == "table" then return rules end
    return {}
end

-- Patterns come from the user's highlights.lua, so a malformed
-- one is pcall'd rather than allowed to abort the whole tool.
local function name_matches(name, pattern)
    local ok, hit = pcall(string.match, name, pattern)
    return ok and hit ~= nil
end

local function highlight_for(rules, asn, names)
    for _, rule in ipairs(rules) do
        for _, rule_asn in ipairs(rule.asns or {}) do
            if tostring(rule_asn) == tostring(asn) then
                return rule.label
            end
        end
        for _, pattern in ipairs(rule.patterns or {}) do
            for _, name in ipairs(names) do
                if name and name_matches(name, pattern) then
                    return rule.label
                end
            end
        end
    end
end

local function cname_after(answers, current)
    for _, row in ipairs(answers) do
        if row.owner:lower() == current:lower()
            and row.type == "CNAME" then
            return net.strip_dot(row.rdata), row.ttl
        end
    end
end

local function chain_of(answers, target)
    local rows, seen, chain = {}, {}, { target }
    local current = target
    while true do
        local next_name, ttl = cname_after(answers, current)
        if not next_name or seen[next_name] then break end
        rows[#rows + 1] = { name = current, type = "CNAME",
            value = next_name, ttl = ttl }
        seen[next_name] = true
        chain[#chain + 1] = next_name
        current = next_name
    end
    return rows, chain, current
end

local function addresses_of(answers, terminal)
    local rows, addresses = {}, {}
    for _, type_ in ipairs({ "A", "AAAA" }) do
        local count, ttl = 0, nil
        for _, row in ipairs(answers) do
            if row.owner:lower() == terminal:lower()
                and row.type == type_ then
                count = count + 1
                ttl = ttl or row.ttl
                addresses[#addresses + 1] = row.rdata
            end
        end
        if count > 0 then
            rows[#rows + 1] = { name = terminal, type = type_,
                value = count, ttl = ttl }
        end
    end
    return rows, addresses
end

local function resolution(target, zone)
    local answers = net.answers(target, "A")
    for _, row in ipairs(net.answers(target, "AAAA")) do
        answers[#answers + 1] = row
    end
    local chain_rows, chain, terminal = chain_of(answers, target)
    local address_rows, addresses =
        addresses_of(answers, terminal)
    for _, row in ipairs(address_rows) do
        chain_rows[#chain_rows + 1] = row
    end
    local apex = #chain_rows > 0
        and chain_rows[1].type ~= "CNAME" and target == zone
    return { rows = chain_rows, apex = apex or false },
        addresses, chain
end

local function address_entry(address, chain, rules)
    local entry = { address = address }
    local pointers = net.ptr_names(address)
    if #pointers > 0 then
        local confirmed = false
        for _, held in ipairs(net.host_addresses(pointers[1])) do
            if held:lower() == address:lower() then
                confirmed = true
            end
        end
        entry.rdns =
            { name = pointers[1], confirmed = confirmed }
    end
    entry.network = net.network_for(address)
    entry.abuse = net.abuse_contact(address)
    local hits, refused = net.rbl_results(address)
    if hits then
        entry.rbl = { hits = hits, refused = refused }
    end
    local names = {}
    if entry.rdns then names[#names + 1] = entry.rdns.name end
    for _, name in ipairs(chain) do names[#names + 1] = name end
    entry.highlight = highlight_for(rules,
        entry.network and entry.network.asn, names)
    return entry
end

local function networks_of(entries)
    local seen, networks = {}, {}
    for _, entry in ipairs(entries) do
        local network = entry.network
        if network and network.prefix ~= ""
            and not seen[network.prefix] then
            seen[network.prefix] = true
            networks[#networks + 1] = network
        end
    end
    return networks
end

local function tls(addresses, servername, notify)
    local probes, certificates, order = {}, {}, {}
    for index, address in ipairs(addresses) do
        notify(("tls %d/%d"):format(index, #addresses))
        local probe = tls_lib.survey(address, servername)
        local entry = { address = address }
        if probe then
            local certificate = probe.certificate
            local key = certificate.fingerprint or "?"
            if not certificates[key] then
                certificate.addresses = {}
                certificates[key] = certificate
                order[#order + 1] = certificate
            end
            local held = certificates[key].addresses
            held[#held + 1] = address
            entry.protocols = probe.protocols
            entry.verify = { code = probe.verify_code,
                message = probe.verify_message }
            entry.sni = probe.sni
            entry.fingerprint = certificate.fingerprint
        end
        probes[#probes + 1] = entry
    end
    return { probes = probes, certificates = order }
end

local function sorted_ns(zone)
    local rows = net.typed_answers(zone, "NS")
    table.sort(rows, function(a, b)
        return a.rdata < b.rdata
    end)
    local servers = {}
    for _, row in ipairs(rows) do
        local server = net.strip_dot(row.rdata)
        servers[#servers + 1] = {
            server = server,
            addresses = net.host_addresses(server),
            ttl = row.ttl,
        }
    end
    return servers
end

local function soa_of(zone)
    local row = net.typed_answers(zone, "SOA")[1]
    if not row then return nil end
    local primary, contact, serial =
        row.rdata:match("^(%S+)%s+(%S+)%s+(%S+)")
    return {
        primary = net.strip_dot(primary or ""),
        contact = net.strip_dot(contact or ""),
        serial = serial or "",
        ttl = row.ttl,
    }
end

local function first_txt(name, marker)
    for _, txt in ipairs(net.records(name, "TXT")) do
        local cleaned = net.unquote_txt(txt)
        if cleaned:lower():match(marker) then return cleaned end
    end
end

local function delegation_of(zone, ns)
    local delegated = net.delegated_ns(zone)
    if #delegated == 0 then return nil end
    local zone_servers = {}
    for _, entry in ipairs(ns) do
        zone_servers[#zone_servers + 1] = entry.server:lower()
    end
    table.sort(zone_servers)
    return {
        parent = delegated,
        zone = zone_servers,
        consistent = table.concat(delegated, ",")
            == table.concat(zone_servers, ","),
    }
end

local function zone_details(zone)
    local ns = sorted_ns(zone)
    local hits, refused = net.domain_rbl_results(zone)
    return {
        name = zone,
        ns = ns,
        soa = soa_of(zone),
        mx = net.mx_records(zone),
        spf = first_txt(zone, "^v=spf1"),
        dmarc = first_txt("_dmarc." .. zone, "^v=dmarc1"),
        caa = net.records(zone, "CAA"),
        delegation = delegation_of(zone, ns),
        dnssec = net.dnssec_facts(zone),
        blacklists = { hits = hits, refused = refused },
    }
end

function collect.report(target, literal, sections, notify)
    notify = notify or function() end
    local rules = load_highlights()
    local report = { target = target }
    local zone
    if not literal then
        notify("resolving " .. target)
        zone = net.find_zone(target)
    end
    local addresses, chain = { target }, { target }
    if not literal then
        local resolved
        report.resolution, resolved, chain =
            resolution(target, zone)
        if #resolved == 0 then
            return nil, target .. " does not resolve"
        end
        addresses = resolved
        if not sections.dns then report.resolution = nil end
    end
    if sections.net then
        report.addresses = {}
        for index, address in ipairs(addresses) do
            notify(("addresses %d/%d"):format(index,
                #addresses))
            report.addresses[#report.addresses + 1] =
                address_entry(address, chain, rules)
        end
        report.networks = networks_of(report.addresses)
    end
    if sections.tls then
        report.tls = tls(addresses,
            not literal and target or nil, notify)
    end
    if sections.dns and zone then
        notify("zone " .. zone)
        report.zone = zone_details(zone)
    end
    if sections.reg and zone then
        notify("registration")
        report.registration = net.registration(zone)
    end
    return report
end

return collect
