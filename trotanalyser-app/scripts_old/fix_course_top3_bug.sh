#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_top3_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text()

s = s.replace(
    "const top3 = sortedParticipants.slice(0, 3);[0];",
    "const top3 = sortedParticipants.slice(0, 3)[0];"
)

p.write_text(s)
print("Correction top3 appliquée")
PY

echo
echo "=== VERIFICATION ==="
grep -n "top3" app/course.tsx || true
