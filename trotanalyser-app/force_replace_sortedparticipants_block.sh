#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_force_replace_map_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

old_pat = r"""\{sortedParticipants\.map\(\(c\)\s*=>\s*\([\s\S]*?\)\)\}"""
new_block = """{sortedParticipants.map((horse) => (
  <CourseHorseCard
    key={String(horse.numero)}
    horse={horse}
  />
))}"""

m = re.search(old_pat, s)
if not m:
    raise SystemExit("Bloc exact {sortedParticipants.map((c) => (...))} introuvable")

s = s[:m.start()] + new_block + s[m.end():]

p.write_text(s, encoding="utf-8")
print("Bloc sortedParticipants remplacé par CourseHorseCard")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
