local net = require("netkit.net")

local collect = {}

local CURL_TIMEOUT_SECONDS = 10
local MAX_HOPS = 10

local CDN_SIGNATURES = {
    { pattern = "cloudflare", label = "Cloudflare" },
    { pattern = "cf%-ray", label = "Cloudflare" },
    { pattern = "x%-amz%-cf%-", label = "CloudFront" },
    { pattern = "x%-served%-by.*cache", label = "Fastly" },
    { pattern = "fastly", label = "Fastly" },
    { pattern = "x%-akamai", label = "Akamai" },
    { pattern = "akamai", label = "Akamai" },
    { pattern = "x%-sucuri", label = "Sucuri WAF" },
    { pattern = "incapsula", label = "Imperva WAF" },
    { pattern = "x%-cache.*varnish", label = "Varnish" },
}

local CURL_FORMAT = table.concat({
    "code=%{http_code}",
    "url=%{url_effective}",
    "redirect=%{redirect_url}",
    "ip=%{remote_ip}",
    "time=%{time_total}",
    "scheme=%{scheme}",
}, "\\n")

local function header_lines(url)
    local command = ("curl -sSI --max-time %d %s 2>/dev/null")
        :format(CURL_TIMEOUT_SECONDS, net.quote(url))
    local lines = {}
    for line in net.run(command):gmatch("[^\r\n]+") do
        lines[#lines + 1] = line
    end
    return lines
end

local function cdn_from(lines)
    local blob = table.concat(lines, "\n"):lower()
    for _, signature in ipairs(CDN_SIGNATURES) do
        if blob:match(signature.pattern) then
            return signature.label
        end
    end
end

local function server_from(lines)
    for _, line in ipairs(lines) do
        local server = line:match("^[Ss]erver:%s*(.+)$")
        if server then return (server:gsub("%s+$", "")) end
    end
end

local function status_of(url)
    local command = ("curl -sS -o /dev/null --max-time %d " ..
        "-w %s %s 2>/dev/null"):format(CURL_TIMEOUT_SECONDS,
        net.quote(CURL_FORMAT), net.quote(url))
    local fields = {}
    for key, value in net.run(command):gmatch("(%w+)=([^\n]*)") do
        fields[key] = value
    end
    return fields
end

local function hop_of(url)
    local status = status_of(url)
    if not status.code or status.code == "000" then
        return nil
    end
    local lines = header_lines(url)
    local network = status.ip ~= ""
        and net.network_for(status.ip) or nil
    return {
        url = url,
        code = status.code,
        redirect = status.redirect ~= "" and status.redirect
            or nil,
        ip = status.ip ~= "" and status.ip or nil,
        time = tonumber(status.time),
        scheme = status.scheme ~= "" and status.scheme or nil,
        server = server_from(lines),
        cdn = cdn_from(lines),
        asn = network and network.asn or nil,
        network = network and network.name or nil,
    }
end

function collect.report(url, notify)
    notify = notify or function() end
    if not url:match("^%a[%w+.-]*://") then
        url = "https://" .. url
    end
    local report = { url = url, hops = {} }
    local seen = {}
    for index = 1, MAX_HOPS do
        notify(("hop %d (%s)"):format(index, url))
        local hop = hop_of(url)
        if not hop then
            if index == 1 then
                return nil, "no response from " .. url
            end
            break
        end
        report.hops[#report.hops + 1] = hop
        if not hop.redirect or seen[hop.redirect] then break end
        seen[url] = true
        url = hop.redirect
    end
    report.truncated = #report.hops == MAX_HOPS
        and report.hops[MAX_HOPS].redirect ~= nil
    return report
end

return collect
