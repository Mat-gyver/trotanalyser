#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_fix_styles_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python - <<'PY'
import re
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# trouver le bloc StyleSheet
m = re.search(r"StyleSheet\.create\(\{([\s\S]*)\}\);", s)
if not m:
    raise SystemExit("Bloc StyleSheet introuvable")

styles = m.group(1)

seen = set()
result = []

for block in re.split(r"\n\s*(\w+):", styles):
    if not block.strip():
        continue
    name = block.split("{")[0].strip()
    if name in seen:
        continue
    seen.add(name)
    result.append(block)

clean = "\n".join(result)

s = s[:m.start(1)] + clean + s[m.end(1):]

p.write_text(s, encoding="utf-8")
print("Doublons de styles supprimés")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
