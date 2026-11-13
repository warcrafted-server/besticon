local ADDON, BI = ...

BI.Search = BI.Search or {}

local function idOf(position)
    local id = BI.DB.Get(position)
    return id or 0
end

local function nameOf(position)
    local _, name = BI.DB.Get(position)
    return name or ""
end

local function copyByID(list)
    local out = {}
    for i = 1, #list do
        out[i] = list[i]
    end
    table.sort(out, function(a, b)
        return idOf(a) < idOf(b)
    end)
    return out
end

local function emptyResult(categoryKey)
    if categoryKey then
        return copyByID(BI.Index.CategoryPositions(categoryKey))
    end
    return copyByID(BI.Index.AllPositions())
end

local function scoreWord(word, key)
    if word == key then
        return 3
    end
    if #key >= #word and key:sub(1, #word) == word then
        return 2
    end
    if #word >= 3 and key:find(word, 1, true) then
        return 1
    end
    return nil
end

local function allowed(categoryKey, position)
    if not categoryKey then
        return true
    end
    return BI.Index.InCategory(categoryKey, position)
end

local function bestScores(word, categoryKey)
    local scores = {}
    local matched = false
    local tokenKeys = BI.Index.TokenKeys()
    for i = 1, #tokenKeys do
        local key = tokenKeys[i]
        local score = scoreWord(word, key)
        if score then
            matched = true
            local list = BI.Index.TokenPostings(key)
            if list then
                for p = 1, #list do
                    local position = list[p]
                    if allowed(categoryKey, position) and (scores[position] or 0) < score then
                        scores[position] = score
                    end
                end
            end
        end
    end

    local aliasKeys = BI.Index.AliasKeys()
    for i = 1, #aliasKeys do
        local key = aliasKeys[i]
        local score = scoreWord(word, key)
        if score then
            matched = true
            local list = BI.Index.AliasPostings(key)
            if list then
                for p = 1, #list do
                    local position = list[p]
                    if allowed(categoryKey, position) and (scores[position] or 0) < score then
                        scores[position] = score
                    end
                end
            end
        end
    end

    if not matched then
        return nil
    end

    -- Keep only the best tier for each word so substring hits cannot bury exact ones.
    local best = 0
    for _, score in pairs(scores) do
        if score > best then
            best = score
        end
    end
    if best == 0 then
        return nil
    end
    local filtered = {}
    for position, score in pairs(scores) do
        if score == best then
            filtered[position] = score
        end
    end
    return filtered
end

local function searchText(query, categoryKey)
    local words = BI.Words(query)
    if #words == 0 then
        return emptyResult(categoryKey)
    end

    local totals = {}
    local counts = {}
    local usedWords = 0
    for w = 1, #words do
        local word = words[w]
        if #word > 2 then
            local scores = bestScores(word, categoryKey)
            if not scores then
                return {}
            end
            usedWords = usedWords + 1
            for position, score in pairs(scores) do
                totals[position] = (totals[position] or 0) + score
                counts[position] = (counts[position] or 0) + 1
            end
        end
    end
    if usedWords == 0 then
        return {}
    end

    local candidates = {}
    for position, total in pairs(totals) do
        if counts[position] == usedWords then
            candidates[#candidates + 1] = {
                position = position,
                score = total,
                nameLength = #nameOf(position),
                id = idOf(position),
            }
        end
    end

    table.sort(candidates, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.nameLength ~= b.nameLength then
            return a.nameLength < b.nameLength
        end
        return a.id < b.id
    end)

    local out = {}
    for i = 1, #candidates do
        out[i] = candidates[i].position
    end
    return out
end

local function searchNumeric(digits, categoryKey)
    local out = {}
    local seen = {}
    local _, _, position = BI.DB.GetByID(tonumber(digits))
    if position and allowed(categoryKey, position) then
        out[#out + 1] = position
        seen[position] = true
    end

    for position = 1, BI.DB.Count() do
        local id = idOf(position)
        local text = tostring(id)
        if text:sub(1, #digits) == digits and not seen[position] and allowed(categoryKey, position) then
            out[#out + 1] = position
            seen[position] = true
        end
    end
    return copyByID(out)
end

local function searchPath(query, categoryKey)
    local needle = query:lower():gsub("/", "\\"):gsub("%.blp$", "")
    local out = {}
    for position = 1, BI.DB.Count() do
        if allowed(categoryKey, position) then
            local id = idOf(position)
            local path = ("Interface\\ICONS\\" .. nameOf(position)):lower()
            if path:find(needle, 1, true) then
                out[#out + 1] = position
            end
        end
    end
    return copyByID(out)
end

function BI.Search.Run(query, categoryKey)
    if not BI.Index.IsReady() then
        BI.Index.BuildSync()
    end

    query = query or ""
    local digits = query:match("^%s*(%d+)%s*$")
    if digits then
        return searchNumeric(digits, categoryKey)
    end

    local lowerQuery = query:lower()
    if lowerQuery:find("\\", 1, true) or lowerQuery:find("/", 1, true) or lowerQuery:find(".blp", 1, true) then
        return searchPath(query, categoryKey)
    end

    if BI.Normalize(query):match("^%s*$") then
        return emptyResult(categoryKey)
    end

    return searchText(query, categoryKey)
end
