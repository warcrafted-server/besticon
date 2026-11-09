local ADDON, BI = ...

local offsets
local total

local function ensureOffsets()
    if offsets then
        return
    end
    offsets = {}
    total = 0
    for i = 1, #BI.DB.chunks do
        offsets[i] = total
        total = total + #BI.DB.chunks[i]
    end
end

function BI.DB.Count()
    ensureOffsets()
    return total
end

function BI.DB.Get(index)
    ensureOffsets()
    if not index or index < 1 or index > total then
        return nil
    end
    local chunks = BI.DB.chunks
    for c = #chunks, 1, -1 do
        local start = offsets[c]
        if index > start then
            local entry = chunks[c][index - start]
            return entry[1], entry[2]
        end
    end
    return nil
end

function BI.DB.GetByID(id)
    ensureOffsets()
    local chunks = BI.DB.chunks
    for c = 1, #chunks do
        local chunk = chunks[c]
        for i = 1, #chunk do
            if chunk[i][1] == id then
                return chunk[i][1], chunk[i][2], offsets[c] + i
            end
        end
    end
    return nil
end

function BI.DB.Path(id)
    local _, name = BI.DB.GetByID(id)
    if not name then
        return nil
    end
    return "Interface\\ICONS\\" .. name
end
