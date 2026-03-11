#!/bin/bash
set -e

mkdir -p backups snapshots

STAMP=$(date +%Y%m%d_%H%M%S)

cp app/course.tsx "backups/course_WORKING_${STAMP}.tsx"
cp components/course/CourseHeader.tsx "backups/CourseHeader_WORKING_${STAMP}.tsx" 2>/dev/null || true
cp components/course/CourseSummary.tsx "backups/CourseSummary_WORKING_${STAMP}.tsx" 2>/dev/null || true
cp components/course/CoursePhysiology.tsx "backups/CoursePhysiology_WORKING_${STAMP}.tsx" 2>/dev/null || true
cp components/course/CourseHorseInlineCard.tsx "backups/CourseHorseInlineCard_WORKING_${STAMP}.tsx" 2>/dev/null || true

sed -n '531,651p' app/course.tsx > "snapshots/course_horse_block_${STAMP}.tsx"

echo "Sauvegarde OK : backups/course_WORKING_${STAMP}.tsx"
echo "Snapshot bloc chevaux : snapshots/course_horse_block_${STAMP}.tsx"

npx tsc --noEmit --pretty false
