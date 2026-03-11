#!/bin/bash
set -e

FILE="components/course/courseScreenHelpers.tsx"

if [ -f "$FILE" ]; then
  rm "$FILE"
  echo "Fichier supprimé : $FILE"
else
  echo "Fichier déjà absent"
fi

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
