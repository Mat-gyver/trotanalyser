#!/bin/bash
set -e

echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false

echo
echo "=== BLOC CHEVAUX RESTAURÉ ==="
nl -ba app/course.tsx | sed -n '531,651p'

echo
echo "=== COMPOSANTS COURSE ==="
ls components/course
