#!/bin/bash
set -e

echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false

echo
echo "=== FICHIERS COURSE ==="
ls components/course

echo
echo "=== IMPORTS course.tsx ==="
grep -n 'courseScreenHelpers\|courseScreenStyles\|CourseHorseInlineCard' app/course.tsx || true
