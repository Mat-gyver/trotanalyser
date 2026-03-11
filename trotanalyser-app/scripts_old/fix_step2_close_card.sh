#!/bin/bash
set -e

FILE="app/course.tsx"

BACKUP="backups/course_before_fix_step2_$(date +%Y%m%d_%H%M%S).tsx"
mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
lines = p.read_text().splitlines()

open_idx = None
for i,l in enumerate(lines):
    if "<CourseHorseInlineCard key={String(c.numero)}>" in l:
        open_idx = i

if open_idx is None:
    raise SystemExit("Ouverture carte introuvable")

close_idx = None
for i in range(len(lines)-1, open_idx, -1):
    if lines[i].strip() == "</View>":
        close_idx = i
        break

if close_idx is None:
    raise SystemExit("Fermeture carte introuvable")

lines[close_idx] = lines[close_idx].replace("</View>", "</CourseHorseInlineCard>")

p.write_text("\n".join(lines))

print("Fermeture carte corrigée ligne", close_idx+1)
PY

npx tsc --noEmit --pretty false
