local ADDON, BI = ...

local stringsByLocale = {}

BI.fallbackLocale = "enUS"
BI.locale = GetLocale and GetLocale() or "enUS"

function BI.RegisterLocale(locale, strings)
    stringsByLocale[locale] = strings
end

local function lookup(key)
    local current = stringsByLocale[BI.locale]
    if current and current[key] ~= nil then
        return current[key]
    end
    local fallback = stringsByLocale[BI.fallbackLocale]
    if fallback and fallback[key] ~= nil then
        return fallback[key]
    end
    return key
end

BI.L = setmetatable({}, {
    __index = function(_, key)
        return lookup(key)
    end,
})
