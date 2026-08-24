local json = {}

local ESCAPES = {
    ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b",
    ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r",
    ["\t"] = "\\t",
}

local function escape(text)
    return (text:gsub('[%z\1-\31"\\]', function(char)
        return ESCAPES[char] or ("\\u%04x"):format(char:byte())
    end))
end

local function is_list(value)
    local count = 0
    for _ in pairs(value) do count = count + 1 end
    return count == #value
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
    local keys = {}
    for key in pairs(object) do keys[#keys + 1] = tostring(key) end
    table.sort(keys)
    local parts = {}
    for _, key in ipairs(keys) do
        parts[#parts + 1] = '"' .. escape(key) .. '":' ..
            encode_value(object[key])
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

encode_value = function(value)
    local kind = type(value)
    if kind == "string" then return '"' .. escape(value) .. '"' end
    if kind == "number" or kind == "boolean" then
        return tostring(value)
    end
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
