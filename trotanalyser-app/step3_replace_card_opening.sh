#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_step3_open_replace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

old = '<View key={String(c.numero)} style={styles.card}>'
new = '<CourseHorseInlineCard key={String(c.numero)}>'

if old not in s:
    raise SystemExit("Ligne d'ouverture de carte introuvable")

s = s.replace(old, new, 1)

p.write_text(s, encoding="utf-8")
print("Ouverture de carte remplacée")
PY

npx tsc --noEmit --pretty false
