#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_phase3_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

import_line = 'import CourseHorseCard from "../components/course/CourseHorseCard";'

# 1) ajouter l'import si absent
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Aucun bloc import trouvé dans app/course.tsx")
    last_import = imports[-1]
    insert_at = last_import.end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

# 2) remplacer le bloc principal d'affichage des chevaux
patterns = [
    r'\{sortedParticipants\.map\(\(([^)]*)\)\s*=>\s*\(([\s\S]*?)\)\)\}',
    r'\{participants\.map\(\(([^)]*)\)\s*=>\s*\(([\s\S]*?)\)\)\}',
]

replaced = False

for pat in patterns:
    m = re.search(pat, s)
    if not m:
        continue

    args = m.group(1).strip()
    src = "sortedParticipants" if "sortedParticipants.map" in m.group(0) else "participants"
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
    raise SystemExit("Bloc participants.map(...) ou sortedParticipants.map(...) introuvable")

p.write_text(s, encoding="utf-8")
print("Phase 3 appliquée : CourseHorseCard branché dans course.tsx")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false

echo
echo "=== REDÉMARRAGE ==="
pkill -f "expo" || true
pkill -f "node.*expo" || true
rm -rf .expo web-build /tmp/metro-* /tmp/expo-* || true
./start.sh
