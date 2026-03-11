#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
OUT_FILE="constants/courseDisplay.ts"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups constants
cp "$COURSE_FILE" "backups/course_before_extract_display_constants_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
out_path = Path("constants/courseDisplay.ts")

s = course_path.read_text(encoding="utf-8", errors="ignore")

candidate_names = [
    "TERRAIN_ORDER",
    "SOUPLESSE_LABELS",
    "ALERT_BADGE_ORDER",
    "RANK_STAR_LABELS",
    "VALUE_THRESHOLDS",
]

blocks = []
found_names = []

for name in candidate_names:
    pattern = re.compile(rf'const {name}\s*=\s*[\[\{{][\s\S]*?[\]\}}];', re.MULTILINE)
    m = pattern.search(s)
    if m:
        block = m.group(0)
        blocks.append(block.replace(f"const {name}", f"export const {name}", 1))
        found_names.append(name)
        s = s.replace(block, "", 1)

if not blocks:
    print("Aucune constante d'affichage trouvée, aucune extraction faite.")
    course_path.write_text(s, encoding="utf-8")
    raise SystemExit(0)

content = "\n\n".join(blocks) + "\n"
out_path.write_text(content, encoding="utf-8")

import_line = f'import {{ {", ".join(found_names)} }} from "../constants/courseDisplay";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if imports:
        insert_at = imports[-1].end()
        s = s[:insert_at] + "\n" + import_line + s[insert_at:]

course_path.write_text(s, encoding="utf-8")

print("Constantes extraites vers constants/courseDisplay.ts :", ", ".join(found_names))
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
