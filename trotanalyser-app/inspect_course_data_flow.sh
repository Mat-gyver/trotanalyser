#!/bin/bash
set -e

FILE="app/course.tsx"

echo "=== setData / useState / fetch / json ==="
grep -nE 'useState|setData\(|fetch\(|await res\.json|await .*json|if \(!data|if \(!data\.|Chargement' "$FILE" || true

echo
echo "=== lignes 1 à 140 ==="
nl -ba "$FILE" | sed -n '1,140p'

echo
echo "=== lignes 330 à 370 ==="
nl -ba "$FILE" | sed -n '330,370p'
