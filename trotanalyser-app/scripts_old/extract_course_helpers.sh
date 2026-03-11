#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
HELPERS_FILE="components/course/courseScreenHelpers.tsx"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups components/course
cp "$COURSE_FILE" "backups/course_before_extract_helpers_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
helpers_path = Path("components/course/courseScreenHelpers.tsx")

s = course_path.read_text(encoding="utf-8", errors="ignore")

helper_names = [
    "getMeteoIcon",
    "souplesseIndex",
    "noteColor",
    "shortAnalyse",
    "alertTags",
    "pariStars",
]

blocks = []

for name in helper_names:
    pattern = re.compile(
        rf'(const {name}\s*=\s*\(.*?\)\s*=>\s*\{{.*?\n\}};)',
        re.DOTALL
    )
    m = pattern.search(s)
    if not m:
        raise SystemExit(f"Helper introuvable: {name}")
    blocks.append(m.group(1))

helpers_content = 'import React from "react";\n\n' + "\n\n".join(
    block.replace(f"const {name}", f"export const {name}", 1)
    for block, name in zip(blocks, helper_names)
) + "\n"

helpers_path.write_text(helpers_content, encoding="utf-8")

for block in blocks:
    s = s.replace(block + "\n\n", "", 1)
    s = s.replace(block + "\n", "", 1)
    s = s.replace(block, "", 1)

import_line = (
    'import { getMeteoIcon, souplesseIndex, noteColor, shortAnalyse, '
    'alertTags, pariStars } from "../components/course/courseScreenHelpers";'
)

if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable dans app/course.tsx")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

course_path.write_text(s, encoding="utf-8")

print("Helpers extraits vers components/course/courseScreenHelpers.tsx")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
