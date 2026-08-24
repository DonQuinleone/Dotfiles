local net = require("netkit.net")

local ffi = require("ffi")
ffi.cdef("int isatty(int fd);")

local LABEL_WIDTH = 11
local CELL_PADDING = 1

local ui = {}

ui.is_tty = ffi.C.isatty(1) == 1
local BOLD = ui.is_tty and net.run("tput bold") or ""
local ACCENT = ui.is_tty and net.run("tput setaf 3") or ""
local RESET = ui.is_tty and net.run("tput sgr0") or ""

function ui.accent(text)
    return ACCENT .. text .. RESET
end

function ui.heading(text)
    print(BOLD .. text .. RESET)
end

function ui.keyed(label, value)
    print(("  %-" .. LABEL_WIDTH .. "s %s"):format(label, value))
end

-- tput output is not only CSI colours: sgr0 can carry a charset
-- designation (ESC ( B) or a shift-in byte, which must not count
-- towards a cell's width either.
function ui.visible_width(text)
    local stripped = text:gsub("\27%[[%d;]*m", "")
        :gsub("\27[%(%)]%w", ""):gsub("[\14\15]", "")
    return #(stripped:gsub("[\128-\191]", ""))
end

function ui.render_table(headers, rows)
    local widths = {}
    for column, header in ipairs(headers) do
        widths[column] = ui.visible_width(header)
    end
    for _, row in ipairs(rows) do
        for column = 1, #headers do
            local width = ui.visible_width(row[column] or "")
            if width > widths[column] then widths[column] = width end
        end
    end
    local margin = string.rep(" ", CELL_PADDING)
    local function border(left, middle, right)
        local parts = {}
        for column = 1, #headers do
            parts[column] = string.rep("─",
                widths[column] + 2 * CELL_PADDING)
        end
        print(left .. table.concat(parts, middle) .. right)
    end
    local function body_line(cells)
        local parts = {}
        for column = 1, #headers do
            local cell = cells[column] or ""
            local pad = widths[column] - ui.visible_width(cell)
            parts[column] = margin .. cell ..
                string.rep(" ", pad) .. margin
        end
        print("│" .. table.concat(parts, "│") .. "│")
    end
    border("┌", "┬", "┐")
    body_line(headers)
    border("├", "┼", "┤")
    for _, row in ipairs(rows) do body_line(row) end
    border("└", "┴", "┘")
end

return ui
