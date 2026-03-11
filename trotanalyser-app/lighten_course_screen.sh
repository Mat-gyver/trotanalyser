#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_lighten_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

# supprimer les anciennes fonctions utilitaires qui ont été déplacées
patterns = [
r'const scoreBar[\s\S]*?};',
r'const pariStars[\s\S]*?};',
r'const noteColor[\s\S]*?};',
r'const alertTags[\s\S]*?};',
r'const getMeteoIcon[\s\S]*?};',
r'const souplesseIndex[\s\S]*?};',
r'const souplesseLabel[\s\S]*?};'
]

for pat in patterns:
    s = re.sub(pat, '', s)

# nettoyer espaces multiples
s = re.sub(r'\n{3,}', '\n\n', s)

p.write_text(s)

print("course.tsx allégé")
PY

echo
echo "=== nouvelle taille ==="
wc -l app/course.tsx
