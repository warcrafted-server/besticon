local ADDON, BI = ...

BI.version = "0.1.0"

-- Data/Icons_NN.lua append to BI.DB.chunks, so this table must exist before them.
BI.DB = { chunks = {} }

local function printIndexStats()
    local stats = BI.Index.Stats()
    if not BI.Index.IsReady() or not stats.totalMs then
        print("Best Icon debug: el indice aun no se ha construido (abre /bi una vez).")
        return
    end
    print(string.format("Best Icon debug: indexado total=%.0f ms en %d tramos, tramo mas largo=%.0f ms, final=%.0f ms (alias %.0f, conceptos %.0f, categorias %.0f, posiciones %.0f)",
        stats.totalMs, stats.chunks, stats.chunkMaxMs, stats.finishMs,
        stats.aliasesMs, stats.conceptsMs, stats.categoriesMs, stats.positionsMs))
    print(string.format("Best Icon debug: memoria del indice=%.0f KB (antes %.0f, despues %.0f)",
        stats.kbAfter - stats.kbBefore, stats.kbBefore, stats.kbAfter))
end

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
    if command == "debug" then
        BI.Macros.Debug()
        BI.Macros.DebugMain()
        printIndexStats()
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
