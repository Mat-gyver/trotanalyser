#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_hook_connect_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1 ajouter import hook
if "useCourseAnalysis" not in s:
    s = s.replace(
        "import React",
        "import React\nimport { useCourseAnalysis } from '../hooks/useCourseAnalysis'"
    )

# 2 remplacer tri participants
s = re.sub(
    r"const sortedParticipants[\s\S]*?\];",
    "const { sortedParticipants, top3IA, valueBets, topValue } = useCourseAnalysis(data);",
    s
)

p.write_text(s, encoding="utf-8")
print("Hook connecté dans course.tsx")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true

