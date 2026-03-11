#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_auto_fix_backend_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

root = Path("/workspaces/trotanalyser/trotanalyser-app")
start = root / "start.sh"

s = start.read_text(encoding="utf-8", errors="ignore")

backend_main = root / "backend" / "main.py"
root_main = root / "main.py"

if backend_main.exists():
    backend_block = '''echo "=== START backend : 8000 ==="
cd "$ROOT/backend"
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &
cd "$ROOT"

sleep 3'''
elif root_main.exists():
    backend_block = '''echo "=== START backend : 8000 ==="
cd "$ROOT"
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &

sleep 3'''
else:
    raise SystemExit("Aucun main.py trouvé ni dans backend/ ni à la racine")

pattern = re.compile(
    r'echo "=== START backend : 8000 ==="[\s\S]*?sleep 3',
    re.MULTILINE
)

new_s, n = pattern.subn(backend_block, s, count=1)
if n == 0:
    raise SystemExit("Bloc backend introuvable dans start.sh")

start.write_text(new_s, encoding="utf-8")
print("start.sh backend corrigé automatiquement")
PY

echo
echo "=== VERIFICATION FICHIERS ==="
find . -maxdepth 2 -name "main.py" | sort

echo
echo "=== VERIFICATION start.sh ==="
grep -n 'START backend\|uvicorn main:app\|cd "\$ROOT/backend"\|cd "\$ROOT"' start.sh || true
