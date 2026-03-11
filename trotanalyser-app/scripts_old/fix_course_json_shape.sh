#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_json_shape_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# Corrige setData(json.data) -> setData(json?.data ?? json)
s, n1 = re.subn(
    r'setData\(\s*json\.data\s*\)',
    'setData(json?.data ?? json)',
    s
)

# Corrige setData(res.data) si jamais présent
s, n2 = re.subn(
    r'setData\(\s*res\.data\s*\)',
    'setData(res?.data ?? res)',
    s
)

# Corrige les gardes trop strictes sur participants
s, n3 = re.subn(
    r'if\s*\(\s*!\s*json\.data\s*\)\s*return',
    'if (!json) return',
    s
)

p.write_text(s, encoding="utf-8")
print(f"setData(json.data) corrigé: {n1}")
print(f"setData(res.data) corrigé: {n2}")
print(f"garde json.data corrigée: {n3}")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'setData' app/course.tsx || true
grep -n 'json\.data\|res\.data' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
