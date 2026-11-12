"""Prueba de humo de la interfaz de BestIcon con un cliente de WoW simulado.

No sustituye la prueba en el juego: solo detecta errores de Lua (nil, firmas) en el flujo
abrir -> buscar -> seleccionar -> favoritos -> pestañas -> tamaño.
Uso: python tests/run_ui_smoke.py
"""

import sys
from pathlib import Path

from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "BestIcon"

lua = LuaRuntime(unpack_returned_tuples=True)


def read_file(relative):
    return (ADDON / relative).read_text(encoding="utf-8")


def toc_files():
    files = []
    for line in (ADDON / "BestIcon.toc").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("##"):
            files.append(line)
    return files


lua.globals().read_file = read_file
lua.globals().toc_files = lambda: lua.table_from(toc_files())

MOCK = r"""
ALL_FRAMES = {}
CURRENT_LOCALE = CURRENT_LOCALE or "enUS"
UISpecialFrames = {}
SlashCmdList = {}
BestIconDB = nil
function GetLocale() return CURRENT_LOCALE end
function InCombatLockdown() return false end

local overrides = {}
function overrides:SetScript(name, fn) self._scripts[name] = fn end
function overrides:GetScript(name) return self._scripts[name] end
function overrides:HookScript(name, fn) self._scripts[name] = self._scripts[name] or fn end
function overrides:RegisterEvent(name) self._events[name] = true end
function overrides:SetText(text) self._text = text end
function overrides:GetText() return self._text end
function overrides:GetWidth() return 440 end
function overrides:GetHeight() return 540 end
function overrides:GetPoint() return "CENTER", nil, "CENTER", 0, 0 end
function overrides:IsShown() return self._shown end
function overrides:Show() self._shown = true; if self._scripts.OnShow then self._scripts.OnShow(self) end end
function overrides:Hide() self._shown = false; if self._scripts.OnHide then self._scripts.OnHide(self) end end
function overrides:SetEnabled(v) self._enabled = v end
function overrides:SetValue(v) self._value = v end
function overrides:GetValue() return self._value or 0 end
function overrides:SetTexture(v) self._texture = v end
function overrides:SetSize(w, h) self._w = w; self._h = h end
function overrides:GetChildren() return end
function overrides:CreateTexture() return NewFrame("Texture") end
function overrides:CreateFontString() return NewFrame("FontString") end
function overrides:SetDataProvider(p) self._provider = p end
function overrides:GetObjectType() return self._type end

local meta = {}
meta.__index = function(self, key)
    if overrides[key] then return overrides[key] end
    if type(key) == "string" and key:match("^[A-Z]") then
        return function(obj) return obj end
    end
    return nil
end

function NewFrame(frameType, name, parent, template)
    local f = setmetatable({ _type = frameType, _name = name, _parent = parent, _template = template,
        _scripts = {}, _events = {}, _text = "", _shown = false }, meta)
    f.Inset = f
    ALL_FRAMES[#ALL_FRAMES + 1] = f
    if name then _G[name] = f end
    return f
end

function CreateFrame(frameType, name, parent, template)
    local f = NewFrame(frameType, name, parent, template)
    if template == "WowScrollBoxList" then f._scrollBox = true end
    return f
end

UIParent = NewFrame("Frame", "UIParent")
GameTooltip = NewFrame("GameTooltip", "GameTooltip")
function PanelTemplates_SetNumTabs() end
function PanelTemplates_SetTab() end
function PanelTemplates_TabResize() end
function SearchBoxTemplate_OnTextChanged() end
function CreateDataProvider(tbl) return { data = tbl } end
ScrollUtil = { InitScrollBoxListWithScrollBar = function(box, bar, view) box._view = view end }
function CreateScrollBoxListGridView()
    local view = {}
    function view:SetElementFactory(fn) self.factory = fn end
    function view:SetElementExtent() end
    function view:SetStride(n) self.stride = n end
    return view
end
C_Timer = { After = function(_, fn) fn() end }

local failures = {}
function check(cond, label)
    if cond then print("  OK   " .. label) else print("  FAIL " .. label); failures[#failures + 1] = label end
end

function find_frame(predicate)
    for _, f in ipairs(ALL_FRAMES) do if predicate(f) then return f end end
end

-- Botones visibles de la cuadricula propia (marcos Button con posicion asignada).
function render()
    local buttons = {}
    for _, f in ipairs(ALL_FRAMES) do
        if f._type == "Button" and f.position and f._shown then buttons[#buttons + 1] = f end
    end
    table.sort(buttons, function(x, y) return x.position < y.position end)
    return buttons
end

function total() return #BI.UI.GetGrid().results end

for _, relative in ipairs(toc_files()) do
    local chunk, err = loadstring(read_file(relative), relative)
    if not chunk then error(err) end
    chunk("BestIcon", BI)
end

print("(1) carga y apertura")
local loader = find_frame(function(f) return f._events.ADDON_LOADED and f._scripts.OnEvent end)
loader._scripts.OnEvent(loader, "ADDON_LOADED", "BestIcon")
check(type(BestIconDB) == "table", "BestIconDB inicializada")
check(BestIconDB.activeTab == 1, "activeTab por defecto")
SlashCmdList.BESTICON("")
local frame = BestIconFrame
check(frame and frame._shown, "ventana abierta con /besticon")
check(BI.Index.IsReady(), "indice listo")

check(BI.UI.GetGrid() and total() == 27714, "cuadricula con todo el catalogo")
local buttons = render()
check(#buttons > 30 and buttons[1].icon._texture ~= nil, "botones visibles con icono")
check(buttons[1]._h == 40, "botones con tamano de icono")
BI.UI.GetGrid().slider._scripts.OnValueChanged(BI.UI.GetGrid().slider, 3)
check(render()[1].position > 1, "el scroll desplaza las filas")
BI.UI.GetGrid().slider._scripts.OnValueChanged(BI.UI.GetGrid().slider, 0)

print("(2) busqueda")
local search = find_frame(function(f) return f._template == "SearchBoxTemplate" end)
search._text = "hoguera"
search._scripts.OnTextChanged(search, true)
check(total() == 2, "'hoguera' da 2 iconos")
search._text = "campfire"
search._scripts.OnTextChanged(search, true)
check(total() == 2, "'campfire' da 2 iconos")
buttons = render()

print("(3) seleccion, historial y favoritos")
buttons[1]._scripts.OnClick(buttons[1], "LeftButton")
check(BI.UI.selected == buttons[1].position, "clic izquierdo selecciona")
check(#BI.History.List() == 1, "historial registra la seleccion")
buttons[1]._scripts.OnClick(buttons[1], "RightButton")
check(#BI.Favorites.List() == 1, "clic derecho anade favorito")
check(buttons[1].favorite._shown, "marca de favorito visible")
check(#BestIconDB.favorites == 1 and #BestIconDB.history == 1, "persistencia en BestIconDB")

print("(4) pestanas")
search._text = ""
BI.UI.SelectTab(2)
check(total() == 1, "pestana Favoritos: 1 icono")
BI.UI.SelectTab(3)
check(total() == 1, "pestana Historial: 1 icono")
check(BestIconDB.activeTab == 3, "pestana activa guardada")
BI.UI.SelectTab(1)
check(total() == 27714, "pestana Todos: catalogo completo")

print("(5) macros y tamano")
buttons = render()
buttons[1]._scripts.OnDoubleClick(buttons[1])
check(BI.Macros.Apply(7808148) == "noPopup", "sin selector de macros abierto: noPopup")
local slider = find_frame(function(f) return f._template == "MinimalSliderTemplate" end)
slider._scripts.OnValueChanged(slider, 48)
check(BestIconDB.iconSize == 48, "tamano de icono guardado")
check(buttons[1]._w == 48, "botones reciclados con el nuevo tamano")

print("(6) cierre y reapertura")
SlashCmdList.BESTICON("")
check(not frame._shown, "se cierra con /besticon")
SlashCmdList.BESTICON("")
check(frame._shown, "se vuelve a abrir")
SlashCmdList.BESTICON("help")

if #failures > 0 then error("fallos: " .. table.concat(failures, "; ")) end
print("SMOKE OK")
"""


def main():
    lua.globals().BI = lua.table()
    lua.globals().CURRENT_LOCALE = sys.argv[1] if len(sys.argv) > 1 else "enUS"
    try:
        lua.execute(MOCK)
    except Exception as error:
        print("ERROR:", error)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
