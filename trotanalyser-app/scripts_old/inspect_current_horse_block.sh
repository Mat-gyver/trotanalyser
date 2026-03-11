#!/bin/bash
set -e

STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups snapshots

cp app/course.tsx "backups/course_before_horse_extract_${STAMP}.tsx"
cp components/course/CourseHorseInlineCard.tsx "backups/CourseHorseInlineCard_before_horse_extract_${STAMP}.tsx"

echo "=== BLOC CARTE ACTUEL DANS course.tsx ==="
nl -ba app/course.tsx | sed -n '531,651p'

echo
echo "=== COMPOSANT CourseHorseInlineCard ACTUEL ==="
nl -ba components/course/CourseHorseInlineCard.tsx | sed -n '1,120p'

echo
echo "=== SNAPSHOT SAUVEGARDÉ ==="
sed -n '531,651p' app/course.tsx > "snapshots/current_horse_block_${STAMP}.tsx"
echo "snapshots/current_horse_block_${STAMP}.tsx"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
