#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_patch_useeffect_guard_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

effect_block = '''
  useEffect(() => {
    if (!reunion || !course) return;

    const loadCourse = async () => {
      try {
        setError(false);

        const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`);
        const json = await res.json();

        setData(json?.data ?? json);
      } catch (e) {
        console.error("Erreur chargement course:", e);
        setError(true);
      }
    };

    loadCourse();
  }, [reunion, course]);

'''

# 1) s'il y a déjà un useEffect qui fetch la course, on le remplace
pattern_existing = re.compile(
    r'\n\s*useEffect\(\(\)\s*=>\s*{[\s\S]*?fetch\(`\$\{API_BASE\}/api/course/\$\{reunion\}/\$\{course\}`\)[\s\S]*?}\s*,\s*\[reunion,\s*course\]\s*\);\s*',
    re.MULTILINE
)

new_s, n = pattern_existing.subn('\n' + effect_block, s, count=1)

if n == 0:
    # 2) sinon on l'insère juste après les useState data/error
    anchor = re.compile(
        r'(\s*const\s+\[error,\s*setError\]\s*=\s*useState\(false\)\s*;?\s*)',
        re.MULTILINE
    )
    new_s, n2 = anchor.subn(r'\1\n' + effect_block, s, count=1)
    if n2 == 0:
        raise SystemExit("Impossible de trouver le point d'insertion après const [error, setError]")
    new_s = new_s
    n = n2

# 3) corriger au cas où une ancienne ligne setData(json.data) traîne encore
new_s = re.sub(r'setData\(\s*json\.data\s*\)', 'setData(json?.data ?? json)', new_s)

p.write_text(new_s, encoding="utf-8")
print("useEffect course corrigé")
PY

echo
echo "=== VERIFICATION ==="
grep -n "useEffect(() =>" app/course.tsx || true
grep -n "if (!reunion || !course) return;" app/course.tsx || true
grep -n 'fetch(`${API_BASE}/api/course/${reunion}/${course}`)' app/course.tsx || true
grep -n 'setData(json?.data ?? json)' app/course.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
