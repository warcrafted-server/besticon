local ADDON, BI = ...

BI.version = "0.1.0"

-- Data/Icons_NN.lua append to BI.DB.chunks, so this table must exist before them.
BI.DB = { chunks = {} }

local function readMetadataVersion()
    if type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function" then
        return C_AddOns.GetAddOnMetadata(ADDON, "Version")
    end
    if type(GetAddOnMetadata) == "function" then
        return GetAddOnMetadata(ADDON, "Version")
    end
    return nil
end

local metadataVersion = readMetadataVersion()
if metadataVersion then
    BI.version = metadataVersion
end

local function runSlashCommand(message)
    local command = (message or ""):lower():match("^%s*(.-)%s*$")
    if command == "help" then
        print(BI.L["commandHelp"])
        return
    end
    BI.UI.Toggle()
end

local function registerSlashCommands()
    SLASH_BESTICON1 = "/besticon"
    SLASH_BESTICON2 = "/bi"
    SlashCmdList["BESTICON"] = runSlashCommand
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, loadedAddon)
    if loadedAddon ~= ADDON then
        return
    end
    BI.Config.Init()
    registerSlashCommands()
end)
