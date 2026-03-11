#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_participant_type_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# typer sortedParticipants.map
s, n = re.subn(
    r'sortedParticipants\.map\(\(c:\s*any\)',
    'sortedParticipants.map((c: any)',
    s
)

# sécuriser accès aux propriétés
s = re.sub(r'c\.numero', '(c as any).numero', s)
s = re.sub(r'c\.probabiliteIA', '(c as any).probabiliteIA', s)

p.write_text(s)

print("map corrigés:", n)
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
