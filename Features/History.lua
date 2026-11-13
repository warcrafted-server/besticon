local ADDON, BI = ...

BI.History = BI.History or {}

local LIMIT = 40

local function sanitize()
    local source = BI.Config.Get("history")
    if type(source) ~= "table" then
        return {}
    end
    local out = {}
    local seen = {}
    for _, value in ipairs(source) do
        if type(value) == "number" and not seen[value] then
            seen[value] = true
            out[#out + 1] = value
            if #out >= LIMIT then
                break
            end
        end
    end
    return out
end

local function save(list)
    BI.Config.Set("history", list)
end

function BI.History.List()
    return sanitize()
end

function BI.History.Add(id)
    if type(id) ~= "number" then
        return
    end
    local list = sanitize()
    for i = #list, 1, -1 do
        if list[i] == id then
            table.remove(list, i)
        end
    end
    table.insert(list, 1, id)
    while #list > LIMIT do
        table.remove(list)
    end
    save(list)
end

function BI.History.Clear()
    save({})
end
