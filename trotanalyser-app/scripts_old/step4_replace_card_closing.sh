#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_step4_close_replace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
lines = p.read_text(encoding="utf-8", errors="ignore").splitlines()

open_idx = None
for i,l in enumerate(lines):
    if "<CourseHorseInlineCard key={String(c.numero)}>" in l:
        open_idx = i
        break

if open_idx is None:
    raise SystemExit("Ouverture CourseHorseInlineCard introuvable")

close_idx = None
for i in range(open_idx+1, len(lines)):
    if lines[i].strip() == "</View>":
        close_idx = i
        break

if close_idx is None:
    raise SystemExit("Fermeture </View> correspondante introuvable")

lines[close_idx] = lines[close_idx].replace("</View>", "</CourseHorseInlineCard>")

p.write_text("\n".join(lines), encoding="utf-8")

print("Fermeture de carte remplacée")
PY

npx tsc --noEmit --pretty false
