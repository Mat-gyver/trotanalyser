#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_remove_duplicates_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

targets = [
    '      <CourseSummary data={data} />\n',
    '      <CoursePhysiology data={data} />\n',
    '      <CourseSummary data={data} />',
    '      <CoursePhysiology data={data} />',
]

before = s
for t in targets:
    s = s.replace(t, "")

if s == before:
    raise SystemExit("Aucune ligne dupliquée trouvée à supprimer")

p.write_text(s, encoding="utf-8")
print("Doublons CourseSummary / CoursePhysiology supprimés")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
