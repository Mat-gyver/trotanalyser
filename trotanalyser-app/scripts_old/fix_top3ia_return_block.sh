#!/bin/bash
set -e

FILE="hooks/useCourseAnalysis.ts"
BACKUP="backups/useCourseAnalysis_before_fix_top3ia_return_$(date +%Y%m%d_%H%M%S).ts"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("hooks/useCourseAnalysis.ts")
s = p.read_text(encoding="utf-8", errors="ignore")

replacement = '''  const top3IA = useMemo(() => {
    return enrichedSortedParticipants.slice(0, 3)
  }, [enrichedSortedParticipants])

  const topValue = useMemo(() => {
    return valueBets[0] || null
  }, [valueBets])

  return {
    sortedParticipants: enrichedSortedParticipants,
    top3IA,
    valueBets,
    paceAnalysis,
    topValue
  }
}'''

pattern = re.compile(
    r'const\s+top3IA\s*=\s*useMemo\(\([\s\S]*?return\s*\{[\s\S]*?\n\s*\}\s*\}?\s*$',
    re.MULTILINE
)

s2, n = pattern.subn(replacement, s, count=1)

if n == 0:
    raise SystemExit("Bloc top3IA/return introuvable. Rien n'a été modifié.")

p.write_text(s2, encoding="utf-8")
print("Bloc top3IA/topValue/return corrigé")
PY

echo
echo "=== VERIFICATION ==="
tail -n 30 "$FILE"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
