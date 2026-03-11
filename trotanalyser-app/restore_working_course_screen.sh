#!/bin/bash
set -e

SRC="snapshots/course_working_20260311_170423.tsx"
DST="app/course.tsx"
BACKUP="backups/course_before_restore_working_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups

if [ ! -f "$SRC" ]; then
  echo "Snapshot introuvable : $SRC"
  exit 1
fi

cp "$DST" "$BACKUP"
cp "$SRC" "$DST"

echo "Backup créé : $BACKUP"
echo "course.tsx restauré depuis : $SRC"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
