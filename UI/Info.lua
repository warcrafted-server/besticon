local ADDON, BI = ...

BI.Info = BI.Info or {}

local function addKeyword(out, seen, word, limit)
    if #out >= limit then
        return
    end
    local key = BI.Normalize(word)
    if key == "" or seen[key] then
        return
    end
    seen[key] = true
    out[#out + 1] = word
end

local function keywordsFor(name)
    local out = {}
    local seen = {}
    local tokens = BI.Index.TokensForName(name)
    for i = 1, #tokens do
        addKeyword(out, seen, tokens[i], 8)
    end

    local locales = {}
    for locale in pairs(BI.Aliases or {}) do
        locales[#locales + 1] = locale
    end
    table.sort(locales)
    for l = 1, #locales do
        local aliases = BI.Aliases[locales[l]]
        for i = 1, #tokens do
            local list = aliases[tokens[i]]
            if list then
                for a = 1, #list do
                    addKeyword(out, seen, list[a], 8)
                end
            end
        end
    end
    return out
end

-- El juego no tiene portapapeles: el botón deja el texto seleccionado para copiarlo con Ctrl+C.
local function addCopyButton(parent, box)
    local ok, button = pcall(CreateFrame, "Button", nil, parent, "UIPanelButtonTemplate")
    if not ok or not button then
        return nil
    end
    button:SetSize(64, 22)
    button:SetText(BI.L["copyButton"])
    button:SetScript("OnClick", function()
        box:SetFocus()
        box:HighlightText()
    end)
    button:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(BI.L["copyHint"], 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    return button
end

-- Los cuadros son solo de lectura: si se escribe en ellos, se restaura el valor.
local function lockText(box)
    box:SetScript("OnTextChanged", function(self, user)
        if user and self.lockedText then
            self:SetText(self.lockedText)
            self:HighlightText()
        end
    end)
end

function BI.Info.Create(parent)
    local panel = {}

    local preview = parent:CreateTexture(nil, "ARTWORK")
    preview:SetSize(64, 64)
    preview:SetPoint("TOPLEFT", 10, -10)
    panel.preview = preview

    local name = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", preview, "TOPRIGHT", 10, -2)
    name:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    name:SetHeight(18)
    name:SetJustifyH("LEFT")
    panel.name = name

    local idBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    idBox:SetSize(110, 20)
    idBox:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 46, -8)
    idBox:SetAutoFocus(false)
    idBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    idBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    idBox:SetScript("OnChar", function()
    end)
    lockText(idBox)
    panel.idBox = idBox

    local idCopy = addCopyButton(parent, idBox)
    if idCopy then
        idCopy:SetPoint("LEFT", idBox, "RIGHT", 6, 0)
        panel.idCopy = idCopy
    end

    local idLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    idLabel:SetPoint("RIGHT", idBox, "LEFT", -8, 0)
    idLabel:SetText(BI.L["infoId"])
    panel.idLabel = idLabel

    local pathBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    pathBox:SetHeight(20)
    pathBox:SetPoint("TOPLEFT", idBox, "BOTTOMLEFT", 0, -6)
    pathBox:SetPoint("RIGHT", parent, "RIGHT", -80, 0)
    pathBox:SetAutoFocus(false)
    pathBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    pathBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    pathBox:SetScript("OnChar", function()
    end)
    lockText(pathBox)
    panel.pathBox = pathBox

    local pathCopy = addCopyButton(parent, pathBox)
    if pathCopy then
        pathCopy:SetPoint("LEFT", pathBox, "RIGHT", 6, 0)
        panel.pathCopy = pathCopy
    end

    local pathLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pathLabel:SetPoint("RIGHT", pathBox, "LEFT", -8, 0)
    pathLabel:SetText(BI.L["infoPath"])
    panel.pathLabel = pathLabel

    local categories = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    categories:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -8)
    categories:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    categories:SetJustifyH("LEFT")
    panel.categories = categories

    local keywords = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    keywords:SetPoint("TOPLEFT", categories, "BOTTOMLEFT", 0, -4)
    keywords:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    keywords:SetJustifyH("LEFT")
    panel.keywords = keywords

    local okUse, useButton = pcall(CreateFrame, "Button", nil, parent, "UIPanelButtonTemplate")
    if okUse and useButton then
        useButton:SetSize(130, 22)
        useButton:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 10, 8)
        useButton:SetText(BI.L["macroUse"])
        useButton:SetScript("OnClick", function()
            if BI.UI.selected and BI.Macros then
                BI.Macros.UsePosition(BI.UI.selected)
            end
        end)
        panel.useButton = useButton
    elseif BI.UI.NotifyOnce then
        BI.UI.NotifyOnce("UIPanelButtonTemplate", "UIPanelButtonTemplate")
    end

    local okFav, favButton = pcall(CreateFrame, "Button", nil, parent, "UIPanelButtonTemplate")
    if okFav and favButton then
        favButton:SetSize(150, 22)
        favButton:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 8)
        favButton:SetText(BI.L["favoriteAdd"])
        favButton:SetScript("OnClick", function()
            if panel.position then
                BI.UI.ToggleFavorite(panel.position)
            end
        end)
        panel.favButton = favButton
    elseif BI.UI.NotifyOnce then
        BI.UI.NotifyOnce("UIPanelButtonTemplate", "UIPanelButtonTemplate")
    end

    local noSelection = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    noSelection:SetPoint("TOPLEFT", preview, "TOPRIGHT", 10, -6)
    noSelection:SetText(BI.L["infoNoSelection"])
    panel.noSelection = noSelection

    function panel:Show(pos)
        local id, raw = BI.DB.Get(pos)
        panel.position = id and pos or nil
        if panel.useButton then
            panel.useButton:SetEnabled(id ~= nil)
        end
        if panel.favButton then
            panel.favButton:SetEnabled(id ~= nil)
            if id and BI.Favorites and BI.Favorites.IsFavorite(id) then
                panel.favButton:SetText(BI.L["favoriteRemove"])
            else
                panel.favButton:SetText(BI.L["favoriteAdd"])
            end
        end
        if not id then
            preview:Hide()
            name:SetText("")
            idBox.lockedText, pathBox.lockedText = "", ""
            idBox:SetText("")
            pathBox:SetText("")
            categories:SetText("")
            keywords:SetText("")
            noSelection:Show()
            return
        end

        noSelection:Hide()
        preview:Show()
        preview:SetTexture(id)
        name:SetText(BI.UI.DisplayName(pos))
        idBox.lockedText = tostring(id)
        pathBox.lockedText = BI.DB.Path(id) or ""
        idBox:SetText(idBox.lockedText)
        pathBox:SetText(pathBox.lockedText)

        local names = {}
        local keys = BI.Index.CategoriesOf(pos)
        for i = 1, #keys do
            names[#names + 1] = BI.L["cat_" .. keys[i]]
        end
        categories:SetText(BI.L["infoCategories"] .. ": " .. table.concat(names, ", "))

        local words = keywordsFor(raw)
        keywords:SetText(BI.L["infoKeywords"] .. ": " .. table.concat(words, ", "))
    end

    panel:Show(nil)
    return panel
end
