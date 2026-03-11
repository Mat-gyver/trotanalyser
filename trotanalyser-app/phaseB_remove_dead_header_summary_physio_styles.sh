#!/bin/bash
set -e

FILE="app/course.tsx"
STAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p backups
cp "$FILE" "backups/course_before_dead_style_cleanup_${STAMP}.tsx"

python - <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

style_names = [
    "headerBox",
    "pronoBox",
    "dashboardWrap",
    "dashboardCard",
    "dashboardTitle",
    "dashboardText",
    "physioBox",
    "physioTitle",
    "physioText",
]

for name in style_names:
    pattern = rf'\n\s*{name}:\s*\{{(?:[^{{}}]|\{{[^{{}}]*\}})*\}},?'
    s = re.sub(pattern, "", s, flags=re.DOTALL)

p.write_text(s, encoding="utf-8")
print("Styles morts header/summary/physio supprimés si présents")
PY

npx tsc --noEmit --pretty false
