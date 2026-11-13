local ADDON, BI = ...

BI.UI = BI.UI or {}

local frame
local searchBox
local categoryButton
local categoryKey
local statusText
local windowGrid
local info
local warned = {}
local activeTab = 1
local slider
local sizeLabel

function BI.UI.NotifyOnce(key, api)
    if warned[key] then
        return
    end
    warned[key] = true
    local format = BI.L["uiApiMissing"]
    if format then
        print(string.format(format, api or key))
    end
end

function BI.UI.DisplayName(pos)
    local name = BI.DB.Name(pos)
    if name then
        return name
    end
    local _, raw = BI.DB.Get(pos)
    return raw and raw:gsub("_", " ") or ""
end

local function createFrame()
    local ok, created = pcall(CreateFrame, "Frame", "BestIconFrame", UIParent, "PortraitFrameTemplate")
    if not ok or not created then
        ok, created = pcall(CreateFrame, "Frame", "BestIconFrame", UIParent, "BackdropTemplate")
    end
    if not ok then
        return nil
    end
    return created
end

local function createInset(parent)
    local ok, inset = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate3")
    if not ok or not inset then
        ok, inset = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate")
    end
    if not ok or not inset then
        inset = CreateFrame("Frame", nil, parent)
    end
    return inset
end

local function savePosition(self)
    local point, _, _, x, y = self:GetPoint(1)
    BI.Config.Set("point", point)
    BI.Config.Set("x", x)
    BI.Config.Set("y", y)
end

local function saveSize(self)
    BI.Config.Set("width", self:GetWidth())
    BI.Config.Set("height", self:GetHeight())
end

local function restorePosition(self)
    local point = BI.Config.Get("point") or "CENTER"
    local x = BI.Config.Get("x") or 0
    local y = BI.Config.Get("y") or 0
    self:ClearAllPoints()
    self:SetPoint(point, UIParent, point, x, y)
end

local function initialSize()
    local width = BI.Config.Get("width")
    local height = BI.Config.Get("height")
    if not width or (width == 400 and height == 500) or (width == 440 and height == 540) then
        BI.Config.Set("width", 440)
        BI.Config.Set("height", 620)
        return 440, 620
    end
    return width, height
end

local function categoryLabel(key)
    if key then
        return BI.L["cat_" .. key]
    end
    return BI.L["categoryAll"]
end

local function setCategory(key)
    categoryKey = key
    if categoryButton then
        categoryButton:SetText(categoryLabel(key))
    end
    BI.UI.RunSearch()
end

local function cycleCategory()
    local entries = {}
    for _, category in ipairs(BI.Categories or {}) do
        entries[#entries + 1] = category.key
    end
    local index = 0
    for i = 1, #entries do
        if entries[i] == categoryKey then
            index = i
            break
        end
    end
    local nextIndex = (index % (#entries + 1)) + 1
    if nextIndex == 1 then
        setCategory(nil)
    else
        setCategory(entries[nextIndex - 1])
    end
end

local function showCategoryMenu()
    local menuBroken = false
    if type(MenuUtil) == "table" and type(MenuUtil.CreateContextMenu) == "function" then
        local ok = pcall(MenuUtil.CreateContextMenu, categoryButton, function(_, root)
            local function radio(text, isSelected, onClick)
                local added = pcall(root.CreateRadio, root, text, isSelected, onClick)
                if not added then
                    added = pcall(root.CreateRadio, root, text, isSelected, false, onClick)
                end
                if not added then
                    menuBroken = true
                end
            end
            radio(BI.L["categoryAll"], function() return categoryKey == nil end,
                function() setCategory(nil) end)
            for _, category in ipairs(BI.Categories or {}) do
                local key = category.key
                radio(BI.L["cat_" .. key], function() return categoryKey == key end,
                    function() setCategory(key) end)
            end
        end)
        if ok and not menuBroken then
            return
        end
        BI.UI.NotifyOnce("MenuUtil", "MenuUtil")
    end
    cycleCategory()
end

local function createSearchBox(content)
    local ok, box = pcall(CreateFrame, "EditBox", nil, content, "SearchBoxTemplate")
    if not ok or not box then
        BI.UI.NotifyOnce("SearchBoxTemplate", "SearchBoxTemplate")
        ok, box = pcall(CreateFrame, "EditBox", nil, content, "InputBoxTemplate")
    end
    if not ok or not box then
        return nil
    end
    box:SetHeight(24)
    box:SetPoint("TOPLEFT", content, "TOPLEFT", 14, -46)
    box:SetPoint("TOPRIGHT", content, "TOPRIGHT", -144, -46)
    box:SetAutoFocus(false)
    box:SetScript("OnTextChanged", function(self, userInput)
        if type(SearchBoxTemplate_OnTextChanged) == "function" then
            pcall(SearchBoxTemplate_OnTextChanged, self, userInput)
        end
        BI.UI.RunSearch()
    end)
    box:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return box
end

local function createCategoryButton(content)
    local ok, button = pcall(CreateFrame, "Button", nil, content, "UIPanelButtonTemplate")
    if not ok or not button then
        BI.UI.NotifyOnce("UIPanelButtonTemplate", "UIPanelButtonTemplate")
        button = CreateFrame("Button", nil, content)
        local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetAllPoints()
        button.label = text
    end
    button:SetSize(120, 24)
    button:SetPoint("TOPRIGHT", content, "TOPRIGHT", -12, -44)
    if button.SetText then
        button:SetText(categoryLabel(nil))
    elseif button.label then
        button.label:SetText(categoryLabel(nil))
    end
    button:SetScript("OnClick", showCategoryMenu)
    return button
end

local function createResizeGrabber()
    if not frame then
        return
    end
    if type(frame.SetResizable) == "function" then
        pcall(frame.SetResizable, frame, true)
    end
    if type(frame.SetResizeBounds) == "function" then
        pcall(frame.SetResizeBounds, frame, 380, 520, 700, 900)
    end
    local ok, grabber = pcall(CreateFrame, "Button", nil, frame)
    if not ok or not grabber then
        return
    end
    grabber:SetSize(16, 16)
    grabber:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    grabber:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grabber:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grabber:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grabber:SetScript("OnMouseDown", function()
        if type(frame.StartSizing) == "function" then
            pcall(frame.StartSizing, frame, "BOTTOMRIGHT")
        end
    end)
    grabber:SetScript("OnMouseUp", function()
        if type(frame.StopMovingOrSizing) == "function" then
            pcall(frame.StopMovingOrSizing, frame)
        end
        savePosition(frame)
        saveSize(frame)
        if windowGrid then
            windowGrid:Resize()
        end
    end)
end

local function createSlider(content)
    local ok, created = pcall(CreateFrame, "Slider", nil, content, "MinimalSliderTemplate")
    if not ok or not created then
        BI.UI.NotifyOnce("MinimalSliderTemplate", "MinimalSliderTemplate")
        return
    end
    local setup = pcall(function()
        created:SetSize(120, 16)
        created:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -12, 10)
        created:SetMinMaxValues(24, 64)
        if type(created.SetValueStep) == "function" then
            created:SetValueStep(4)
        end
        if type(created.SetObeyStepOnDrag) == "function" then
            created:SetObeyStepOnDrag(true)
        end
        local value = BI.Grid.ClampIconSize(BI.Config.Get("iconSize"))
        sizeLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        sizeLabel:SetPoint("RIGHT", created, "LEFT", -6, 0)
        sizeLabel:SetText(string.format(BI.L["iconSize"], value))
        created:SetValue(value)
        created:SetScript("OnValueChanged", function(_, changed)
            local size = BI.Grid.ClampIconSize(changed)
            sizeLabel:SetText(string.format(BI.L["iconSize"], size))
            if BI.Config.Get("iconSize") ~= size then
                BI.Config.Set("iconSize", size)
                if windowGrid then
                    windowGrid:SetIconSize(size)
                end
            end
        end)
    end)
    if setup then
        slider = created
    else
        BI.UI.NotifyOnce("MinimalSliderTemplate", "MinimalSliderTemplate")
        created:Hide()
    end
end

local function createTabs()
    if type(PanelTemplates_SetNumTabs) == "function" then
        pcall(PanelTemplates_SetNumTabs, frame, 3)
    end
    local labels = { BI.L["tabAll"], BI.L["tabFavorites"], BI.L["tabHistory"] }
    local previous
    for i = 1, 3 do
        local ok, tab = pcall(CreateFrame, "Button", "BestIconFrameTab" .. i, frame, "PanelTabButtonTemplate")
        if ok and tab then
            tab:SetText(labels[i])
            if previous then
                tab:SetPoint("LEFT", previous, "RIGHT", 0, 0)
            else
                tab:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 11, -30)
            end
            tab:SetScript("OnClick", function()
                BI.UI.SelectTab(i)
            end)
            if type(PanelTemplates_TabResize) == "function" then
                pcall(PanelTemplates_TabResize, tab, 0)
            end
            previous = tab
        else
            BI.UI.NotifyOnce("PanelTabButtonTemplate", "PanelTabButtonTemplate")
        end
    end
    if type(PanelTemplates_SetTab) == "function" then
        pcall(PanelTemplates_SetTab, frame, activeTab)
    end
end

local function createContent()
    local content = frame.Inset or frame
    activeTab = tonumber(BI.Config.Get("activeTab")) or 1
    if activeTab < 1 or activeTab > 3 then
        activeTab = 1
    end
    searchBox = createSearchBox(content)
    categoryButton = createCategoryButton(content)

    local gridInset = createInset(content)
    gridInset:SetPoint("TOPLEFT", content, "TOPLEFT", 12, -80)
    gridInset:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -12, 214)
    windowGrid = BI.Grid.Create(gridInset, function(pos)
        BI.UI.SelectIcon(pos)
    end)

    local infoInset = createInset(content)
    infoInset:SetHeight(172)
    infoInset:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 12, 34)
    infoInset:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -12, 34)
    if BI.Info and BI.Info.Create then
        info = BI.Info.Create(infoInset)
    end

    statusText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 12, 12)
    statusText:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -176, 12)
    statusText:SetJustifyH("LEFT")
    createSlider(content)
    createTabs()

    local last = BI.Config.Get("lastSelected")
    if last and last > 0 then
        BI.UI.selected = last
        if info then
            info:Show(last)
        end
    end
    if windowGrid then
        windowGrid:Resize()
    end
end

function BI.UI.GetGrid()
    return windowGrid
end

function BI.UI.GetFrame()
    if frame then
        return frame
    end

    frame = createFrame()
    if not frame then
        return nil
    end

    local width, height = initialSize()
    frame:SetSize(width, height)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePosition(self)
    end)
    frame:SetScript("OnSizeChanged", function(self)
        saveSize(self)
        if windowGrid then
            windowGrid:Resize()
        end
    end)

    local titled = false
    if type(frame.SetTitle) == "function" then
        titled = pcall(frame.SetTitle, frame, BI.L["frameTitle"])
    end
    if not titled then
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -12)
        frame.title:SetText(BI.L["frameTitle"])
    end
    if type(frame.SetPortraitToAsset) == "function" then
        pcall(frame.SetPortraitToAsset, frame, 7808148)
    end

    restorePosition(frame)
    createContent()
    createResizeGrabber()
    frame:SetScript("OnShow", function()
        if windowGrid then
            windowGrid:Resize()
        end
        BI.UI.RunSearch()
    end)

    table.insert(UISpecialFrames, "BestIconFrame")
    frame:Hide()
    return frame
end

function BI.UI.RunSearch()
    if not BI.Search or not BI.Index then
        return
    end
    if not BI.Index.IsReady() then
        if statusText then
            statusText:SetText(BI.L["indexing"])
        end
        BI.Index.BuildAsync(function()
            BI.UI.RunSearch()
        end)
        return
    end
    local query = searchBox and searchBox:GetText() or ""
    local results = BI.UI.BuildResults(activeTab, query, categoryKey)
    if windowGrid then
        windowGrid:Update(results)
    end
    if statusText then
        local empty
        if activeTab == 2 and #BI.Favorites.List() == 0 then
            empty = BI.L["favoritesEmpty"]
        elseif activeTab == 3 and #BI.History.List() == 0 then
            empty = BI.L["historyEmpty"]
        end
        statusText:SetText(empty or string.format(BI.L["statusIcons"], #results))
    end
    if info and BI.UI.selected then
        info:Show(BI.UI.selected)
    end
end

function BI.UI.SelectTab(tab)
    tab = tonumber(tab) or 1
    if tab < 1 or tab > 3 then
        tab = 1
    end
    activeTab = tab
    BI.Config.Set("activeTab", tab)
    if frame and type(PanelTemplates_SetTab) == "function" then
        pcall(PanelTemplates_SetTab, frame, tab)
    end
    BI.UI.RunSearch()
end

function BI.UI.ToggleFavorite(pos)
    local id = BI.DB.Get(pos)
    if not id then
        return
    end
    BI.Favorites.Toggle(id)
    if windowGrid then
        windowGrid:RefreshFavorites()
    end
    if activeTab == 2 then
        BI.UI.RunSearch()
    elseif info and BI.UI.selected then
        info:Show(BI.UI.selected)
    end
end

function BI.UI.SelectIcon(pos)
    BI.UI.selected = pos
    local id = BI.DB.Get(pos)
    if id then
        BI.History.Add(id)
    end
    BI.Config.Set("lastSelected", pos)
    if windowGrid then
        windowGrid:RefreshSelection(pos)
    end
    if info then
        info:Show(pos)
    end
end

function BI.UI.Toggle()
    local main = BI.UI.GetFrame()
    if not main then
        return
    end
    if main:IsShown() then
        main:Hide()
    else
        main:Show()
    end
end
