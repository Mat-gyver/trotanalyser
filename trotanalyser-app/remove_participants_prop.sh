#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_remove_participants_prop_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

patterns = [
    r'\n[ \t]*participants=\{[^}]*\}',
    r'[ \t]+participants=\{[^}]*\}',
]

count = 0
for pattern in patterns:
    s, n = re.subn(pattern, '', s)
    count += n

p.write_text(s, encoding="utf-8")
print(f"Prop participants supprimée ({count} occurrence(s))")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
