local net = require("netkit.net")

local collect = {}

local PORTS = {
    { port = 21, service = "ftp" },
    { port = 22, service = "ssh" },
    { port = 25, service = "smtp" },
    { port = 53, service = "dns" },
    { port = 80, service = "http" },
    { port = 110, service = "pop3" },
    { port = 143, service = "imap" },
    { port = 443, service = "https" },
    { port = 465, service = "smtps" },
    { port = 587, service = "submission" },
    { port = 993, service = "imaps" },
    { port = 995, service = "pop3s" },
    { port = 2082, service = "cpanel" },
    { port = 2083, service = "cpanel-ssl" },
    { port = 2086, service = "whm" },
    { port = 2087, service = "whm-ssl" },
    { port = 2095, service = "webmail" },
    { port = 2096, service = "webmail-ssl" },
    { port = 3306, service = "mysql" },
}
collect.DEFAULT_PORTS = PORTS

local function target_address(target)
    if net.is_ipv4(target) or net.is_ipv6(target) then
        return target
    end
    return net.host_addresses(target)[1]
end

function collect.report(target, ports, notify)
    notify = notify or function() end
    local address = target_address(target)
    if not address then
        return nil, target .. " does not resolve"
    end
    local report = { target = target, address = address,
        rows = {} }
    local numbers = {}
    for _, entry in ipairs(ports) do
        numbers[#numbers + 1] = entry.port
    end
    notify(("probing %d ports"):format(#ports))
    local probes = net.tcp_probe_batch(address, numbers)
    for index, entry in ipairs(ports) do
        report.rows[#report.rows + 1] = {
            port = entry.port,
            service = entry.service,
            open = probes[index].open,
            banner = probes[index].banner,
        }
    end
    return report
end

return collect
