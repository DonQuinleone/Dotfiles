local net = {}

local DIG_TIMEOUT_SECONDS = 2
local DIG_TRIES = 1
local RDAP_TIMEOUT_SECONDS = 8
local IPV6_GROUP_COUNT = 8
local CYMRU_ORIGIN_V4_ZONE = "origin.asn.cymru.com"
local CYMRU_ORIGIN_V6_ZONE = "origin6.asn.cymru.com"
local CYMRU_ASN_ZONE = "asn.cymru.com"
local ABUSIX_CONTACT_ZONE = "abuse-contacts.abusix.zone"
local RDAP_BOOTSTRAP_URL = "https://rdap.org"

net.REQUIRED_TOOLS = { "dig", "curl", "jq", "openssl", "timeout" }

local RBL_ZONES = {
    "zen.spamhaus.org",
    "bl.spamcop.net",
    "b.barracudacentral.org",
    "psbl.surriel.com",
    "dnsbl.dronebl.org",
    "dnsbl-1.uceprotect.net",
    "spam.spamrats.com",
}
net.RBL_COUNT = #RBL_ZONES

local DOMAIN_RBL_ZONES = {
    "dbl.spamhaus.org",
    "multi.surbl.org",
}
net.DOMAIN_RBL_COUNT = #DOMAIN_RBL_ZONES

function net.quote(word)
    return "'" .. tostring(word):gsub("'", "'\\''") .. "'"
end
local quote = net.quote

function net.run(command)
    local pipe = io.popen(command)
    if not pipe then return "" end
    local output = pipe:read("*a") or ""
    pipe:close()
    return output
end
local run = net.run

local function lines_of(text)
    local result = {}
    for line in text:gmatch("[^\n]+") do
        result[#result + 1] = line
    end
    return result
end

local function fields_of(line)
    local result = {}
    for field in line:gmatch("%S+") do
        result[#result + 1] = field
    end
    return result
end

local function split_pipes(text)
    local result = {}
    for part in (text .. "|"):gmatch("%s*([^|]-)%s*|") do
        result[#result + 1] = part
    end
    return result
end

function net.strip_dot(name)
    return (name:gsub("%.$", ""))
end
local strip_dot = net.strip_dot

-- A TXT record over 255 bytes arrives as several quoted strings;
-- the spec joins them with nothing, not with the space dig shows.
function net.unquote_txt(text)
    return (text:gsub('" *"', ""):gsub('"', ""))
end
local unquote_txt = net.unquote_txt

function net.normalise_target(raw)
    local target = raw:lower()
    target = target:gsub("^%a[%w+.-]*://", "")
    target = target:gsub("[/?#].*$", "")
    target = target:gsub("^.*@", "")
    local bracketed = target:match("^%[([^%]]+)%]")
    if bracketed then
        target = bracketed
    elseif select(2, target:gsub(":", "")) == 1 then
        target = target:gsub(":[^:]*$", "")
    end
    target = target:gsub("%%.*$", "")
    local mapped = target:match("^::ffff:(%d+%.%d+%.%d+%.%d+)$")
    if mapped then target = mapped end
    return strip_dot(target)
end

function net.plausible_host(name)
    return name:match("^[%w_][%w_%-.]*$") ~= nil
        and not name:find("%.%.")
end

function net.is_ipv4(text)
    return text:match("^%d+%.%d+%.%d+%.%d+$") ~= nil
end

function net.is_ipv6(text)
    return text:match("^[%x:]+$") ~= nil and text:find(":") ~= nil
end

local function reverse_ipv4(address)
    local a, b, c, d = address:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    return d .. "." .. c .. "." .. b .. "." .. a
end

local function ipv6_nibbles(address)
    local left, right = address, ""
    if address:find("::", 1, true) then
        left, right = address:match("^(.-)::(.*)$")
    end
    local head, tail = {}, {}
    for group in left:gmatch("[^:]+") do head[#head + 1] = group end
    for group in right:gmatch("[^:]+") do tail[#tail + 1] = group end
    local groups = {}
    for _, group in ipairs(head) do groups[#groups + 1] = group end
    for _ = 1, IPV6_GROUP_COUNT - #head - #tail do
        groups[#groups + 1] = "0"
    end
    for _, group in ipairs(tail) do groups[#groups + 1] = group end
    local hex = ""
    for _, group in ipairs(groups) do
        hex = hex .. ("%04x"):format(tonumber(group, 16))
    end
    local nibbles = {}
    for position = #hex, 1, -1 do
        nibbles[#nibbles + 1] = hex:sub(position, position)
    end
    return table.concat(nibbles, ".")
end

local function reversed_for(address)
    if net.is_ipv4(address) then return reverse_ipv4(address) end
    return ipv6_nibbles(address)
end

local function dig_rows(arguments)
    local output = run(("dig +noall +answer +time=%d +tries=%d " ..
        "%s 2>/dev/null"):format(DIG_TIMEOUT_SECONDS, DIG_TRIES,
        arguments))
    local rows = {}
    for _, line in ipairs(lines_of(output)) do
        local fields = fields_of(line)
        if #fields >= 5 then
            rows[#rows + 1] = {
                owner = strip_dot(fields[1]),
                ttl = tonumber(fields[2]),
                type = fields[4],
                rdata = table.concat(fields, " ", 5),
            }
        end
    end
    return rows
end

function net.answers(name, type_)
    return dig_rows(quote(name) .. " " .. type_)
end

function net.typed_answers(name, type_)
    local rows = {}
    for _, row in ipairs(net.answers(name, type_)) do
        if row.type == type_ then rows[#rows + 1] = row end
    end
    return rows
end

function net.records(name, type_)
    local values = {}
    for _, row in ipairs(net.typed_answers(name, type_)) do
        values[#values + 1] = row.rdata
    end
    return values
end
local records = net.records

function net.ptr_names(address)
    local names = {}
    for _, row in ipairs(dig_rows("-x " .. quote(address))) do
        if row.type == "PTR" then
            names[#names + 1] = strip_dot(row.rdata)
        end
    end
    return names
end

function net.host_addresses(name)
    local addresses = records(name, "A")
    for _, address in ipairs(records(name, "AAAA")) do
        addresses[#addresses + 1] = address
    end
    return addresses
end

local TCP_CONNECT_TIMEOUT_SECONDS = 3
local TCP_BANNER_WAIT_SECONDS = 2

-- Banner bytes come from a stranger: keep only printable ASCII
-- so a hostile greeting cannot repaint the terminal or corrupt
-- the table's width arithmetic.
local function sanitise_banner(text)
    return (text:gsub("[^\32-\126]", ""))
end

-- bash's /dev/tcp opens the connection; a failed open exits the
-- inner shell non-zero (refused fast, filtered via timeout), so
-- the exit status is the open/closed verdict. An optional short
-- read grabs whatever the server greets with. Host and port
-- reach bash as positional arguments, never spliced into the
-- script text, so a hostile DNS name cannot inject shell code.
local TCP_SCRIPT = ('exec 3<>/dev/tcp/"$1"/"$2" && ' ..
    '{ IFS= read -r -t %d line <&3 2>/dev/null; ' ..
    'printf "%%s" "$line"; }')

-- The read can burn the whole banner wait before returning, so
-- the outer budget must cover the connect and the wait, or a
-- silent-but-open port on a distant host trips the timeout and
-- is misreported as closed.
local TCP_TOTAL_TIMEOUT_SECONDS =
    TCP_CONNECT_TIMEOUT_SECONDS + TCP_BANNER_WAIT_SECONDS

function net.tcp_probe(host, port)
    local script =
        TCP_SCRIPT:format(TCP_BANNER_WAIT_SECONDS)
    local command = ("timeout %d bash -c %s netkit-tcp %s %d " ..
        "2>/dev/null; printf '\\n%%s' \"$?\""):format(
        TCP_TOTAL_TIMEOUT_SECONDS, quote(script),
        quote(host), port)
    local output = run(command)
    local banner, status = output:match("^(.-)\n(%d+)$")
    return {
        open = status == "0",
        banner = sanitise_banner(banner or ""),
    }
end

function net.mx_records(name)
    local mail = {}
    for _, row in ipairs(net.typed_answers(name, "MX")) do
        local preference, exchange =
            row.rdata:match("^(%d+)%s+(%S+)")
        if exchange then
            mail[#mail + 1] = {
                preference = tonumber(preference),
                exchange = strip_dot(exchange),
                ttl = row.ttl,
            }
        end
    end
    table.sort(mail, function(a, b)
        return a.preference < b.preference
    end)
    return mail
end

function net.find_zone(name)
    while name:find("%.") do
        if #records(name, "NS") > 0 then return name end
        name = name:match("^[^.]+%.(.*)$")
    end
end

function net.network_for(address)
    local zone = net.is_ipv4(address)
        and reverse_ipv4(address) .. "." .. CYMRU_ORIGIN_V4_ZONE
        or ipv6_nibbles(address) .. "." .. CYMRU_ORIGIN_V6_ZONE
    local origin = unquote_txt(records(zone, "TXT")[1] or "")
    if origin == "" then return nil end
    local parts = split_pipes(origin)
    local asn = (parts[1] or ""):match("%d+") or ""
    local name_record = unquote_txt(records("AS" .. asn .. "." ..
        CYMRU_ASN_ZONE, "TXT")[1] or "")
    return {
        asn = asn,
        prefix = parts[2] or "",
        country = parts[3] or "",
        registry = parts[4] or "",
        allocated = parts[5] or "",
        name = split_pipes(name_record)[5] or "",
    }
end

function net.abuse_contact(address)
    local zone = reversed_for(address) .. "." .. ABUSIX_CONTACT_ZONE
    return unquote_txt(records(zone, "TXT")[1] or "")
end

local function rbl_sweep(query, zones)
    local hits, refused = {}, {}
    for _, zone in ipairs(zones) do
        local answer = records(query .. "." .. zone, "A")[1]
        if answer and answer:match("^127%.255%.255%.") then
            refused[#refused + 1] = zone
        elseif answer and answer:match("^127%.") then
            hits[#hits + 1] = {
                zone = zone,
                code = answer,
                reason = unquote_txt(records(query .. "." ..
                    zone, "TXT")[1] or ""),
            }
        end
    end
    return hits, refused
end

function net.rbl_results(address)
    if not net.is_ipv4(address) then return nil end
    return rbl_sweep(reverse_ipv4(address), RBL_ZONES)
end

function net.domain_rbl_results(name)
    return rbl_sweep(name, DOMAIN_RBL_ZONES)
end

local function answers_at(server, name, type_, extras)
    return dig_rows((extras or "") .. quote("@" .. server) ..
        " " .. quote(name) .. " " .. type_)
end
net.answers_at = answers_at

local function parent_server(zone)
    local parent = zone:match("^[^.]+%.(.*)$")
    if not parent then return nil end
    local cut = net.find_zone(parent) or parent
    local server = strip_dot(records(cut, "NS")[1] or "")
    if server == "" then return nil end
    return server
end

local function parent_has_ds(zone)
    local server = parent_server(zone)
    if not server then return false end
    for _, row in ipairs(answers_at(server, zone, "DS")) do
        if row.type == "DS" then return true end
    end
    return false
end

-- A parent's referral carries the delegated NS set in the
-- authority section, so that section is requested as well.
function net.delegated_ns(zone)
    local server = parent_server(zone)
    if not server then return {} end
    local rows =
        answers_at(server, zone, "NS", "+authority ")
    local servers = {}
    for _, row in ipairs(rows) do
        if row.type == "NS"
            and row.owner:lower() == zone:lower() then
            servers[#servers + 1] = strip_dot(row.rdata):lower()
        end
    end
    table.sort(servers)
    return servers
end

local function zone_has_rrsig(zone)
    local zone_ns = strip_dot(records(zone, "NS")[1] or "")
    if zone_ns == "" then return false end
    local rows = answers_at(zone_ns, zone, "DNSKEY", "+dnssec ")
    for _, row in ipairs(rows) do
        if row.type == "RRSIG" then return true end
    end
    return false
end

-- The local stub resolver may run with DNSSEC off and strip
-- RRSIG and DS from answers, so signing state is read from the
-- authoritative servers; only validation is judged locally.
function net.dnssec_facts(zone)
    local output = run(("dig +time=%d +tries=%d +dnssec %s SOA " ..
        "2>/dev/null"):format(DIG_TIMEOUT_SECONDS, DIG_TRIES,
        quote(zone)))
    return {
        ds = parent_has_ds(zone),
        signed = zone_has_rrsig(zone),
        validated = output:match("flags:[^;]* ad[ ;]") ~= nil,
        servfail = output:match("status: SERVFAIL") ~= nil,
    }
end

local RDAP_FILTER = [=[
[([.entities[]? | select(.roles[]? == "registrar")
   | .vcardArray[1][]? | select(.[0] == "fn") | .[3]][0]
  // "unknown"),
 ([.events[]? | select(.eventAction == "expiration")
   | .eventDate][0] // "unknown"),
 ((.status // []) | join(", "))] | .[]
]=]

function net.registration(zone)
    local candidate = zone
    while candidate:find("%.") do
        local output = run(("curl -fsSL --max-time %d %s " ..
            "2>/dev/null | jq -r %s 2>/dev/null"):format(
            RDAP_TIMEOUT_SECONDS,
            quote(RDAP_BOOTSTRAP_URL .. "/domain/" .. candidate),
            quote(RDAP_FILTER)))
        local values = lines_of(output)
        if #values >= 3 then
            return {
                domain = candidate,
                registrar = values[1],
                expires = values[2],
                status = values[3] ~= "" and values[3] or "unknown",
            }
        end
        candidate = candidate:match("^[^.]+%.(.*)$")
    end
end

return net
