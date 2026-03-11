#!/bin/bash
set -e

FILE="components/course/CourseHorseInlineCard.tsx"
BACKUP="backups/card_before_fix_props_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("components/course/CourseHorseInlineCard.tsx")
s = p.read_text()

# supprimer la ligne participants dans Props
s = re.sub(r'\s*participants\s*:\s*[^;]+;', '', s)

p.write_text(s)
print("Prop participants supprimée du type Props")
PY

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
