#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_fix_api_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("start.sh")
s = p.read_text()

pattern = re.compile(r'uvicorn .*--port 8000.*')

replacement = 'cd "$ROOT/backend"\nnohup uvicorn api_before_value_fix:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &\ncd "$ROOT"'

s2, n = pattern.subn(replacement, s)

if n == 0:
    raise SystemExit("Commande uvicorn introuvable")

p.write_text(s2)
print("start.sh corrigé avec api_before_value_fix:app")
PY

grep -n "uvicorn" start.sh
