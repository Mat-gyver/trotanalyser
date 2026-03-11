#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
TYPES_FILE="types/courseScreen.ts"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups types
cp "$COURSE_FILE" "backups/course_before_extract_types_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
types_path = Path("types/courseScreen.ts")

s = course_path.read_text(encoding="utf-8", errors="ignore")

patterns = {
    "Participant": re.compile(r'type Participant\s*=\s*\{.*?\n\};', re.DOTALL),
    "CourseData": re.compile(r'type CourseData\s*=\s*\{.*?\n\};', re.DOTALL),
}

blocks = {}
for name, pattern in patterns.items():
    m = pattern.search(s)
    if not m:
        raise SystemExit(f"Type introuvable: {name}")
    blocks[name] = m.group(0)

types_content = (
    blocks["Participant"].replace("type Participant", "export type Participant")
    + "\n\n"
    + blocks["CourseData"].replace("type CourseData", "export type CourseData")
    + "\n"
)

types_path.write_text(types_content, encoding="utf-8")

for block in blocks.values():
    s = s.replace(block + "\n\n", "", 1)
    s = s.replace(block + "\n", "", 1)
    s = s.replace(block, "", 1)

import_line = 'import type { Participant, CourseData } from "../types/courseScreen";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable dans app/course.tsx")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

course_path.write_text(s, encoding="utf-8")

print("Types extraits vers types/courseScreen.ts")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
