#!/bin/bash
set -e

FILE="hooks/useCourseAnalysis.ts"
BACKUP="backups/useCourseAnalysis_before_pace_fix_$(date +%Y%m%d_%H%M%S).ts"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

python3 << 'PY'
from pathlib import Path
import re

p = Path("hooks/useCourseAnalysis.ts")
s = p.read_text()

# ajouter paceAnalysis juste après sortedParticipants

pattern = r'(const sortedParticipants[\s\S]*?\];)'

replacement = r"""\1

  const paceAnalysis = useMemo(() => {
    const leaders = sortedParticipants.filter(p =>
      String(p?.analyseIA || "").toLowerCase().includes("tête")
    )

    const finishers = sortedParticipants.filter(p =>
      String(p?.analyseIA || "").toLowerCase().includes("fin")
    )

    let train = "NORMAL"

    if (leaders.length >= 3):
        train = "RAPIDE"
    elif (leaders.length <= 1):
        train = "LENT"

    return {
      train,
      leaders,
      finishers
    }

  }, [sortedParticipants])
"""

s2 = re.sub(pattern, replacement, s)

p.write_text(s2)

print("paceAnalysis ajouté")
PY

echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true

