#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
CARD_FILE="components/course/CourseHorseInlineCard.tsx"

mkdir -p backups

cp "$COURSE_FILE" "backups/course_before_final_fix_$(date +%Y%m%d_%H%M%S).tsx"
cp "$CARD_FILE" "backups/card_before_final_fix_$(date +%Y%m%d_%H%M%S).tsx"

python3 <<'PY'
from pathlib import Path
import re

# -------- fix topIA -> top3IA --------

course = Path("app/course.tsx")
s = course.read_text()

s = re.sub(r'\btopIA\b', 'top3IA', s)

course.write_text(s)
print("topIA remplacé par top3IA")

# -------- supprimer participants des Props --------

card = Path("components/course/CourseHorseInlineCard.tsx")
s = card.read_text()

s = re.sub(r'\s*participants\s*:\s*[^;]+;', '', s)

card.write_text(s)
print("participants supprimé du type Props")

PY

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
