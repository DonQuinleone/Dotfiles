local net = require("netkit.net")

local collect = {}

local PUBLIC_RESOLVERS = {
    { address = "1.1.1.1", label = "Cloudflare" },
    { address = "8.8.8.8", label = "Google" },
    { address = "9.9.9.9", label = "Quad9" },
}

local function serial_from(rows)
    for _, row in ipairs(rows) do
        if row.type == "SOA" then
            return row.rdata:match("^%S+%s+%S+%s+(%S+)")
        end
    end
end

local function answers_from(rows, types)
    local values = {}
    for _, row in ipairs(rows) do
        if types[row.type] then
            values[#values + 1] = row.rdata:lower()
        end
    end
    table.sort(values)
    return table.concat(values, " ")
end

local MIN_ROWS_TO_COMPARE = 2

local function probe(server, zone, name, types)
    local entry = {}
    if server then
        entry.serial = serial_from(
            net.answers_at(server, zone, "SOA"))
    else
        entry.serial = serial_from(net.answers(zone, "SOA"))
    end
    -- The SOA query doubles as a liveness probe: a server that
    -- returns no serial did not respond, and is left out of both
    -- comparisons rather than counted as agreeing.
    entry.responded = entry.serial ~= nil
    if not name then return entry end
    local rows = {}
    for type_ in pairs(types) do
        local answered = server
            and net.answers_at(server, name, type_)
            or net.answers(name, type_)
        for _, row in ipairs(answered) do
            rows[#rows + 1] = row
        end
    end
    entry.answers = answers_from(rows, types)
    return entry
end

-- An empty answer from a responding server is a real value and
-- must be able to disagree; only a non-responding server (nil)
-- is skipped. Fewer than two contributors means no verdict.
local function agreement(rows, field, role)
    local seen, count = nil, 0
    for _, row in ipairs(rows) do
        if (not role or row.role == role) and row.responded
            and row[field] ~= nil then
            count = count + 1
            if seen == nil then
                seen = row[field]
            elseif row[field] ~= seen then
                return false
            end
        end
    end
    if count < MIN_ROWS_TO_COMPARE then return nil end
    return true
end

function collect.report(target, types, notify)
    notify = notify or function() end
    local zone = net.find_zone(target)
    if not zone then
        return nil, "no zone with NS records above " .. target
    end
    local name = target ~= zone and target or nil
    local report = { target = target, zone = zone,
        compared_answers = name ~= nil, rows = {} }
    local servers = {}
    for _, entry in ipairs(net.typed_answers(zone, "NS")) do
        servers[#servers + 1] = {
            server = net.strip_dot(entry.rdata),
            role = "authoritative",
        }
    end
    table.sort(servers, function(a, b)
        return a.server < b.server
    end)
    for _, resolver in ipairs(PUBLIC_RESOLVERS) do
        servers[#servers + 1] = {
            server = resolver.address,
            label = resolver.label,
            role = "public",
        }
    end
    servers[#servers + 1] =
        { server = "local", role = "local" }
    for index, entry in ipairs(servers) do
        notify(("querying %d/%d (%s)"):format(index, #servers,
            entry.server))
        local queried = entry.role ~= "local" and entry.server
        local result = probe(queried, zone, name, types)
        report.rows[#report.rows + 1] = {
            server = entry.server,
            label = entry.label,
            role = entry.role,
            responded = result.responded,
            serial = result.serial,
            answers = result.answers,
        }
    end
    report.serials_agree =
        agreement(report.rows, "serial", "authoritative")
    if name then
        report.answers_agree =
            agreement(report.rows, "answers")
    end
    return report
end

return collect
