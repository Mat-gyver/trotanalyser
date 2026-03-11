#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_top3ia_array_usage_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# top3IA est un tableau -> on corrige les accès objet
s, n1 = re.subn(r'\btop3IA\.numero\b', 'top3IA[0]?.numero', s)
s, n2 = re.subn(r'\btop3IA\.probabiliteIA\b', 'top3IA[0]?.probabiliteIA', s)
s, n3 = re.subn(r'\btop3IA\.scoreIA\b', 'top3IA[0]?.scoreIA', s)
s, n4 = re.subn(r'\btop3IA\.nom\b', 'top3IA[0]?.nom', s)

p.write_text(s, encoding="utf-8")

print(f"top3IA.numero corrigé: {n1}")
print(f"top3IA.probabiliteIA corrigé: {n2}")
print(f"top3IA.scoreIA corrigé: {n3}")
print(f"top3IA.nom corrigé: {n4}")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'top3IA\.' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
