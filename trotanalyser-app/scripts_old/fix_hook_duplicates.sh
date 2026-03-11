#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_hook_duplicates_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) ajouter l'import du hook si absent
import_line = 'import { useCourseAnalysis } from "../hooks/useCourseAnalysis";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

# 2) supprimer les anciennes déclarations locales valueBets / topValue
patterns = [
    r'\n\s*const valueBets\s*=\s*useMemo\([\s\S]*?\n\s*\},\s*\[[^\]]*\]\s*\);?',
    r'\n\s*const valueBets\s*=\s*\[[\s\S]*?\n\s*\);?',
    r'\n\s*const topValue\s*=\s*[^\n;]+;?',
]

total_removed = 0
for pattern in patterns:
    s, n = re.subn(pattern, '', s, flags=re.M)
    total_removed += n

# 3) nettoyer lignes vides excessives
s = re.sub(r'\n{3,}', '\n\n', s)

p.write_text(s, encoding="utf-8")
print(f"Anciennes déclarations supprimées: {total_removed}")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'useCourseAnalysis' app/course.tsx || true
grep -n 'const valueBets' app/course.tsx || true
grep -n 'const topValue' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
