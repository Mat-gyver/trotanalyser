#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
CARD_FILE="components/course/CourseHorseInlineCard.tsx"

mkdir -p backups
cp "$COURSE_FILE" "backups/course_before_force_fix_$(date +%Y%m%d_%H%M%S).tsx"
cp "$CARD_FILE" "backups/card_before_force_fix_$(date +%Y%m%d_%H%M%S).tsx"

python3 <<'PY'
from pathlib import Path
import re

course = Path("app/course.tsx")
card = Path("components/course/CourseHorseInlineCard.tsx")

s = course.read_text(encoding="utf-8", errors="ignore")

# 1) topIA -> top3IA
s, n1 = re.subn(r'\btopIA\b', 'top3IA', s)

course.write_text(s, encoding="utf-8")

c = card.read_text(encoding="utf-8", errors="ignore")

# 2) retirer toute ligne participants: ...; dans Props
c, n2 = re.subn(r'^\s*participants\s*:\s*[^;]+;\s*$', '', c, flags=re.M)

card.write_text(c, encoding="utf-8")

print(f"topIA remplacé: {n1}")
print(f"participants retiré des Props: {n2}")
PY

echo
echo "=== VERIFICATION 1 ==="
grep -n '\btopIA\b' app/course.tsx || true
grep -n 'participants\s*:' components/course/CourseHorseInlineCard.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
