"""Genera dist/BestIcon-<version>.zip con una sola carpeta raíz BestIcon/ lista para CurseForge.

Uso: python tools/package.py
La versión sale de BestIcon/BestIcon.toc. Incluye LICENSE y CREDITS.md dentro de la carpeta del addon.
"""

import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "BestIcon"


def version():
    match = re.search(r"^## Version:\s*(\S+)", (ADDON / "BestIcon.toc").read_text(encoding="utf-8"), re.M)
    if not match:
        raise SystemExit("No hay '## Version:' en BestIcon.toc")
    return match.group(1)


def main():
    name = version()
    out = ROOT / "dist" / f"BestIcon-{name}.zip"
    out.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(ADDON.rglob("*")):
            if path.is_file() and "__pycache__" not in path.parts:
                zf.write(path, "BestIcon/" + path.relative_to(ADDON).as_posix())
        for extra in ("LICENSE", "CREDITS.md"):
            zf.write(ROOT / extra, "BestIcon/" + extra)
    print(out, round(out.stat().st_size / 1024), "KB")


if __name__ == "__main__":
    main()
