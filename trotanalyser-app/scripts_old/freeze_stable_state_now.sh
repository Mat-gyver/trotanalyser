#!/bin/bash
set -e

STAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p backups snapshots

cp app/course.tsx "backups/course_STABLE_${STAMP}.tsx"
cp components/course/CourseHorseInlineCard.tsx "backups/CourseHorseInlineCard_STABLE_${STAMP}.tsx"
cp tsconfig.json "backups/tsconfig_STABLE_${STAMP}.json"

sed -n '531,651p' app/course.tsx > "snapshots/horse_block_STABLE_${STAMP}.tsx"

echo "Etat stable sauvegardé :"
echo " - backups/course_STABLE_${STAMP}.tsx"
echo " - backups/CourseHorseInlineCard_STABLE_${STAMP}.tsx"
echo " - backups/tsconfig_STABLE_${STAMP}.json"
echo " - snapshots/horse_block_STABLE_${STAMP}.tsx"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
