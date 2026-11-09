local ADDON, BI = ...

local replacements = {
    {"Á", "a"}, {"É", "e"}, {"Í", "i"}, {"Ó", "o"}, {"Ú", "u"}, {"Ü", "u"},
    {"Ñ", "n"}, {"À", "a"}, {"È", "e"}, {"Ì", "i"}, {"Ò", "o"}, {"Ù", "u"},
    {"Â", "a"}, {"Ê", "e"}, {"Î", "i"}, {"Ô", "o"}, {"Û", "u"}, {"Ç", "c"},
    {"á", "a"}, {"é", "e"}, {"í", "i"}, {"ó", "o"}, {"ú", "u"}, {"ü", "u"},
    {"ñ", "n"}, {"à", "a"}, {"è", "e"}, {"ì", "i"}, {"ò", "o"}, {"ù", "u"},
    {"â", "a"}, {"ê", "e"}, {"î", "i"}, {"ô", "o"}, {"û", "u"}, {"ç", "c"},
}

function BI.Normalize(text)
    if not text then
        return ""
    end
    for i = 1, #replacements do
        text = text:gsub(replacements[i][1], replacements[i][2])
    end
    return text:lower()
end

function BI.Stem(word)
    if #word > 3 then
        if word:sub(-3) == "ones" or (#word > 4 and word:sub(-2) == "es") then
            return word:sub(1, -3)
        end
        if word:sub(-1) == "s" then
            return word:sub(1, -2)
        end
    end
    return word
end

function BI.Words(query)
    local words = {}
    for word in BI.Normalize(query):gmatch("[%w]+") do
        local stemmed = BI.Stem(word)
        if #stemmed > 1 then
            words[#words + 1] = stemmed
        end
    end
    return words
end
