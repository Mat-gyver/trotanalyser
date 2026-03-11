#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_fix_inline_card_prop_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

sed -i 's/c={c}/participant={c}/g' "$FILE"

echo
echo "=== VERIFICATION ==="
grep -n "CourseHorseInlineCard" "$FILE" || true
grep -n "participant={c}" "$FILE" || true
grep -n "c={c}" "$FILE" || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
