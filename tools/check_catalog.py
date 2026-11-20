"""Busca iconos nuevos del juego y, si se pide, regenera el catálogo. No necesita abrir el juego.

Uso:
    python tools/check_catalog.py            # informa de lo que hay de nuevo; no cambia nada
    python tools/check_catalog.py --apply    # además regenera Data/Icons_*.lua y apunta la build

Cómo funciona: pide a wago.tools la última build de WoW Forever (producto «wowf») y descarga su
tabla ManifestInterfaceData (CSV con las rutas de los archivos de interfaz). El catálogo del addon
son los iconos de Interface\\ICONS cuyo nombre empieza por inv_, ability_ o spell_ (así lo lista
el selector de macros del cliente; comprobado: coincide con los 27 668 iconos de la build 1.60.1.70959).
Los iconos que el catálogo ya tiene y la tabla no lista (los más recientes) se conservan como Icon_<ID>.
"""
import csv
import re
import sys
import tempfile
import urllib.request
from pathlib import Path

import build_catalog

ROOT = Path(__file__).resolve().parent.parent
STATE = Path(__file__).resolve().parent / "last_build.txt"
PRODUCT = "wowf"
PREFIX = re.compile(r"(inv|ability|spell)_", re.I)
HEADERS = {"User-Agent": "besticon-tools"}


def fetch(url, timeout=300):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def version_key(v):
    return tuple(int(x) for x in v.split("."))


def latest_build():
    import json
    data = json.loads(fetch("https://wago.tools/api/builds"))
    versions = [b["version"] for b in data.get(PRODUCT, []) if re.fullmatch(r"\d+(\.\d+)+", b.get("version", ""))]
    if not versions:
        sys.exit("wago.tools no devuelve builds del producto %s." % PRODUCT)
    return max(versions, key=version_key)


def current_catalog():
    ids = {}
    for p in sorted((ROOT / "Data").glob("Icons_*.lua")):
        for m in re.finditer(r'\{(\d+),"([^"]*)"\}', p.read_text(encoding="utf-8")):
            ids[int(m.group(1))] = m.group(2)
    return ids


def manifest_icons(csv_path):
    names = build_catalog.read_names(csv_path)
    return {i: n for i, n in names.items() if PREFIX.match(n.rsplit("/", 1)[-1])}


def main(apply):
    build = latest_build()
    known = STATE.read_text(encoding="utf-8").strip() if STATE.exists() else "(ninguna)"
    print("Última build de Forever en wago.tools:", build, "| última revisada:", known)

    with tempfile.TemporaryDirectory() as tmp:
        csv_path = Path(tmp) / "ManifestInterfaceData.csv"
        csv_path.write_bytes(fetch("https://wago.tools/db2/ManifestInterfaceData/csv?build=" + build))
        icons = manifest_icons(csv_path)

    catalog = current_catalog()
    new = sorted(i for i in icons if i not in catalog)
    gone = sorted(i for i in catalog if i not in icons and not catalog[i].startswith("Icon_"))
    kept = sorted(i for i in catalog if i not in icons and catalog[i].startswith("Icon_"))
    print("Catálogo actual: %d | en la tabla: %d" % (len(catalog), len(icons)))
    print("Iconos nuevos: %d | desaparecidos: %d | conservados sin nombre (Icon_<ID>): %d" % (len(new), len(gone), len(kept)))
    for i in new[:15]:
        print("  +", i, icons[i])
    if len(new) > 15:
        print("  ... y %d más" % (len(new) - 15))
    for i in gone[:15]:
        print("  -", i, catalog[i])

    if not apply:
        print("No se ha cambiado nada. Con --apply se regenera el catálogo.")
        return
    if not new and not gone:
        STATE.write_text(build + "\n", encoding="utf-8", newline="\n")
        print("Sin cambios en el catálogo; build apuntada.")
        return
    entries = {i: icons[i] for i in icons}
    for i in catalog:
        if i not in entries and catalog[i].startswith("Icon_"):
            entries[i] = catalog[i]
    build_catalog.write_catalog(sorted(entries.items()))
    STATE.write_text(build + "\n", encoding="utf-8", newline="\n")
    print("Catálogo regenerado (%d iconos). Ejecuta los tests y prueba en el juego antes de publicar." % len(entries))


if __name__ == "__main__":
    args = sys.argv[1:]
    if any(a not in ("--apply",) for a in args):
        sys.exit(__doc__)
    main("--apply" in args)
