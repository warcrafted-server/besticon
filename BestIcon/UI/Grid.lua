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

local GAP = 4

function BI.Grid.Create(parent, onSelect)
    local grid = setmetatable({
        iconSize = Grid.ClampIconSize(BI.Config.Get("iconSize")),
        parent = parent,
        onSelect = onSelect,
        buttons = {},
        results = {},
        row = 0,
    }, Grid)

    local viewport = CreateFrame("Frame", nil, parent)
    viewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -6)
    viewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -26, 6)
    if viewport.SetClipsChildren then
        viewport:SetClipsChildren(true)
    end
    grid.viewport = viewport
    viewport:SetScript("OnSizeChanged", function()
        grid:Resize()
    end)

    local slider = CreateFrame("Slider", nil, parent)
    slider:SetOrientation("VERTICAL")
    slider:SetWidth(16)
    slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -5, -6)
    slider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -5, 6)
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0, 0, 0, 0.35)
    slider:SetThumbTexture("Interface\Buttons\UI-ScrollBar-Knob")
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(18, 24)
    end
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function(_, value)
        local row = math.floor((value or 0) + 0.5)
        if row ~= grid.row then
            grid.row = row
            grid:Render()
        end
    end)
    grid.slider = slider

    viewport:EnableMouseWheel(true)
    viewport:SetScript("OnMouseWheel", function(_, delta)
        slider:SetValue(slider:GetValue() - delta * 3)
    end)
    parent:EnableMouseWheel(true)
    parent:SetScript("OnMouseWheel", function(_, delta)
        slider:SetValue(slider:GetValue() - delta * 3)
    end)

    return grid
end

function Grid:Layout()
    local width = self.viewport:GetWidth() or 0
    local height = self.viewport:GetHeight() or 0
    local cell = self.iconSize + GAP
    local stride = math.max(1, math.floor((width + GAP) / cell))
    local visibleRows = math.max(1, math.floor((height + GAP) / cell))
    self.stride = stride
    self.visibleRows = visibleRows
    local totalRows = math.ceil(#self.results / stride)
    local maxRow = math.max(0, totalRows - visibleRows)
    self.slider:SetMinMaxValues(0, maxRow)
    if self.row > maxRow then
        self.row = maxRow
    end
    self.slider:SetValue(self.row)
    self.slider:SetEnabled(maxRow > 0)
end

function Grid:Render()
    local stride, visibleRows = self.stride or 1, self.visibleRows or 1
    local cell = self.iconSize + GAP
    local slots = stride * (visibleRows + 1)
    for i = 1, slots do
        local button = self.buttons[i]
        if not button then
            button = CreateFrame("Button", nil, self.viewport)
            initButton(button, self.buttons)
        end
        local position = self.results[self.row * stride + i]
        if position then
            local col = (i - 1) % stride
            local r = math.floor((i - 1) / stride)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", self.viewport, "TOPLEFT", col * cell, -r * cell)
            setButton(button, position, self.onSelect, self.iconSize)
            button:Show()
        else
            button.position = nil
            button:Hide()
        end
    end
    for i = slots + 1, #self.buttons do
        self.buttons[i].position = nil
        self.buttons[i]:Hide()
    end
end

function Grid:SetResults(results)
    self.results = results or {}
    self.row = 0
    self:Layout()
    self:Render()
end

function Grid:Update(results)
    self:SetResults(results)
end

function Grid:Resize()
    self:Layout()
    self:Render()
end

function Grid:SetIconSize(size)
    self.iconSize = Grid.ClampIconSize(size)
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
