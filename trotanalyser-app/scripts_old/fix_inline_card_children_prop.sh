#!/bin/bash
set -e

FILE="components/course/CourseHorseInlineCard.tsx"
BACKUP="backups/CourseHorseInlineCard_before_children_fix_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path

p = Path("components/course/CourseHorseInlineCard.tsx")
s = p.read_text()

if "children?:" not in s:
    s = s.replace(
        "styles: any;",
        "styles: any;\n  children?: React.ReactNode;"
    )

p.write_text(s)
print("Prop children ajoutée")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
