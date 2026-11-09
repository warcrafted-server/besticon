local ADDON, BI = ...

BI.Grid = BI.Grid or {}

local Grid = {}
Grid.__index = Grid

function Grid.ClampIconSize(value)
    value = tonumber(value) or 36
    value = math.floor((value - 24) / 4 + 0.5) * 4 + 24
    if value < 24 then
        return 24
    end
    if value > 64 then
        return 64
    end
    return value
end

BI.Grid.ClampIconSize = Grid.ClampIconSize

function Grid.ComputeStride(parentWidth, iconSize)
    local stride = math.floor(((parentWidth or 0) - 32) / (iconSize + 4))
    if stride < 1 then
        stride = 1
    end
    return stride
end

local function notify(key)
    if BI.UI and BI.UI.NotifyOnce then
        BI.UI.NotifyOnce(key, key)
    end
end

local function initButton(button, buttons)
    if not button.bestIconInitialized then
        button.bestIconInitialized = true

        local slot = button:CreateTexture(nil, "BACKGROUND")
        slot:SetAllPoints()
        slot:SetTexture("Interface\\Buttons\\UI-Quickslot2")
        button.slot = slot

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button.icon = icon

        local selected = button:CreateTexture(nil, "OVERLAY")
        selected:SetAllPoints()
        selected:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        selected:SetBlendMode("ADD")
        selected:Hide()
        button.selected = selected

        local favorite = button:CreateTexture(nil, "OVERLAY")
        favorite:SetSize(14, 14)
        favorite:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        favorite:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
        favorite:Hide()
        button.favorite = favorite

        button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(self, mouseButton)
            if not self.position then
                return
            end
            if mouseButton == "RightButton" then
                BI.UI.ToggleFavorite(self.position)
            elseif self.onSelect then
                self.onSelect(self.position)
            end
        end)
        button:SetScript("OnDoubleClick", function(self)
            if self.position and BI.Macros then
                BI.UI.SelectIcon(self.position)
                BI.Macros.UsePosition(self.position)
            end
        end)
        button:SetScript("OnEnter", function(self)
            if type(GameTooltip) ~= "table" or not self.position then
                return
            end
            local id = BI.DB.Get(self.position)
            if not id then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(BI.UI.DisplayName(self.position))
            GameTooltip:AddLine(string.format(BI.L["tooltipId"], id))
            GameTooltip:AddLine(string.format(BI.L["tooltipPath"], BI.DB.Path(id) or ""))
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            if type(GameTooltip) == "table" then
                GameTooltip:Hide()
            end
        end)

        buttons[#buttons + 1] = button
    end
end

local function setButton(button, position, onSelect, iconSize)
    button.position = position
    button.onSelect = onSelect
    button:SetSize(iconSize, iconSize)
    local id = BI.DB.Get(position)
    button.icon:SetTexture(id)
    if id and BI.Favorites and BI.Favorites.IsFavorite(id) then
        button.favorite:Show()
    else
        button.favorite:Hide()
    end
    if BI.UI.selected == position then
        button.selected:Show()
    else
        button.selected:Hide()
    end
end

function BI.Grid.Create(parent, onSelect)
    local iconSize = Grid.ClampIconSize(BI.Config.Get("iconSize"))
    local grid = setmetatable({
        iconSize = iconSize,
        parent = parent,
        onSelect = onSelect,
        buttons = {},
        results = {},
    }, Grid)

    local scrollBar
    for _, frameType in ipairs({ "EventFrame", "Frame" }) do
        local ok, bar = pcall(CreateFrame, frameType, nil, parent, "MinimalScrollBar")
        if ok and bar then
            scrollBar = bar
            break
        end
    end
    if not scrollBar then
        notify("MinimalScrollBar")
        return nil
    end
    scrollBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, -4)
    scrollBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 4)
    grid.scrollBar = scrollBar

    local okBox, scrollBox = pcall(CreateFrame, "Frame", nil, parent, "WowScrollBoxList")
    if not okBox or not scrollBox then
        notify("WowScrollBoxList")
        return nil
    end
    scrollBox:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
    scrollBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 4)
    grid.scrollBox = scrollBox

    local stride = Grid.ComputeStride(parent:GetWidth(), iconSize)
    grid.stride = stride

    local okView, view = pcall(CreateScrollBoxListGridView, stride, 0, 0, 0, 0, 4, 4)
    if not okView or not view then
        notify("CreateScrollBoxListGridView")
        return nil
    end
    grid.view = view
    if type(view.SetElementExtent) == "function" then
        pcall(view.SetElementExtent, view, iconSize)
    end

    local function setup(button, elementData)
        initButton(button, grid.buttons)
        setButton(button, elementData, onSelect, grid.iconSize)
    end

    local factorySet = false
    if type(view.SetElementFactory) == "function" then
        factorySet = pcall(view.SetElementFactory, view, function(factory)
            factory("Button", setup)
        end)
    end
    if not factorySet and type(view.SetElementInitializer) == "function" then
        factorySet = pcall(view.SetElementInitializer, view, "Button", setup)
    end
    if not factorySet then
        notify("SetElementFactory")
    end

    -- La vista debe enlazarse antes de asignar datos.
    if type(ScrollUtil) == "table" and type(ScrollUtil.InitScrollBoxListWithScrollBar) == "function" then
        if not pcall(ScrollUtil.InitScrollBoxListWithScrollBar, scrollBox, scrollBar, view) then
            notify("ScrollUtil")
        end
    else
        notify("ScrollUtil")
    end

    return grid
end

function Grid:SetResults(results)
    self.results = results or {}
    if not self.scrollBox then
        return
    end
    local okProvider, provider = pcall(CreateDataProvider, self.results)
    if not okProvider or not provider or type(self.scrollBox.SetDataProvider) ~= "function" then
        notify("CreateDataProvider")
        return
    end
    if not pcall(self.scrollBox.SetDataProvider, self.scrollBox, provider) then
        notify("SetDataProvider")
    end
end

function Grid:Update(results)
    self:SetResults(results)
end

function Grid:Resize()
    if not self.parent or not self.view then
        return
    end
    local stride = Grid.ComputeStride(self.parent:GetWidth(), self.iconSize)
    self.stride = stride
    if type(self.view.SetStride) == "function" then
        local ok = pcall(self.view.SetStride, self.view, stride)
        if not ok then
            notify("SetStride")
        end
    else
        notify("SetStride")
    end
    if self.scrollBox and type(self.scrollBox.FullUpdate) == "function" then
        pcall(self.scrollBox.FullUpdate, self.scrollBox)
    end
end

function Grid:SetIconSize(size)
    self.iconSize = Grid.ClampIconSize(size)
    if self.view and type(self.view.SetElementExtent) == "function" then
        pcall(self.view.SetElementExtent, self.view, self.iconSize)
    end
    for i = 1, #self.buttons do
        self.buttons[i]:SetSize(self.iconSize, self.iconSize)
    end
    self:Resize()
end

function Grid:RefreshFavorites()
    for i = 1, #self.buttons do
        local button = self.buttons[i]
        local id = button.position and BI.DB.Get(button.position)
        if id and BI.Favorites and BI.Favorites.IsFavorite(id) then
            button.favorite:Show()
        else
            button.favorite:Hide()
        end
    end
end

function Grid:RefreshSelection(position)
    for i = 1, #self.buttons do
        local button = self.buttons[i]
        if button.position == position then
            button.selected:Show()
        else
            button.selected:Hide()
        end
    end
end
