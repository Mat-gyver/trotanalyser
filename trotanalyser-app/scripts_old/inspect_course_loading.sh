#!/bin/bash
set -e

FILE="app/course.tsx"

echo "=== fetch / useEffect / setData / loading ==="
grep -nE 'useEffect|fetch\\(|setData\\(|setError\\(|Chargement|loading|if \\(!data\\)|if \\(error\\)' "$FILE" || true

echo
echo "=== lignes 1 à 220 ==="
nl -ba "$FILE" | sed -n '1,220p'

echo
echo "=== lignes 221 à 420 ==="
nl -ba "$FILE" | sed -n '221,420p'

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
