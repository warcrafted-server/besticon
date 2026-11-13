"""Extrae el vocabulario de las rutas del catálogo y lo guarda con su frecuencia.

Uso: python tools/build_vocab.py [salida.tsv]   (por defecto tools/vocab.tsv)
"""
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GENERIC = {"inv", "ability", "spell", "achievement", "trade", "classic", "ui", "icon", "icons"}


def tokens(name):
    out = []
    for part in name.split("_"):
        for t in re.findall(r"[A-Z]+(?![a-z])|[A-Z]?[a-z]+|\d+", part):
            t = t.lower()
            if not t.isdigit() and len(t) > 1 and t not in GENERIC:
                out.append(t)
    return out


def main(out_path):
    freq = Counter()
    total = 0
    for f in sorted((ROOT / "Data").glob("Icons_*.lua")):
        for name in re.findall(r'\{\d+,"([^"]+)"\}', f.read_text(encoding="utf-8")):
            total += 1
            freq.update(set(tokens(name)))
    rows = freq.most_common()
    Path(out_path).write_text("\n".join("%s\t%d" % r for r in rows) + "\n", encoding="utf-8", newline="\n")
    print("iconos:", total, "| tokens distintos:", len(rows), "| con >=3 iconos:", sum(1 for _, c in rows if c >= 3))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ROOT / "tools" / "vocab.tsv")
