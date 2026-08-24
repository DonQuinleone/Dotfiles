local net = require("netkit.net")

local tls = {}

local TLS_TIMEOUT_SECONDS = 4
local SECONDS_PER_DAY = 86400

tls.HTTPS_PORT = 443
tls.SMTP_PORT = 25
tls.EXPIRY_WARNING_DAYS = 30

-- Fedora's default OpenSSL security level refuses TLS 1.0/1.1
-- handshakes client-side, which would report every server as
-- rejecting them; SECLEVEL=0 lifts it for those probes only.
local LEGACY_CIPHERS = "DEFAULT@SECLEVEL=0"
local TLS_PROTOCOLS = {
    { flag = "-tls1", label = "1.0", ciphers = LEGACY_CIPHERS },
    { flag = "-tls1_1", label = "1.1", ciphers = LEGACY_CIPHERS },
    { flag = "-tls1_2", label = "1.2" },
    { flag = "-tls1_3", label = "1.3" },
}
tls.PROTOCOL_LABELS = {}
for _, protocol in ipairs(TLS_PROTOCOLS) do
    tls.PROTOCOL_LABELS[#tls.PROTOCOL_LABELS + 1] =
        protocol.label
end

local VERIFY_LABELS = {
    [0] = "ok",
    [10] = "expired",
    [18] = "self-signed",
    [19] = "self-signed chain",
    [20] = "unknown issuer",
    [62] = "hostname mismatch",
}

function tls.verify_label(code, message)
    if not code then return "unknown" end
    return VERIFY_LABELS[code] or message or "unknown"
end

local quote = net.quote
local run = net.run

local function tls_command(address, port, options)
    local endpoint = address .. ":" .. port
    if net.is_ipv6(address) then
        endpoint = "[" .. address .. "]:" .. port
    end
    return ("timeout %d openssl s_client -connect %s %s " ..
        "</dev/null 2>/dev/null"):format(TLS_TIMEOUT_SECONDS,
        quote(endpoint), options)
end

local function batch_outputs(commands)
    local dir = run("mktemp -d"):match("%S+")
    if not dir then return {} end
    local parts = {}
    for index, command in ipairs(commands) do
        parts[#parts + 1] = command .. " > " ..
            quote(dir .. "/" .. index) .. " &"
    end
    run("{ " .. table.concat(parts, " ") .. " wait; }")
    local outputs = {}
    for index = 1, #commands do
        local file = io.open(dir .. "/" .. index)
        outputs[index] = file and file:read("*a") or ""
        if file then file:close() end
    end
    run("rm -rf " .. quote(dir))
    return outputs
end

local function pem_of(output)
    return output:match("(%-%-%-%-%-BEGIN CERTIFICATE%-%-%-%-%-" ..
        ".-%-%-%-%-%-END CERTIFICATE%-%-%-%-%-)")
end

local function certificate_details(pem)
    local text = run(("printf '%%s' %s | openssl x509 -noout " ..
        "-subject -issuer -enddate -fingerprint -sha256 " ..
        "-ext subjectAltName 2>/dev/null"):format(quote(pem)))
    local details = {
        subject = text:match("subject=%s*([^\n]+)"),
        issuer = text:match("issuer=%s*([^\n]+)"),
        not_after = text:match("notAfter=([^\n]+)"),
        fingerprint = text:match("Fingerprint=(%S+)"),
        sans = {},
    }
    local san_blob =
        text:match("Alternative Name:%s*\n%s*([^\n]+)")
    for entry in (san_blob or ""):gmatch("[^,]+") do
        local value = entry:match("^%s*[%a%s]+:(.+)$")
        if value then details.sans[#details.sans + 1] = value end
    end
    if details.not_after then
        local epoch = tonumber(run("date -d " ..
            quote(details.not_after) .. " +%s 2>/dev/null"))
        if epoch then
            details.days_left =
                math.floor((epoch - os.time()) / SECONDS_PER_DAY)
        end
    end
    return details
end

local function sni_options_for(servername)
    if not servername then return "" end
    return "-servername " .. quote(servername) ..
        " -verify_hostname " .. quote(servername)
end

local function parse_probe(output)
    local pem = pem_of(output)
    if not pem then return nil end
    local code, message =
        output:match("Verify return code: (%d+) %((.-)%)")
    return {
        certificate = certificate_details(pem),
        verify_code = tonumber(code),
        verify_message = message,
    }
end

function tls.smtp_probe(host)
    local output = run(tls_command(host, tls.SMTP_PORT,
        "-starttls smtp " .. sni_options_for(host)))
    return parse_probe(output)
end

local function sni_verdict(servername, bare_pem, fingerprint)
    if not servername then return "no host" end
    if not bare_pem then return "required" end
    local bare = certificate_details(bare_pem)
    if bare.fingerprint == fingerprint then return "same" end
    return "different"
end

-- One parallel batch per address: the SNI probe, the bare probe
-- and every protocol probe run concurrently, so an address costs
-- one round trip instead of six.
function tls.survey(address, servername)
    local port = tls.HTTPS_PORT
    local commands = {
        tls_command(address, port, sni_options_for(servername)),
        tls_command(address, port, "-noservername"),
    }
    for _, protocol in ipairs(TLS_PROTOCOLS) do
        local options =
            sni_options_for(servername) .. " " .. protocol.flag
        if protocol.ciphers then
            options = options ..
                " -cipher " .. quote(protocol.ciphers)
        end
        commands[#commands + 1] =
            tls_command(address, port, options)
    end
    local outputs = batch_outputs(commands)
    local result = parse_probe(outputs[1] or "")
    if not result then return nil end
    result.protocols = {}
    for index, protocol in ipairs(TLS_PROTOCOLS) do
        result.protocols[index] = {
            label = protocol.label,
            supported = pem_of(outputs[2 + index] or "") ~= nil,
        }
    end
    result.sni = sni_verdict(servername, pem_of(outputs[2] or ""),
        result.certificate.fingerprint)
    return result
end

return tls
