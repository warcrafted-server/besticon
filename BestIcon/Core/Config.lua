local ADDON, BI = ...

local defaults = {
    point = "CENTER",
    x = 0,
    y = 0,
    width = 400,
    height = 500,
    iconSize = 36,
    activeTab = 1,
    favorites = {},
    history = {},
}

BI.Config = {}

local function applyDefaults(target)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function BI.Config.Init()
    if type(BestIconDB) ~= "table" then
        BestIconDB = {}
    end
    applyDefaults(BestIconDB)
end

function BI.Config.Get(key)
    if type(BestIconDB) ~= "table" then
        return nil
    end
    return BestIconDB[key]
end

function BI.Config.Set(key, value)
    if type(BestIconDB) ~= "table" then
        BestIconDB = {}
    end
    BestIconDB[key] = value
end
