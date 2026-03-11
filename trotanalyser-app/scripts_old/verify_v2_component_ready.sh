#!/bin/bash
set -e

echo "=== FICHIER V2 ==="
nl -ba components/course/CourseHorseInlineCard_v2.tsx | sed -n '1,220p'

echo
echo "=== TYPESCRIPT GLOBAL ==="
npx tsc --noEmit --pretty false

echo
echo "=== IMPORTS course.tsx ==="
grep -n 'CourseHorseInlineCard' app/course.tsx || true
