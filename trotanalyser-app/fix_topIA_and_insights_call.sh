#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_topIA_and_insights_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) corriger toute occurrence restante de topIA
s, n1 = re.subn(r'\btopIA\b', 'top3IA', s)

# 2) corriger l'appel CourseInsights pour lui passer participants
pattern = re.compile(r'<CourseInsights\s+styles=\{styles\}\s*/>')
replacement = '<CourseInsights participants={sortedParticipants} styles={styles} />'
s, n2 = pattern.subn(replacement, s, count=1)

p.write_text(s, encoding="utf-8")

print(f"topIA -> top3IA : {n1}")
print(f"CourseInsights corrigé : {n2}")
PY

echo
echo "=== VERIFICATION ==="
grep -n '\btopIA\b' app/course.tsx || true
grep -n 'CourseInsights' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
