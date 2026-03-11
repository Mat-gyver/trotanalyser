#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_loading_fix_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text()

pattern = r"useEffect\(\(\)\s*=>\s*{[\s\S]*?}\s*,\s*\[.*?\]\s*\)"

replacement = '''
useEffect(() => {
  const load = async () => {
    try {
      setLoading(true);

      const res = await fetch(`${API_URL}/api/course/${reunion}/${course}`);
      const json = await res.json();

      setData(json?.data ?? json);

    } catch (e) {
      console.error("Erreur chargement course:", e);
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  load();
}, [reunion, course]);
'''

s2, n = re.subn(pattern, replacement, s)

if n:
    p.write_text(s2)
    print("useEffect corrigé :", n)
else:
    print("useEffect non remplacé (structure différente)")

PY

echo
echo "=== VERIFICATION ==="
grep -n "setLoading" app/course.tsx || true
grep -n "fetch" app/course.tsx || true
