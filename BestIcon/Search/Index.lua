local ADDON, BI = ...

BI.Index = BI.Index or {}

local GENERIC = {
    inv = true, ability = true, spell = true, achievement = true, trade = true,
    classic = true, ui = true, icon = true, icons = true,
}

local function tokenize(name)
    local tokens = {}
    for part in (name or ""):gmatch("[^_]+") do
        local i = 1
        while i <= #part do
            local char = part:sub(i, i)
            if char:match("%d") then
                local j = i
                while j <= #part and part:sub(j, j):match("%d") do
                    j = j + 1
                end
                i = j
            elseif char:match("%u") then
                local j = i
                while j <= #part and part:sub(j, j):match("%u") do
                    j = j + 1
                end
                if part:sub(j, j):match("%l") then
                    if j - 1 > i then
                        tokens[#tokens + 1] = part:sub(i, j - 2)
                        i = j - 1
                    else
                        local k = j
                        while k <= #part and part:sub(k, k):match("%l") do
                            k = k + 1
                        end
                        tokens[#tokens + 1] = part:sub(i, k - 1)
                        i = k
                    end
                else
                    tokens[#tokens + 1] = part:sub(i, j - 1)
                    i = j
                end
            elseif char:match("%l") then
                local j = i
                while j <= #part and part:sub(j, j):match("%l") do
                    j = j + 1
                end
                tokens[#tokens + 1] = part:sub(i, j - 1)
                i = j
            else
                i = i + 1
            end
        end
    end

    local out = {}
    for i = 1, #tokens do
        local token = tokens[i]:lower()
        if not token:match("^%d+$") and #token > 1 and not GENERIC[token] then
            out[#out + 1] = token
        end
    end
    return out
end

local postings = {}
local tokenKeys = {}
local aliasPostings = {}
local aliasKeys = {}
local categorySets = {}
local categoryLists = {}
local allPositions = {}
local totalIcons = 0
local ready = false
local building = false
local pendingDone = {}

local function idOf(position)
    local id = BI.DB.Get(position)
    return id or 0
end

local function byID(a, b)
    return idOf(a) < idOf(b)
end

local function addPosting(key, position)
    local list = postings[key]
    if not list then
        list = {}
        postings[key] = list
        tokenKeys[#tokenKeys + 1] = key
    end
    list[#list + 1] = position
end

local function indexIcon(position)
    local _, name = BI.DB.Get(position)
    if not name then
        return
    end
    local seen = {}
    local tokens = tokenize(name)
    for i = 1, #tokens do
        local key = BI.Stem(BI.Normalize(tokens[i]))
        if key ~= "" and not seen[key] then
            seen[key] = true
            addPosting(key, position)
        end
    end
end

local function isWordVariant(a, b)
    if a == b then
        return true
    end
    if #a < #b then
        a, b = b, a
    end
    return #b >= 3 and #a - #b <= 1 and a:sub(1, #b) == b
end

-- Alias words are shared by several tokens; keeping the primary translation and
-- folding plural variants stops common synonyms from flooding every result.
local function buildAliases()
    aliasPostings = {}
    aliasKeys = {}
    local info = {}
    for _, localeAliases in pairs(BI.Aliases or {}) do
        for token, aliases in pairs(localeAliases) do
            local tokenKey = BI.Stem(BI.Normalize(token))
            if postings[tokenKey] then
                for rank = 1, #aliases do
                    local words = BI.Normalize(aliases[rank]):gmatch("[%w]+")
                    for word in words do
                        if #word > 2 then
                            local key = BI.Stem(word)
                            local entry = info[key]
                            if not entry then
                                entry = { ranks = {} }
                                info[key] = entry
                                aliasKeys[#aliasKeys + 1] = key
                            end
                            local previous = entry.ranks[tokenKey]
                            if not previous or rank < previous then
                                entry.ranks[tokenKey] = rank
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, #aliasKeys do
        local key = aliasKeys[i]
        local ranks = info[key].ranks
        local best = 100
        for _, rank in pairs(ranks) do
            if rank < best then
                best = rank
            end
        end

        local selected = {}
        local chosen
        local chosenSize = -1
        local tied = 0
        for tokenKey, rank in pairs(ranks) do
            if rank == best then
                tied = tied + 1
                local size = #postings[tokenKey]
                if size > chosenSize or (size == chosenSize and tokenKey < chosen) then
                    chosen = tokenKey
                    chosenSize = size
                end
            end
        end
        -- With several equally primary translations, prefer the most common token.
        if tied > 1 then
            selected[chosen] = true
        else
            for tokenKey, rank in pairs(ranks) do
                if rank == best then
                    selected[tokenKey] = true
                end
            end
        end
        for tokenKey in pairs(ranks) do
            if not selected[tokenKey] then
                for chosenKey in pairs(selected) do
                    if isWordVariant(tokenKey, chosenKey) then
                        selected[tokenKey] = true
                        break
                    end
                end
            end
        end

        local set = {}
        for tokenKey in pairs(selected) do
            local list = postings[tokenKey]
            for p = 1, #list do
                set[list[p]] = true
            end
        end
        local list = {}
        for position in pairs(set) do
            list[#list + 1] = position
        end
        table.sort(list, byID)
        aliasPostings[key] = list
    end
end

local function buildCategories()
    categorySets = {}
    categoryLists = {}
    local used = {}
    for _, category in ipairs(BI.Categories or {}) do
        if category.key ~= "misc" then
            local set = {}
            for i = 1, #category.tokens do
                local key = BI.Stem(BI.Normalize(category.tokens[i]))
                local list = postings[key]
                if list then
                    for p = 1, #list do
                        set[list[p]] = true
                        used[list[p]] = true
                    end
                end
            end
            categorySets[category.key] = set
        end
    end

    local misc = {}
    for position = 1, totalIcons do
        if not used[position] then
            misc[position] = true
        end
    end
    categorySets["misc"] = misc

    for _, category in ipairs(BI.Categories or {}) do
        local set = categorySets[category.key]
        if set then
            local list = {}
            for position in pairs(set) do
                list[#list + 1] = position
            end
            table.sort(list, byID)
            categoryLists[category.key] = list
        end
    end
    if not categoryLists["misc"] then
        local list = {}
        for position in pairs(misc) do
            list[#list + 1] = position
        end
        table.sort(list, byID)
        categoryLists["misc"] = list
    end
end

local function buildAllPositions()
    allPositions = {}
    for position = 1, totalIcons do
        allPositions[position] = position
    end
    table.sort(allPositions, byID)
end

local function finish()
    buildAliases()
    buildCategories()
    buildAllPositions()
    ready = true
    building = false
end

local function reset()
    postings = {}
    tokenKeys = {}
    aliasPostings = {}
    aliasKeys = {}
    categorySets = {}
    categoryLists = {}
    allPositions = {}
    ready = false
end

function BI.Index.BuildSync()
    reset()
    totalIcons = BI.DB.Count()
    for position = 1, totalIcons do
        indexIcon(position)
    end
    finish()
end

function BI.Index.BuildAsync(onDone)
    if ready then
        if onDone then
            onDone()
        end
        return
    end
    if building then
        if onDone then
            pendingDone[#pendingDone + 1] = onDone
        end
        return
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        BI.Index.BuildSync()
        if onDone then
            onDone()
        end
        return
    end

    building = true
    reset()
    totalIcons = BI.DB.Count()
    local position = 1

    local function step()
        local last = position + 1999
        if last > totalIcons then
            last = totalIcons
        end
        for i = position, last do
            indexIcon(i)
        end
        position = last + 1
        if position <= totalIcons then
            C_Timer.After(0, step)
        else
            finish()
            if onDone then
                onDone()
            end
            for i = 1, #pendingDone do
                pendingDone[i]()
            end
            pendingDone = {}
        end
    end

    C_Timer.After(0, step)
end

function BI.Index.IsReady()
    return ready
end

function BI.Index.TokenKeys()
    return tokenKeys
end

function BI.Index.AliasKeys()
    return aliasKeys
end

function BI.Index.TokenPostings(token)
    return postings[BI.Stem(BI.Normalize(token))]
end

function BI.Index.AliasPostings(token)
    return aliasPostings[BI.Stem(BI.Normalize(token))]
end

function BI.Index.CategoryPositions(key)
    return categoryLists[key] or {}
end

function BI.Index.AllPositions()
    return allPositions
end

function BI.Index.InCategory(key, position)
    local set = categorySets[key]
    return set ~= nil and set[position] == true
end

function BI.Index.TokensForName(name)
    return tokenize(name)
end
