#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_topia_and_callbacks_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) Corriger toutes les variantes restantes
s, n1 = re.subn(r'\btopIA\b', 'top3IA', s)
s, n2 = re.subn(r'\btopIa\b', 'top3IA', s)

# 2) Corriger les callbacks map/filter les plus courants pour noImplicitAny
replacements = [
    (r'\.map\(\(c\)\s*=>', '.map((c: any) =>'),
    (r'\.filter\(\(c\)\s*=>', '.filter((c: any) =>'),
    (r'\.some\(\(c\)\s*=>', '.some((c: any) =>'),
    (r'\.find\(\(c\)\s*=>', '.find((c: any) =>'),
    (r'\.sort\(\(\s*a\s*,\s*b\s*\)\s*=>', '.sort((a: any, b: any) =>'),
    (r'\.map\(\(\s*badge\s*,\s*index\s*\)\s*=>', '.map((badge: any, index: number) =>'),
    (r'\.map\(\(\s*tag\s*,\s*index\s*\)\s*=>', '.map((tag: any, index: number) =>'),
    (r'\.map\(\(\s*line\s*,\s*i\s*\)\s*=>', '.map((line: any, i: number) =>'),
]

total = 0
for pattern, repl in replacements:
    s, n = re.subn(pattern, repl, s)
    total += n

p.write_text(s, encoding="utf-8")

print(f"topIA -> top3IA: {n1}")
print(f"topIa -> top3IA: {n2}")
print(f"callbacks typés: {total}")
PY

echo
echo "=== VERIFICATION ==="
grep -n '\btopIA\b\|\btopIa\b' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
