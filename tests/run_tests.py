"""Tests del catálogo, índice y búsqueda de BestIcon fuera del cliente."""

import sys
import time
from pathlib import Path

from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "BestIcon"
LOCALE = sys.argv[1] if len(sys.argv) > 1 else "enUS"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
BI = {}
CURRENT_LOCALE = "enUS"
UISpecialFrames = {}
SlashCmdList = {}
function GetLocale() return CURRENT_LOCALE end
function CreateFrame(...)
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
        Hide = function() end,
        Show = function() end,
        IsShown = function() return false end,
        SetSize = function() end,
        SetClampedToScreen = function() end,
        SetMovable = function() end,
        EnableMouse = function() end,
        RegisterForDrag = function() end,
        CreateFontString = function() return { SetPoint = function() end, SetText = function() end } end,
        StartMoving = function() end,
        StopMovingOrSizing = function() end,
        GetPoint = function() return "CENTER", nil, "CENTER", 0, 0 end,
        ClearAllPoints = function() end,
        SetPoint = function() end,
    }
end
C_Timer = {}
""")
lua.globals().CURRENT_LOCALE = LOCALE

BI = lua.globals().BI
loader = lua.eval("function(source, name) local chunk, err = loadstring(source, name); if not chunk then error(err) end; return chunk end")


def load_toc():
    files = []
    for line in (ADDON / "BestIcon.toc").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("##") or line.startswith("UI/"):
            continue
        files.append(line)
    for relative in files:
        path = ADDON / relative
        chunk = loader(path.read_text(encoding="utf-8"), relative)
        chunk("BestIcon", BI)
    return files


def to_list(value):
    return [value[i] for i in range(1, len(value) + 1)]


def name_of(position):
    result = BI.DB.Get(position)
    return result[1] if isinstance(result, tuple) else result


def names_of(positions):
    return {name_of(position) for position in positions}


def id_of(position):
    result = BI.DB.Get(position)
    return result[0] if isinstance(result, tuple) else result


failures = []


def check(condition, label):
    if condition:
        print("  OK   " + label)
    else:
        print("  FAIL " + label)
        failures.append(label)


def main():
    started = time.perf_counter()
    files = load_toc()
    print("TOC: %d archivos cargados (sin UI/)" % len(files))

    print("(a) normalizacion")
    check(BI.Normalize("HOGUERAS") == "hogueras", "Normalize minusculas")
    check(BI.Normalize("Poción") == "pocion", "Normalize tildes")
    check(BI.Normalize("Pingüino") == "pinguino", "Normalize dieresis")
    check(BI.Normalize("ÁÉÍÓÚÜÑÇ") == "aeiouunc", "Normalize mayusculas acentuadas")
    check(BI.Stem("hogueras") == "hoguera", "Stem hogueras")
    check(BI.Stem("pociones") == "pocion", "Stem pociones")
    check(BI.Stem("bolsas") == "bolsa", "Stem bolsas")
    check(BI.Stem("totems") == "totem", "Stem totems")
    check(to_list(BI.Words("¡Hogueras, FOGATA!_camp")) == ["hoguera", "fogata", "camp"], "Words")

    print("(b) catalogo")
    check(BI.DB.Count() == 27714, "Count == 27714")
    by_id = BI.DB.GetByID(7808148)
    check(by_id[1] == "INV_Camelot_Camping_WelcomingCampfire", "GetByID nombre")
    check(BI.DB.Path(7808148) == "Interface\\ICONS\\INV_Camelot_Camping_WelcomingCampfire", "Path")
    first_id, first_name = BI.DB.Get(1)
    check(first_id is not None and first_name is not None, "Get(1)")

    print("(b2) indice")
    build_started = time.perf_counter()
    BI.Index.BuildSync()
    build_elapsed = time.perf_counter() - build_started
    check(BI.Index.IsReady(), "IsReady")
    print("       BuildSync: %.3f s, tokens: %d, alias: %d" % (
        build_elapsed, len(BI.Index.TokenKeys()), len(BI.Index.AliasKeys())))

    print("(c) campamento")
    required = {
        "INV_Camelot_Camping_CampfireNearby",
        "INV_Camelot_Camping_WelcomingCampfire",
    }
    for query in ("hoguera", "Hogueras", "campfire", "fogata"):
        names = names_of(to_list(BI.Search.Run(query)))
        check(required <= names, "%r incluye los dos Campfire" % query)
    for query in ("camp", "campamento"):
        names = names_of(to_list(BI.Search.Run(query)))
        check("INV_Camelot_Camping_CampBenefits" in names, "%r incluye CampBenefits" % query)

    print("(d) pares EN/ES")
    pairs = [
        ("campfire", "hoguera"), ("fish", "pescado"), ("food", "comida"),
        ("totem", "totem"), ("lightning", "rayo"), ("storm", "tormenta"),
        ("sword", "espada"), ("shield", "escudo"), ("cooking", "cocina"),
        ("fishing", "pesca"), ("bedroll", "saco de dormir"), ("fire", "fuego"),
        ("potion", "pocion"), ("herb", "hierba"), ("gem", "gema"),
        ("bag", "bolsa"), ("mount", "montura"), ("dragon", "dragon"),
        ("skull", "calavera"), ("scroll", "pergamino"), ("key", "llave"),
        ("bear", "oso"), ("wolf", "lobo"), ("ring", "anillo"),
        ("cape", "capa"), ("helm", "yelmo"), ("glove", "guantes"),
        ("belt", "cinturon"), ("shoulder", "hombreras"), ("armor", "armadura"),
        ("axe", "hacha"), ("bow", "arco"), ("staff", "baston"),
        ("wand", "varita"), ("dagger", "daga"), ("mace", "maza"),
        ("hammer", "martillo"), ("arrow", "flecha"), ("book", "libro"),
        ("coin", "moneda"), ("tent", "tienda"), ("water", "agua"),
        ("ice", "hielo"),
    ]
    pair_failures = []
    warnings = []
    for en, es in pairs:
        en_positions = set(to_list(BI.Search.Run(en)))
        es_positions = set(to_list(BI.Search.Run(es)))
        exact_table = BI.Index.TokenPostings(en)
        exact = set(to_list(exact_table)) if exact_table is not None else set()
        union = en_positions | es_positions
        diff = en_positions ^ es_positions
        missing_en = exact - en_positions
        missing_es = exact - es_positions
        ratio = (len(diff) / len(union)) if union else 1.0
        if not en_positions or not es_positions:
            check(False, "%s / %s (resultado vacio)" % (en, es))
            pair_failures.append("%s/%s: resultado vacio" % (en, es))
            continue
        ok = not missing_en and not missing_es and ratio <= 0.30
        if ok:
            print("  OK   %s / %s" % (en, es))
        else:
            message = (
                "%s/%s: en=%d es=%d exact=%d diff=%.0f%% missing_en=%d missing_es=%d"
                % (en, es, len(en_positions), len(es_positions), len(exact),
                   ratio * 100, len(missing_en), len(missing_es))
            )
            print("  WARN " + message)
            warnings.append(message)
    if pair_failures:
        print("       Fallos de pares:")
        for line in pair_failures:
            print("       - " + line)
    if warnings:
        print("       Avisos de pares (diferencia > 30%% o falta un token exacto):")
        for line in warnings:
            print("       - " + line)

    print("(e) ID y ruta")
    numeric = to_list(BI.Search.Run("7808148"))
    check(bool(numeric) and name_of(numeric[0]) == "INV_Camelot_Camping_WelcomingCampfire",
          "busqueda por ID exacto")
    prefix = to_list(BI.Search.Run("78081"))
    check(bool(prefix) and all(str(id_of(p)).startswith("78081") for p in prefix),
          "busqueda por prefijo de ID")
    path = to_list(BI.Search.Run("Interface\\ICONS\\INV_Camelot_Camping_WelcomingCampfire"))
    check(bool(path) and name_of(path[0]) == "INV_Camelot_Camping_WelcomingCampfire",
          "busqueda por ruta")

    print("(f) categoria")
    camps = to_list(BI.Search.Run("camp", "camps"))
    check(bool(camps) and all(BI.Index.InCategory("camps", p) for p in camps),
          "filtro camps")
    all_camps = to_list(BI.Search.Run("", "camps"))
    check(bool(all_camps) and all(BI.Index.InCategory("camps", p) for p in all_camps),
          "categoria con consulta vacia")

    print("(g) rendimiento")
    queries = ["camp", "fire", "sword", "fish", "hoguera", "pocion", "dragon",
               "agua", "tela", "mount", "staff", "calavera", "oro", "wolf",
               "comida", "ice", "llave", "cooking", "shield", "anillo"]
    search_started = time.perf_counter()
    for i in range(200):
        BI.Search.Run(queries[i % len(queries)])
    elapsed = time.perf_counter() - search_started
    check(elapsed < 2.0, "200 busquedas en %.3f s (< 2 s)" % elapsed)

    print("(h) cadenas visibles")
    localized = True
    for i in range(1, len(BI.Categories) + 1):
        key = BI.Categories[i].key
        value = BI.L["cat_" + key]
        if value == "cat_" + key or not value:
            localized = False
    check(localized, "categorias localizadas en BI.L")
    logic = ["Core/DB.lua", "Search/Normalize.lua", "Search/Index.lua",
             "Search/Search.lua", "Data/Categories.lua"]
    visible = False
    for relative in logic:
        text = (ADDON / relative).read_text(encoding="utf-8")
        if "print(" in text:
            visible = True
    check(not visible, "sin print() en la logica")

    total = time.perf_counter() - started
    print("Tiempo total: %.3f s" % total)
    if failures:
        print("FALLOS: %d" % len(failures))
        return 1
    print("TODO OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
