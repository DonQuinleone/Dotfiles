local net = require("netkit.net")
local tls_lib = require("netkit.tls")

local collect = {}

local BANNER_TIMEOUT_SECONDS = 5

local DKIM_SELECTORS = {
    "default", "google", "selector1", "selector2",
    "k1", "k2", "s1", "s2", "dkim", "mail", "mx", "pm",
}
collect.DKIM_SELECTOR_COUNT = #DKIM_SELECTORS

local function spf_of(domain)
    local records = {}
    for _, txt in ipairs(net.records(domain, "TXT")) do
        local cleaned = net.unquote_txt(txt)
        if cleaned:lower():match("^v=spf1") then
            records[#records + 1] = cleaned
        end
    end
    return { records = records }
end

local function dmarc_of(domain)
    for _, txt in ipairs(net.records("_dmarc." .. domain,
        "TXT")) do
        local cleaned = net.unquote_txt(txt)
        if cleaned:lower():match("^v=dmarc1") then
            return {
                record = cleaned,
                policy = cleaned:lower():match("p%s*=%s*(%a+)"),
                subdomain_policy =
                    cleaned:lower():match("sp%s*=%s*(%a+)"),
                percent = tonumber(
                    cleaned:lower():match("pct%s*=%s*(%d+)")),
                reporting =
                    cleaned:lower():match("rua%s*=") ~= nil,
            }
        end
    end
end

local function mta_sts_of(domain)
    for _, txt in ipairs(net.records("_mta-sts." .. domain,
        "TXT")) do
        local cleaned = net.unquote_txt(txt)
        if cleaned:lower():match("^v=stsv1") then
            local policy = net.run(("curl -fsSL --max-time 8 " ..
                "%s 2>/dev/null"):format(net.quote(
                "https://mta-sts." .. domain ..
                "/.well-known/mta-sts.txt")))
            return {
                record = cleaned,
                mode = policy:lower():match("mode:%s*(%a+)"),
            }
        end
    end
end

local function tlsrpt_of(domain)
    for _, txt in ipairs(net.records("_smtp._tls." .. domain,
        "TXT")) do
        local cleaned = net.unquote_txt(txt)
        if cleaned:lower():match("^v=tlsrptv1") then
            return cleaned
        end
    end
end

local function dkim_of(domain)
    local found = {}
    for _, selector in ipairs(DKIM_SELECTORS) do
        local name = selector .. "._domainkey." .. domain
        for _, txt in ipairs(net.records(name, "TXT")) do
            local cleaned = net.unquote_txt(txt)
            if cleaned:match("v=DKIM1") or cleaned:match("k=")
                or cleaned:match("p=") then
                found[#found + 1] = selector
                break
            end
        end
    end
    return found
end

local function banner_of(host)
    local script = ("exec 3<>/dev/tcp/%s/25 && IFS= read -r " ..
        "-t %d line <&3 && printf '%%s' \"$line\""):format(
        host, BANNER_TIMEOUT_SECONDS)
    local output = net.run(("timeout %d bash -c %s 2>/dev/null")
        :format(BANNER_TIMEOUT_SECONDS + 1, net.quote(script)))
    return (output:gsub("[\r\n]", ""))
end

local function mx_entry(record)
    local entry = {
        preference = record.preference,
        exchange = record.exchange,
        implicit = record.implicit or nil,
    }
    entry.addresses = net.host_addresses(entry.exchange)
    local first = entry.addresses[1]
    if first then
        entry.rdns = net.ptr_names(first)[1]
        local hits = net.rbl_results(first)
        if hits then entry.rbl_hits = hits end
    end
    entry.banner = banner_of(entry.exchange)
    local probe = tls_lib.smtp_probe(entry.exchange)
    if probe then
        entry.starttls = {
            verify_code = probe.verify_code,
            verify_message = probe.verify_message,
            subject = probe.certificate.subject,
            not_after = probe.certificate.not_after,
            days_left = probe.certificate.days_left,
        }
    end
    entry.dane =
        #net.records("_25._tcp." .. entry.exchange, "TLSA") > 0
    return entry
end

local function mx_list(domain)
    local records = net.mx_records(domain)
    if #records > 0 then return records end
    if #net.host_addresses(domain) == 0 then return {} end
    return { { preference = 0, exchange = domain,
        implicit = true } }
end

function collect.report(domain, sections, notify)
    notify = notify or function() end
    local report = { domain = domain }
    if sections.policy then
        notify("policy records")
        report.spf = spf_of(domain)
        report.dmarc = dmarc_of(domain)
        report.mta_sts = mta_sts_of(domain)
        report.tlsrpt = tlsrpt_of(domain)
    end
    if sections.dkim then
        notify("dkim selectors")
        report.dkim = dkim_of(domain)
    end
    if sections.mx then
        report.mx = {}
        local records = mx_list(domain)
        for index, record in ipairs(records) do
            notify(("mx %d/%d (%s)"):format(index, #records,
                record.exchange))
            report.mx[#report.mx + 1] = mx_entry(record)
        end
    end
    return report
end

return collect
