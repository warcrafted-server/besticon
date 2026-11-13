local ADDON, BI = ...

BI.Macros = BI.Macros or {}

local MESSAGES = {
    applied = "macroApplied",
    noPopup = "macroNoPopup",
    notInList = "macroNotInList",
    unavailable = "macroUnavailable",
}

local function inCombat()
    if type(InCombatLockdown) ~= "function" then
        return false
    end
    local ok, combat = pcall(InCombatLockdown)
    return ok and combat == true
end

local function isAddonLoaded(name)
    if type(C_AddOns) == "table" and type(C_AddOns.IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, name)
        if ok then
            return loaded == true
        end
    end
    if type(IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(IsAddOnLoaded, name)
        if ok then
            return loaded == true
        end
    end
    return false
end

function BI.Macros.GetPopup()
    if type(MacroPopupFrame) ~= "table" or type(MacroPopupFrame.IsShown) ~= "function" then
        return nil
    end
    local ok, shown = pcall(MacroPopupFrame.IsShown, MacroPopupFrame)
    if not ok or not shown then
        return nil
    end
    return MacroPopupFrame
end

function BI.Macros.Apply(fileDataID)
    if inCombat() then
        return "unavailable"
    end

    local popup = BI.Macros.GetPopup()
    if not popup then
        return "noPopup"
    end
    if type(fileDataID) ~= "number" or type(popup.GetIndexOfIcon) ~= "function" then
        return "unavailable"
    end

    local ok, index = pcall(popup.GetIndexOfIcon, popup, fileDataID)
    if not ok then
        return "unavailable"
    end
    if type(index) ~= "number" or index <= 0 then
        return "notInList"
    end

    local selector = popup.IconSelector
    if type(selector) ~= "table" or type(selector.SetSelectedIndex) ~= "function" then
        return "unavailable"
    end
    if not pcall(selector.SetSelectedIndex, selector, index) then
        return "unavailable"
    end

    if type(selector.ScrollToSelectedIndex) == "function" then
        pcall(selector.ScrollToSelectedIndex, selector)
    end
    if type(popup.SetSelectedIconText) == "function" then
        pcall(popup.SetSelectedIconText, popup)
    end

    local border = popup.BorderBox
    local area = type(border) == "table" and border.SelectedIconArea or nil
    local button = type(area) == "table" and area.SelectedIconButton or nil
    if type(button) == "table" and type(button.SetIconTexture) == "function" then
        pcall(button.SetIconTexture, button, fileDataID)
    end

    if type(popup.GetSelectedIndex) == "function" then
        local okSelected, selected = pcall(popup.GetSelectedIndex, popup)
        if okSelected and type(selected) == "number" and selected ~= index then
            return "unavailable"
        end
    end
    return "applied"
end

function BI.Macros.Report(state)
    local key = MESSAGES[state]
    if key and BI.L[key] then
        print(BI.L[key])
    end
end

function BI.Macros.UsePosition(position)
    local id = BI.DB.Get(position)
    if not id then
        return nil
    end
    if BI.History then
        BI.History.Add(id)
    end
    local state = BI.Macros.Apply(id)
    BI.Macros.Report(state)
    return state
end

local function findCancel()
    local popup = MacroPopupFrame
    local candidates = { popup.CancelButton, popup.BorderBox and popup.BorderBox.CancelButton, _G.MacroPopupCancelButton }
    for i = 1, 3 do
        if type(candidates[i]) == "table" then
            return candidates[i]
        end
    end
    return nil
end

-- Misma altura y misma fila que Aceptar/Cancelar, a la izquierda de la barra inferior.
function BI.Macros.Align()
    local button = BI.Macros.button
    local popup = MacroPopupFrame
    if not button or type(popup) ~= "table" then
        return
    end
    local cancel = findCancel()
    if not cancel or not cancel.GetTop or not popup.GetTop then
        return
    end
    local top, popupTop = cancel:GetTop(), popup:GetTop()
    local height = cancel:GetHeight()
    if not top or not popupTop then
        return
    end
    local inset = 14
    button:ClearAllPoints()
    button:SetSize(110, height)
    button:SetPoint("TOPLEFT", popup, "TOPLEFT", inset, top - popupTop)
end

function BI.Macros.Debug()
    local button = BI.Macros.button
    if type(MacroPopupFrame) ~= "table" then
        print("Best Icon debug: MacroPopupFrame no existe todavia.")
        return
    end
    if not button then
        print("Best Icon debug: el boton no se ha creado. Instalando...")
        BI.Macros.Install()
        button = BI.Macros.button
        if not button then
            print("Best Icon debug: Install fallo.")
            return
        end
    end
    local point, relative, relPoint, x, y = button:GetPoint(1)
    print(string.format("Best Icon debug: shown=%s visible=%s strata=%s level=%s popupLevel=%s punto=%s %s %s %s",
        tostring(button:IsShown()), tostring(button:IsVisible()), tostring(button:GetFrameStrata()),
        tostring(button:GetFrameLevel()), tostring(MacroPopupFrame:GetFrameLevel()),
        tostring(point), tostring(relPoint), tostring(x), tostring(y)))
    local cancel = findCancel()
    print(string.format("Best Icon debug: cancelButton=%s alto=%s", tostring(cancel ~= nil),
        tostring(cancel and cancel:GetHeight())))
    print(string.format("Best Icon debug: ancho=%s alto=%s parent=%s popupStrata=%s",
        tostring(button:GetWidth()), tostring(button:GetHeight()),
        tostring(button:GetParent() == MacroPopupFrame), tostring(MacroPopupFrame:GetFrameStrata())))
end

function BI.Macros.Install()
    if type(MacroPopupFrame) ~= "table" then
        return nil
    end
    if BI.Macros.button and BI.Macros.installedFor == MacroPopupFrame then
        return BI.Macros.button
    end
    if inCombat() then
        return nil
    end

    if BI.Macros.button and type(BI.Macros.button.Hide) == "function" then
        pcall(BI.Macros.button.Hide, BI.Macros.button)
    end

    local ok, button = pcall(CreateFrame, "Button", nil, MacroPopupFrame, "UIPanelButtonTemplate")
    if not ok or not button then
        if BI.UI and BI.UI.NotifyOnce then
            BI.UI.NotifyOnce("UIPanelButtonTemplate", "UIPanelButtonTemplate")
        end
        return nil
    end

    local setup = pcall(function()
        button:SetSize(110, 20)
        button:SetPoint("BOTTOMLEFT", MacroPopupFrame, "BOTTOMLEFT", 14, 7)
        -- La barra inferior del selector se dibuja con marcos propios: hay que quedar por encima.
        if button.SetFrameStrata then
            button:SetFrameStrata("FULLSCREEN_DIALOG")
        end
        if MacroPopupFrame.GetFrameLevel and button.SetFrameLevel then
            button:SetFrameLevel(MacroPopupFrame:GetFrameLevel() + 50)
        end
        button:SetText(BI.L["macroButton"])
        button:SetScript("OnClick", function()
            if BI.UI and BI.UI.Toggle then
                BI.UI.Toggle()
            end
        end)
    end)
    if not setup then
        if BI.UI and BI.UI.NotifyOnce then
            BI.UI.NotifyOnce("UIPanelButtonTemplate", "UIPanelButtonTemplate")
        end
        return nil
    end

    BI.Macros.button = button
    BI.Macros.installedFor = MacroPopupFrame
    pcall(MacroPopupFrame.HookScript, MacroPopupFrame, "OnShow", function()
        BI.Macros.Align()
        if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
            C_Timer.After(0, BI.Macros.Align)
        end
    end)
    pcall(BI.Macros.Align)
    return button
end

local ok, eventFrame = pcall(CreateFrame, "Frame")
if ok and eventFrame then
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:SetScript("OnEvent", function(_, event, name)
        if event == "ADDON_LOADED" and name == "Blizzard_MacroUI" then
            BI.Macros.Install()
        elseif event == "PLAYER_REGEN_ENABLED" then
            BI.Macros.Install()
        end
    end)
end

if isAddonLoaded("Blizzard_MacroUI") then
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        pcall(C_Timer.After, 0, BI.Macros.Install)
    else
        BI.Macros.Install()
    end
end
