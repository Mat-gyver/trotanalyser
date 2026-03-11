#!/bin/bash
set -e

LATEST=$(ls -t backups/course_before_extract_helpers_*.tsx | head -n 1)

if [ -z "$LATEST" ]; then
  echo "Backup introuvable"
  exit 1
fi

cp "$LATEST" app/course.tsx

echo "course.tsx restauré depuis : $LATEST"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
