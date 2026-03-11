#!/bin/bash
set -e

LATEST=$(ls -t snapshots/CourseHorseInlineCard_draft_*.tsx 2>/dev/null | head -n 1)

if [ -z "$LATEST" ]; then
  echo "Aucun brouillon trouvé."
  exit 1
fi

STAMP=$(date +%Y%m%d_%H%M%S)
OUT="snapshots/CourseHorseInlineCard_clean_${STAMP}.tsx"

python3 <<PY
from pathlib import Path
src = Path("$LATEST")
dst = Path("$OUT")
s = src.read_text(encoding="utf-8", errors="ignore")

# Nettoyage des lignes d'enveloppe du map
patterns_to_drop = [
    "{sortedParticipants.map((c) => (",
    "<CourseHorseInlineCard key={String(c.numero)}>",
    "</CourseHorseInlineCard>",
    "))}",
]

lines = s.splitlines()
cleaned = []
for line in lines:
    if any(p in line for p in patterns_to_drop):
        continue
    cleaned.append(line)

dst.write_text("\n".join(cleaned), encoding="utf-8")
print(f"Fichier nettoyé créé : {dst}")
PY

echo
echo "=== APERÇU ==="
nl -ba "$OUT" | sed -n '1,220p'
