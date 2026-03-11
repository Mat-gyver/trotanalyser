#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_fix_backend_cwd_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("start.sh")
s = p.read_text(encoding="utf-8", errors="ignore")

pattern = re.compile(
    r'echo "=== START backend : 8000 ==="[\s\S]*?sleep 3',
    re.MULTILINE
)

replacement = '''echo "=== START backend : 8000 ==="
cd "$BACKEND_DIR"
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &
cd "$ROOT"

sleep 3'''

new_s, n = pattern.subn(replacement, s, count=1)

if n == 0:
    raise SystemExit("Bloc backend introuvable dans start.sh")

p.write_text(new_s, encoding="utf-8")
print("Bloc backend corrigé")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'START backend\|uvicorn main:app\|uvicorn backend.main:app\|cd "\$BACKEND_DIR"' start.sh || true
