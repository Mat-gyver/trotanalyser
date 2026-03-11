#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_fix_backend_import_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("start.sh")
s = p.read_text(encoding="utf-8", errors="ignore")

s2, n = re.subn(
    r'nohup uvicorn main:app --host 0\.0\.0\.0 --port 8000 > "\$ROOT/backend\.log" 2>&1 &',
    'nohup uvicorn backend.main:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &',
    s
)

if n == 0:
    s2, n = re.subn(
        r'uvicorn main:app --host 0\.0\.0\.0 --port 8000',
        'uvicorn backend.main:app --host 0.0.0.0 --port 8000',
        s
    )

if n == 0:
    raise SystemExit("Ligne uvicorn main:app introuvable dans start.sh")

p.write_text(s2, encoding="utf-8")
print("start.sh corrigé : backend.main:app")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'uvicorn .*8000' start.sh || true
