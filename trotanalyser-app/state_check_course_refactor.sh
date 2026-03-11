#!/bin/bash
set -e

echo "=== 1) IMPORT INLINE CARD DANS course.tsx ==="
grep -n 'CourseHorseInlineCard' app/course.tsx || true
echo

echo "=== 2) BLOC MAP ACTUEL ==="
nl -ba app/course.tsx | sed -n '528,660p'
echo

echo "=== 3) FICHIER CourseHorseInlineCard.tsx ==="
nl -ba components/course/CourseHorseInlineCard.tsx | sed -n '1,220p'
echo

echo "=== 4) TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
