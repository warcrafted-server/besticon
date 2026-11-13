local ADDON, BI = ...

BI.UI = BI.UI or {}

local function isEmptyQuery(query)
    return BI.Normalize(query or ""):match("^%s*$") ~= nil
end

local function idSet(ids)
    local set = {}
    for _, id in ipairs(ids) do
        set[id] = true
    end
    return set
end

local function positionsFromIDs(ids, categoryKey)
    local out = {}
    for _, id in ipairs(ids) do
        local _, _, position = BI.DB.GetByID(id)
        if position and (not categoryKey or BI.Index.InCategory(categoryKey, position)) then
            out[#out + 1] = position
        end
    end
    return out
end

local function filterSearch(query, categoryKey, allowed)
    local results = BI.Search.Run(query, categoryKey)
    local out = {}
    for i = 1, #results do
        local id = BI.DB.Get(results[i])
        if id and allowed[id] then
            out[#out + 1] = results[i]
        end
    end
    return out
end

function BI.UI.BuildResults(tab, query, categoryKey)
    tab = tonumber(tab) or 1
    if tab == 2 then
        local ids = BI.Favorites.List()
        if isEmptyQuery(query) then
            return positionsFromIDs(ids, categoryKey)
        end
        return filterSearch(query, categoryKey, idSet(ids))
    end
    if tab == 3 then
        local ids = BI.History.List()
        if isEmptyQuery(query) then
            return positionsFromIDs(ids, categoryKey)
        end
        return filterSearch(query, categoryKey, idSet(ids))
    end
    return BI.Search.Run(query, categoryKey)
end
