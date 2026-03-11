#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_header_replace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# remplacer headerBox + pronoBox par le composant
pattern = r"<View style=\{styles\.headerBox\}[\s\S]*?<View style=\{styles\.pronoBox\}[\s\S]*?<\/View>"
replacement = "      <CourseHeader data={data} />"

new = re.sub(pattern, replacement, s)

if new == s:
    raise SystemExit("Bloc header non trouvé")

p.write_text(new, encoding="utf-8")

print("Header remplacé par CourseHeader")
PY

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false
