#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_wire_summary_physiology_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

summary_import = 'import CourseSummary from "../components/course/CourseSummary";'
physio_import = 'import CoursePhysiology from "../components/course/CoursePhysiology";'

# 1) Ajouter les imports si absents
imports = []
if summary_import not in s:
    imports.append(summary_import)
if physio_import not in s:
    imports.append(physio_import)

if imports:
    matches = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not matches:
        raise SystemExit("Bloc imports introuvable dans app/course.tsx")
    insert_at = matches[-1].end()
    s = s[:insert_at] + "\n" + "\n".join(imports) + s[insert_at:]

# 2) Insérer les composants juste avant la liste des chevaux
marker = "{sortedParticipants.map((c) => ("
if marker not in s:
    raise SystemExit("Marqueur sortedParticipants.map introuvable dans app/course.tsx")

insertion = """      <CourseSummary data={data} />
      <CoursePhysiology data={data} />

"""

s = s.replace(marker, insertion + marker, 1)

p.write_text(s, encoding="utf-8")
print("CourseSummary et CoursePhysiology branchés dans course.tsx")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
