#!/bin/bash
set -e

mkdir -p snapshots

STAMP=$(date +%Y%m%d_%H%M%S)

cp app/course.tsx "snapshots/course_before_refactor_${STAMP}.tsx"
cp start.sh "snapshots/start_before_refactor_${STAMP}.sh"

echo "Snapshots créés :"
ls -lt snapshots | head
