local json = {}

local ESCAPES = {
    ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b",
    ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r",
    ["\t"] = "\\t",
}

-- Control bytes, DEL and anything above ASCII become \uXXXX, so
-- a stray byte from a DNS name or banner cannot produce output a
-- strict parser rejects.
local function escape(text)
    return (text:gsub('[%z\1-\31\127-\255"\\]', function(char)
        return ESCAPES[char] or ("\\u%04x"):format(char:byte())
    end))
end

local function is_list(value)
    local count = 0
    for _ in pairs(value) do count = count + 1 end
    return count == #value
end

local function sorted_keys(object)
    local keys = {}
    for key in pairs(object) do keys[#keys + 1] = key end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    return keys
end

local encode_value

local function encode_list(list)
    local parts = {}
    for _, item in ipairs(list) do
        parts[#parts + 1] = encode_value(item)
    end
    return "[" .. table.concat(parts, ",") .. "]"
end

local function encode_object(object)
    local parts = {}
    for _, key in ipairs(sorted_keys(object)) do
        parts[#parts + 1] = '"' .. escape(tostring(key)) ..
            '":' .. encode_value(object[key])
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function encode_number(value)
    if value ~= value or value == math.huge
        or value == -math.huge then
        return "null"
    end
    return tostring(value)
end

-- An empty Lua table is ambiguous; this schema's empty values
-- are far more often lists (no records, no listings) than
-- objects, so empty encodes as [].
encode_value = function(value)
    local kind = type(value)
    if kind == "string" then return '"' .. escape(value) .. '"' end
    if kind == "number" then return encode_number(value) end
    if kind == "boolean" then return tostring(value) end
    if kind == "table" then
        if is_list(value) then return encode_list(value) end
        return encode_object(value)
    end
    return "null"
end

function json.encode(value)
    return encode_value(value)
end

return json
