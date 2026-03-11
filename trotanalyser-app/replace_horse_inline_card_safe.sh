#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_inline_card_replace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

import_line = 'import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

start_marker = "{sortedParticipants.map((c) => ("
start = s.find(start_marker)
if start == -1:
    raise SystemExit("Début du bloc map introuvable")

search_from = start + len(start_marker)
end_marker = "))}"
end = s.find(end_marker, search_from)
if end == -1:
    raise SystemExit("Fin du bloc map introuvable")

replacement = """{sortedParticipants.map((c) => (
  <CourseHorseInlineCard
    key={String(c.numero)}
    horse={c}
  />
))}"""

s = s[:start] + replacement + s[end + len(end_marker):]

p.write_text(s, encoding="utf-8")
print("Bloc chevaux remplacé par CourseHorseInlineCard")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
