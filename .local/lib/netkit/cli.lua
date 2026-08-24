local net = require("netkit.net")

local cli = {}

local USAGE_EXIT_CODE = 64

function cli.die(name, message)
    io.stderr:write(name .. ": " .. message .. "\n")
    os.exit(1)
end

local function usage_error(spec)
    io.stderr:write(spec.usage .. "\n")
    os.exit(USAGE_EXIT_CODE)
end

function cli.require_tools(spec)
    for _, tool in ipairs(spec.required or {}) do
        if net.run("command -v " .. tool) == "" then
            cli.die(spec.name, tool .. " not found")
        end
    end
end

local function apply_value(spec, options, flag, value)
    if not value then usage_error(spec) end
    if not spec.values[flag](options, value) then
        usage_error(spec)
    end
end

-- A single flag grammar for every tool: --help, --json, the
-- tool's own section flags (each sets a name in options.sections)
-- and its value flags (each consumes the next argument). With no
-- section flag given, every section is selected.
function cli.parse(spec)
    local options = { sections = {} }
    local chosen, pending = false, nil
    for _, argument in ipairs(arg) do
        if pending then
            apply_value(spec, options, pending, argument)
            pending = nil
        elseif argument == "-h" or argument == "--help" then
            print(spec.usage)
            os.exit(0)
        elseif argument == "--json" then
            options.json = true
        elseif spec.sections and spec.sections[argument] then
            options.sections[spec.sections[argument]] = true
            chosen = true
        elseif spec.values and spec.values[argument] then
            pending = argument
        elseif argument:match("^%-") or options.target then
            usage_error(spec)
        else
            options.target = argument
        end
    end
    if not options.target or pending then usage_error(spec) end
    if spec.sections and not chosen then
        for _, section in pairs(spec.sections) do
            options.sections[section] = true
        end
    end
    return options
end

return cli
