#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_card_line_replace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

pattern = r'<View key=\{String\(c\.numero\)\} style=\{styles\.card\}>'

replacement = '<CourseHorseCard key={String(c.numero)} horse={c} />'

if re.search(pattern, s):
    s = re.sub(pattern, replacement, s, count=1)
    p.write_text(s)
    print("Carte remplacée par CourseHorseCard")
else:
    print("Ligne carte non trouvée")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
