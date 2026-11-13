local ADDON, BI = ...

BI.Favorites = BI.Favorites or {}

local function sanitize()
    local source = BI.Config.Get("favorites")
    if type(source) ~= "table" then
        return {}
    end
    local out = {}
    local seen = {}
    for _, value in ipairs(source) do
        if type(value) == "number" and not seen[value] then
            seen[value] = true
            out[#out + 1] = value
        end
    end
    return out
end

local function save(list)
    BI.Config.Set("favorites", list)
end

function BI.Favorites.List()
    return sanitize()
end

function BI.Favorites.IsFavorite(id)
    if type(id) ~= "number" then
        return false
    end
    for _, value in ipairs(sanitize()) do
        if value == id then
            return true
        end
    end
    return false
end

function BI.Favorites.Add(id)
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
    save(list)
end

function BI.Favorites.Remove(id)
    if type(id) ~= "number" then
        return
    end
    local list = sanitize()
    for i = #list, 1, -1 do
        if list[i] == id then
            table.remove(list, i)
        end
    end
    save(list)
end

function BI.Favorites.Toggle(id)
    if BI.Favorites.IsFavorite(id) then
        BI.Favorites.Remove(id)
        return false
    end
    BI.Favorites.Add(id)
    return true
end
