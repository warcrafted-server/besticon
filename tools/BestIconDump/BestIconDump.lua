-- Herramienta de desarrollo: no se distribuye con el addon.
local function grab(fn)
  local t = {}
  local ok, r = pcall(fn, t)
  local out = { ok = ok, retType = type(r), list = {}, sample = {} }
  if not ok then out.err = tostring(r) return out end
  local src = (#t > 0 and t) or (type(r) == "table" and r) or {}
  out.n = #src
  for i, v in ipairs(src) do out.list[i] = v end
  for i = 1, math.min(5, #src) do out.sample[i] = tostring(src[i]) end
  return out
end

SLASH_BIDUMP1 = "/bidump"
SlashCmdList.BIDUMP = function()
  local db = { build = { GetBuildInfo() }, dumped = date("%Y-%m-%d %H:%M:%S"), funcs = {}, globals = {} }
  for _, name in ipairs({ "GetMacroIcons", "GetLooseMacroIcons", "GetMacroItemIcons", "GetSpellTexture" }) do
    local fn = _G[name]
    if type(fn) == "function" and name ~= "GetSpellTexture" then
      db.funcs[name] = grab(fn)
      print(name, "ok=" .. tostring(db.funcs[name].ok), "n=" .. tostring(db.funcs[name].n), db.funcs[name].err or "")
    else
      db.funcs[name] = type(fn)
    end
  end
  for k in pairs(_G) do
    if type(k) == "string" and (k:find("IconSelector") or k:find("MacroPopup") or k:find("MacroFrame")) then
      db.globals[#db.globals + 1] = k .. ":" .. type(_G[k])
    end
  end
  db.templates = {}
  for _, tpl in ipairs({ "ButtonFrameTemplate", "PortraitFrameTemplate", "ButtonFrameTemplateNoPortrait",
    "UIPanelButtonTemplate", "UIPanelCloseButton", "PanelTabButtonTemplate", "InputBoxTemplate",
    "SearchBoxTemplate", "InsetFrameTemplate", "InsetFrameTemplate3", "MinimalScrollBar", "ScrollFrameTemplate",
    "UIPanelScrollFrameTemplate", "WowScrollBoxList", "ItemButtonTemplate", "SimplePopupButtonTemplate",
    "BackdropTemplate", "UICheckButtonTemplate", "MinimalSliderTemplate", "UIPanelDialogTemplate" }) do
    local ok = pcall(CreateFrame, "Frame", nil, UIParent, tpl)
    db.templates[#db.templates + 1] = tpl .. ":" .. tostring(ok)
  end
  table.sort(db.globals)
  db.api = {}
  for _, name in ipairs({ "CreateScrollBoxListGridView", "CreateScrollBoxListLinearView", "CreateDataProvider",
    "ScrollUtil", "MenuUtil", "C_Timer", "SetPortraitToTexture", "Mixin", "CreateFromMixins", "SearchBoxTemplate_OnTextChanged",
    "PanelTemplates_SetNumTabs", "C_Texture", "GetFileIDFromPath", "C_AddOns", "SetPortraitTextureFromAsset" }) do
    db.api[#db.api + 1] = name .. ":" .. type(_G[name])
  end
  local function keysOf(t)
    local out = {}
    if type(t) == "table" then
      for k, v in pairs(t) do out[#out + 1] = tostring(k) .. ":" .. type(v) end
      table.sort(out)
    end
    return out
  end
  db.tables = {}
  for _, name in ipairs({ "IconSelectorPopupFrameTemplateMixin", "IconSelectorEditBoxMixin",
    "IconSelectorPopupFrameModes", "IconSelectorPopupFrameIconFilterTypes", "MacroFrame", "MacroPopupFrame",
    "MacroFrameMixin", "MacroPopupFrameMixin", "C_Macro" }) do
    db.tables[name] = keysOf(_G[name])
  end
  BestIconDumpDB = db
  print("BestIconDump: listo (" .. #db.globals .. " globales). Haz /reload para guardar.")
end
