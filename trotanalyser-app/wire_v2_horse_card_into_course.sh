#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_wire_v2_horse_card_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

old_import = 'import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";'
new_import = 'import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard_v2";'

if old_import in s:
    s = s.replace(old_import, new_import, 1)
elif new_import not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + new_import + s[insert_at:]

start_marker = '{sortedParticipants.map((c) => ('
start = s.find(start_marker)
if start == -1:
    raise SystemExit("Début du bloc map introuvable")

search_from = start + len(start_marker)
end_marker = '))}'
end = s.find(end_marker, search_from)
if end == -1:
    raise SystemExit("Fin du bloc map introuvable")

replacement = """{sortedParticipants.map((c) => (
  <CourseHorseInlineCard
    key={String(c.numero)}
    c={c}
    renderCasaque={renderCasaque}
    scoreBar={scoreBar}
    iaProbBar={iaProbBar}
    noteColor={noteColor}
    shortAnalyse={shortAnalyse}
    alertTags={alertTags}
    pariStars={pariStars}
    styles={styles}
  />
))}"""

s = s[:start] + replacement + s[end + len(end_marker):]

p.write_text(s, encoding="utf-8")
print("Bloc chevaux remplacé par CourseHorseInlineCard_v2")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
