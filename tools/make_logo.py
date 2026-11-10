"""Genera docs/curseforge/logo.png (400x400): rejilla de iconos con lupa, dibujada por código."""

import random
from pathlib import Path

from PIL import Image, ImageDraw

S = 400
OUT = Path(__file__).resolve().parent.parent / "docs" / "curseforge" / "logo.png"
random.seed(7)
PALETTE = [(200, 70, 50), (60, 130, 200), (90, 170, 90), (220, 170, 50), (150, 90, 190), (70, 170, 170)]

img = Image.new("RGB", (S, S), (28, 20, 14))
d = ImageDraw.Draw(img)
d.rounded_rectangle((8, 8, S - 9, S - 9), 28, outline=(170, 135, 60), width=6, fill=(40, 30, 22))
d.rounded_rectangle((20, 20, S - 21, S - 21), 20, outline=(90, 70, 35), width=2)

cell, gap, n = 62, 10, 4
x0 = (S - (n * cell + (n - 1) * gap)) // 2
for r in range(n):
    for c in range(n):
        x, y = x0 + c * (cell + gap), x0 + r * (cell + gap)
        base = random.choice(PALETTE)
        d.rounded_rectangle((x, y, x + cell, y + cell), 8, fill=(20, 15, 10), outline=(110, 90, 50), width=2)
        d.rounded_rectangle((x + 5, y + 5, x + cell - 5, y + cell - 5), 5, fill=base)
        d.polygon([(x + 5, y + 5), (x + cell - 5, y + 5), (x + 5, y + cell - 5)],
                  fill=tuple(min(255, v + 45) for v in base))

lens = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ld = ImageDraw.Draw(lens)
cx, cy, rad = 235, 235, 92
ld.ellipse((cx - rad, cy - rad, cx + rad, cy + rad), fill=(255, 255, 255, 38))
ld.ellipse((cx - rad, cy - rad, cx + rad, cy + rad), outline=(232, 190, 80, 255), width=14)
ld.line((cx + 66, cy + 66, 352, 352), fill=(150, 105, 40, 255), width=26)
ld.line((cx + 66, cy + 66, 352, 352), fill=(232, 190, 80, 255), width=14)
img = Image.alpha_composite(img.convert("RGBA"), lens).convert("RGB")
OUT.parent.mkdir(parents=True, exist_ok=True)
img.save(OUT)
print(OUT)
