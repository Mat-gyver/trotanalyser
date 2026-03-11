#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_step2_import_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

IMPORT='import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";'

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")
imp = 'import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";'

if imp in s:
    print("Import déjà présent")
else:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + imp + s[insert_at:]
    p.write_text(s, encoding="utf-8")
    print("Import ajouté")
PY

npx tsc --noEmit --pretty false
