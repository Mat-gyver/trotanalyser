#!/bin/bash
set -e

FILE="start.sh"
BACKUP="backups/start_before_patch_ports_$(date +%Y%m%d_%H%M%S).sh"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("start.sh")
s = p.read_text(encoding="utf-8", errors="ignore")

old = r'gh codespace ports visibility 8000:public 8081:public\s*\|\|\s*true'
new = '''gh codespace ports visibility 8000:public -c $CODESPACE_NAME || true
gh codespace ports visibility 8081:public -c $CODESPACE_NAME || true'''

s, n = re.subn(old, new, s)

if n == 0:
    old2 = 'gh codespace ports visibility 8000:public 8081:public'
    if old2 in s:
        s = s.replace(old2, new)
        n = 1

if n == 0:
    raise SystemExit("Ligne gh codespace introuvable dans start.sh")

p.write_text(s, encoding="utf-8")
print("start.sh corrigé")
PY

echo
echo "=== VERIFICATION ==="
grep -n 'gh codespace ports visibility' start.sh || true
