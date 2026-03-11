#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_prop_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

# supprimer prop sortedParticipants si elle est passée au composant
s = re.sub(r'\s*sortedParticipants=\{sortedParticipants\}', '', s)

p.write_text(s)
print("Prop sortedParticipants supprimée")
PY

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
