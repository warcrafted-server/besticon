"""Genera Data/Icons_NN.lua a partir del volcado /bidump y el listfile comunitario.

Uso: python tools/build_catalog.py <BestIconDump.lua> <community-listfile-withcapitals.csv>
"""
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


def read_names(listfile):
    names = {}
    prefix = "interface/icons/"
    for line in Path(listfile).read_text(encoding="utf-8").splitlines():
        fid, _, path = line.partition(";")
        if path.lower().startswith(prefix) and path.lower().endswith(".blp"):
            names[int(fid)] = path[len(prefix):-4]
    return names


def main(dump_path, listfile):
    ids = read_ids(dump_path)
    names = read_names(listfile)
    missing = sorted(i for i in ids if i not in names)
    entries = sorted((i, names[i]) for i in ids if i in names)
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("Icons_*.lua"):
        old.unlink()
    for n, start in enumerate(range(0, len(entries), CHUNK), 1):
        rows = ",\n".join('{%d,"%s"}' % e for e in entries[start:start + CHUNK])
        (OUT / ("Icons_%02d.lua" % n)).write_text(
            "-- Generado por tools/build_catalog.py. No editar a mano.\n"
            "local _, BI = ...\nBI.DB.chunks[#BI.DB.chunks + 1] = {\n" + rows + ",\n}\n",
            encoding="utf-8", newline="\n")
    print("iconos:", len(entries), "| sin nombre:", len(missing), "| archivos:", -(-len(entries) // CHUNK))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(*sys.argv[1:])
