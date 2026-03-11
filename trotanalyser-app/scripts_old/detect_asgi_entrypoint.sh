#!/bin/bash
set -e

echo "=== PY FILES ==="
find . -type f -name "*.py" | sort

echo
echo "=== CANDIDATS FastAPI ==="
grep -RIn --include="*.py" "FastAPI\|app *= *FastAPI\|APIRouter" . || true

echo
echo "=== CANDIDATS uvicorn ==="
grep -RIn --include="*.py" "uvicorn" . || true

echo
echo "=== CANDIDATS __main__ ==="
grep -RIn --include="*.py" '__name__ *= *= *["'"'"']__main__["'"'"']' . || true
