#!/bin/bash
set -e

echo "=== course.tsx autour de topIA ==="
nl -ba app/course.tsx | sed -n '170,190p'

echo
echo "=== course.tsx autour de CourseHorseInlineCard ==="
nl -ba app/course.tsx | sed -n '380,395p'

echo
echo "=== CourseHorseInlineCard.tsx début ==="
nl -ba components/course/CourseHorseInlineCard.tsx | sed -n '1,80p'

echo
echo "=== grep topIA ==="
grep -n '\btopIA\b' app/course.tsx || true

echo
echo "=== grep participants dans Props ==="
grep -n 'participants\s*:' components/course/CourseHorseInlineCard.tsx || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
