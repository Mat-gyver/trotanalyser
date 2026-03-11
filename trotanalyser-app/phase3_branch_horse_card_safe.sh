#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_phase3_safe_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

import_line = 'import CourseHorseCard from "../components/course/CourseHorseCard";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Aucun import trouvé dans app/course.tsx")
    last_import = imports[-1]
    s = s[:last_import.end()] + "\n" + import_line + s[last_import.end():]

patterns = [
    (
        "sortedParticipants",
        r'\{sortedParticipants\.map\(\((?P<args>[^)]*)\)\s*=>\s*\(\s*<View style=\{styles\.horseCardTest\}>[\s\S]*?\)\)\}'
    ),
    (
        "participants",
        r'\{participants\.map\(\((?P<args>[^)]*)\)\s*=>\s*\(\s*<View style=\{styles\.horseCardTest\}>[\s\S]*?\)\)\}'
    ),
]

replaced = False

for src, pat in patterns:
    m = re.search(pat, s)
    if not m:
        continue
    args = m.group("args").strip()
    var_name = args.split(",")[0].strip() or "horse"

    new_block = f'''{{{src}.map(({args}) => (
  <CourseHorseCard
    key={{String({var_name}.numero)}}
    horse={{{var_name}}}
  />
))}}'''

    s = s[:m.start()] + new_block + s[m.end():]
    replaced = True
    break

if not replaced:
    raise SystemExit("Bloc carte inline introuvable. Aucun changement appliqué.")

p.write_text(s, encoding="utf-8")
print("Phase 3 safe appliquée : CourseHorseCard branché")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
