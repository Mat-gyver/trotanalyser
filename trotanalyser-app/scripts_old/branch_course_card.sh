#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_card_branch_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

# ajouter import si absent
grep -q CourseHorseCard "$FILE" || sed -i '1i import CourseHorseCard from "../components/course/CourseHorseCard";' "$FILE"

# remplacer la ligne map
sed -i 's/{sortedParticipants.map((c) => (/{sortedParticipants.map((c) => (<CourseHorseCard key={String(c.numero)} horse={c} \/>))/g' "$FILE"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
