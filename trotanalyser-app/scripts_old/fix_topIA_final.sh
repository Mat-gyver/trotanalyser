#!/bin/bash
set -e

FILE="app/course.tsx"

mkdir -p backups
cp "$FILE" "backups/course_before_fix_topIA_$(date +%Y%m%d_%H%M%S).tsx"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

# remplacer toute occurrence restante
s = re.sub(r'\btopIA\b', 'top3IA', s)

p.write_text(s)

print("Toutes les occurrences topIA -> top3IA corrigées")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
