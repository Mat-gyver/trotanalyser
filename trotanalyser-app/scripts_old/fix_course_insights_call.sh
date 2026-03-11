#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_insights_call_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

pattern = re.compile(
    r'<CourseInsights[\s\S]*?styles=\{styles\}\s*/>',
    re.MULTILINE
)

replacement = """<CourseInsights
        participants={sortedParticipants}
        styles={styles}
      />"""

new_s, count = pattern.subn(replacement, s, count=1)

if count == 0:
    raise SystemExit("Bloc CourseInsights introuvable")

p.write_text(new_s, encoding="utf-8")
print("Appel CourseInsights corrigé")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
