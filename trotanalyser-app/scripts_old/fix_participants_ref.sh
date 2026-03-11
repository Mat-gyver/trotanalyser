#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_participants_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

# remplace participants par sortedParticipants uniquement dans les usages
s = re.sub(r'\bparticipants\b', 'sortedParticipants', s)

p.write_text(s)
print("Références participants corrigées")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
