#!/bin/bash
set -e

FILE="components/course/CourseHeader.tsx"

python3 <<'PY'
from pathlib import Path

p = Path("components/course/CourseHeader.tsx")
s = p.read_text()

s = s.replace(
"styles: any;",
"styles?: any;"
)

p.write_text(s)
print("styles rendu optionnel")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true

