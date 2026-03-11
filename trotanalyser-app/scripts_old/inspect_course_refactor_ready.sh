#!/bin/bash
set -e

echo "=== imports course.tsx ==="
sed -n '1,40p' app/course.tsx

echo
echo "=== composants course disponibles ==="
find components/course -maxdepth 1 -type f | sort

echo
echo "=== usages actuels dans course.tsx ==="
grep -nE 'CourseHeader|CourseSummary|CoursePhysiology|CourseInsights|CourseHorseInlineCard' app/course.tsx || true

echo
echo "=== taille course.tsx ==="
wc -l app/course.tsx
