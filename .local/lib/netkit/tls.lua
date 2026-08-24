local net = require("netkit.net")

local tls = {}

local TLS_TIMEOUT_SECONDS = 4
local SECONDS_PER_DAY = 86400

tls.HTTPS_PORT = 443

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

local quote = net.quote
local run = net.run

local function tls_client(address, options)
    local endpoint = address .. ":" .. tls.HTTPS_PORT
    if net.is_ipv6(address) then
        endpoint = "[" .. address .. "]:" .. tls.HTTPS_PORT
    end
    return run(("timeout %d openssl s_client -connect %s %s " ..
        "</dev/null 2>/dev/null"):format(TLS_TIMEOUT_SECONDS,
        quote(endpoint), options))
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

function tls.probe(address, servername)
    local output = tls_client(address, sni_options_for(servername))
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

function tls.protocols(address, servername)
    local results = {}
    for _, protocol in ipairs(TLS_PROTOCOLS) do
        local options =
            sni_options_for(servername) .. " " .. protocol.flag
        if protocol.ciphers then
            options = options ..
                " -cipher " .. quote(protocol.ciphers)
        end
        local output = tls_client(address, options)
        results[#results + 1] = {
            label = protocol.label,
            supported = pem_of(output) ~= nil,
        }
    end
    return results
end

function tls.sni_check(address, servername, fingerprint)
    if not servername then return "no host" end
    local bare = pem_of(tls_client(address, "-noservername"))
    if not bare then return "required" end
    local details = certificate_details(bare)
    if details.fingerprint == fingerprint then return "same" end
    return "different"
end

return tls
