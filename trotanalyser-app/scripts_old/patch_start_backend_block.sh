#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_patch_backend_block_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("start.sh")
s = p.read_text(encoding="utf-8", errors="ignore")

replacement = '''echo "=== START backend : 8000 ==="

cd "$ROOT/backend"

nohup uvicorn api_before_value_fix:app \\
  --host 0.0.0.0 \\
  --port 8000 \\
  > "$ROOT/backend.log" 2>&1 &

cd "$ROOT"

sleep 3'''

pattern = re.compile(
    r'echo "=== START backend : 8000 ==="[\s\S]*?sleep 3',
    re.MULTILINE
)

new_s, n = pattern.subn(replacement, s, count=1)

if n == 0:
    raise SystemExit("Bloc backend introuvable dans start.sh")

p.write_text(new_s, encoding="utf-8")
print("Bloc backend remplacé correctement")
PY

echo
echo "=== VERIFICATION ==="
sed -n '1,35p' start.sh
