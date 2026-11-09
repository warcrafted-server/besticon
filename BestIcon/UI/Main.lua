local ADDON, BI = ...

BI.UI = BI.UI or {}

local frame

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

local function savePosition(self)
    local point, _, _, x, y = self:GetPoint(1)
    BI.Config.Set("point", point)
    BI.Config.Set("x", x)
    BI.Config.Set("y", y)
end

local function restorePosition(self)
    local point = BI.Config.Get("point") or "CENTER"
    local x = BI.Config.Get("x") or 0
    local y = BI.Config.Get("y") or 0
    self:ClearAllPoints()
    self:SetPoint(point, UIParent, point, x, y)
end

function BI.UI.GetFrame()
    if frame then
        return frame
    end

    frame = createFrame()
    if not frame then
        return nil
    end

    frame:SetSize(BI.Config.Get("width") or 400, BI.Config.Get("height") or 500)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePosition(self)
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -12)
    frame.title:SetText(BI.L["frameTitle"])

    restorePosition(frame)

    table.insert(UISpecialFrames, "BestIconFrame")
    frame:Hide()
    return frame
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
