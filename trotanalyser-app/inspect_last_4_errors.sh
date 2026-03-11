#!/bin/bash
set -e

echo "=== course.tsx lignes 150 à 175 ==="
nl -ba app/course.tsx | sed -n '150,175p'

echo
echo "=== course.tsx lignes 175 à 185 ==="
nl -ba app/course.tsx | sed -n '175,185p'

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
