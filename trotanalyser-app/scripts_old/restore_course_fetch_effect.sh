#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_restore_fetch_effect_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# Ne rien faire si un fetch de course existe déjà
if "/api/course/${reunion}/${course}" in s or "/api/course/" in s and "setData(" in s:
    print("Un fetch de course semble déjà présent, aucune modification.")
    raise SystemExit(0)

anchor_pattern = re.compile(
    r'(const\s+\[error,\s*setError\]\s*=\s*useState\(false\)\s*)',
    re.MULTILINE
)

effect_block = r'''\1

  useEffect(() => {
    let cancelled = false;

    const loadCourse = async () => {
      try {
        setError(false);

        const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`);
        const json = await res.json();

        if (!cancelled) {
          setData(json?.data ?? json);
        }
      } catch (e) {
        console.error("Erreur chargement course:", e);
        if (!cancelled) {
          setError(true);
        }
      }
    };

    if (reunion && course) {
      loadCourse();
    }

    return () => {
      cancelled = true;
    };
  }, [reunion, course]);
'''

new_s, n = anchor_pattern.subn(effect_block, s, count=1)

if n == 0:
    raise SystemExit("Point d'insertion introuvable après const [error, setError]")

p.write_text(new_s, encoding="utf-8")
print("useEffect de chargement restauré")
PY

echo
echo "=== VERIFICATION ==="
grep -n "useEffect(() =>" app/course.tsx || true
grep -n "fetch(.*api/course" app/course.tsx || true
grep -n "setData(" app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
