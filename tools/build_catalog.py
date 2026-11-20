"""Genera Data/Icons_NN.lua a partir del volcado /bidump y la tabla ManifestInterfaceData del juego.

Uso: python tools/build_catalog.py <BestIconDump.lua> <ManifestInterfaceData.csv>

ManifestInterfaceData (columnas ID, FilePath, FileName) es una tabla de Blizzard incluida en el
cliente; el CSV se exporta de la misma build, por ejemplo desde wago.tools (tabla ManifestInterfaceData,
build del cliente, formato CSV). Los iconos que la tabla no lista se nombran Icon_<ID>.
"""
import csv
import re
import sys
from pathlib import Path

CHUNK = 3000
OUT = Path(__file__).resolve().parent.parent / "Data"


def read_ids(dump_path):
    text = Path(dump_path).read_text(encoding="utf-8")
    ids = set()
    for name in ("GetMacroIcons", "GetMacroItemIcons", "GetLooseMacroIcons"):
        i = text.find('["%s"] = {' % name)
        if i < 0:
            continue
        j = text.find('["list"] = {', i)
        k = text.find("}", j)
        ids.update(int(x) for x in re.findall(r"^(\d+),", text[j:k], re.M))
    return ids


def read_names(manifest):
    names = {}
    prefix = "interface\\icons\\"
    with open(manifest, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            path, file = row["FilePath"], row["FileName"]
            if path.lower().startswith(prefix) and file.lower().endswith(".blp"):
                sub = path[len(prefix):].replace("\\", "/")
                names[int(row["ID"])] = sub + file[:-4]
    return names


def write_catalog(entries):
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("Icons_*.lua"):
        old.unlink()
    for n, start in enumerate(range(0, len(entries), CHUNK), 1):
        rows = ",\n".join('{%d,"%s"}' % e for e in entries[start:start + CHUNK])
        (OUT / ("Icons_%02d.lua" % n)).write_text(
            "-- Generado por tools/build_catalog.py. No editar a mano.\n"
            "local _, BI = ...\nBI.DB.chunks[#BI.DB.chunks + 1] = {\n" + rows + ",\n}\n",
            encoding="utf-8", newline="\n")
    print("iconos:", len(entries), "| archivos:", -(-len(entries) // CHUNK))


def main(dump_path, manifest):
    ids = read_ids(dump_path)
    names = read_names(manifest)
    print("sin nombre en la tabla:", sum(1 for i in ids if i not in names))
    write_catalog(sorted((i, names.get(i, "Icon_%d" % i)) for i in ids))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(*sys.argv[1:])
