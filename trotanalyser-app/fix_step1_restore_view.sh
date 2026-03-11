#!/bin/bash
set -e

FILE="app/course.tsx"

BACKUP="backups/course_before_fix_step1_$(date +%Y%m%d_%H%M%S).tsx"
mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
lines = p.read_text().splitlines()

for i,l in enumerate(lines):
    if "</CourseHorseInlineCard>" in l:
        lines[i] = l.replace("</CourseHorseInlineCard>", "</View>")
        print("Correction ligne", i+1)
        break

p.write_text("\n".join(lines))
PY

npx tsc --noEmit --pretty false
