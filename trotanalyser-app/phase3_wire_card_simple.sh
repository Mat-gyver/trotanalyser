#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_phase3_simple_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

import_line = 'import CourseHorseCard from "../components/course/CourseHorseCard";'

# Ajouter import si absent
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    last = imports[-1]
    s = s[:last.end()] + "\n" + import_line + s[last.end():]

# remplacer map simple
s = re.sub(
    r'\{sortedParticipants\.map\([^)]*\)\}',
    '{sortedParticipants.map((horse) => (<CourseHorseCard key={String(horse.numero)} horse={horse} />))}',
    s
)

s = re.sub(
    r'\{participants\.map\([^)]*\)\}',
    '{participants.map((horse) => (<CourseHorseCard key={String(horse.numero)} horse={horse} />))}',
    s
)

p.write_text(s, encoding="utf-8")
print("Carte cheval branchée")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
