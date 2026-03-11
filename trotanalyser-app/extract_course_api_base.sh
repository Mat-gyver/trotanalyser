#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
API_FILE="constants/courseApiBase.ts"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups constants
cp "$COURSE_FILE" "backups/course_before_extract_api_base_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
api_path = Path("constants/courseApiBase.ts")

s = course_path.read_text(encoding="utf-8", errors="ignore")

pattern = re.compile(
    r'const API_BASE =\s*(?:\n|\r\n?)[\s\S]*?\);\n',
    re.MULTILINE
)

m = pattern.search(s)
if not m:
    raise SystemExit("Bloc API_BASE introuvable")

block = m.group(0)
api_block = block.replace("const API_BASE =", "export const API_BASE =", 1)

api_file_content = api_block
api_path.write_text(api_file_content, encoding="utf-8")

s = s.replace(block, "", 1)

import_line = 'import { API_BASE } from "../constants/courseApiBase";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable dans app/course.tsx")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

course_path.write_text(s, encoding="utf-8")

print("API_BASE extrait vers constants/courseApiBase.ts")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
