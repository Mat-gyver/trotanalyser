#!/bin/bash
set -e

echo "=== STOP PROCESS ==="
pkill -f uvicorn || true
pkill -f expo || true
pkill -f node || true

sleep 2

echo "=== START BACKEND ==="
cd backend
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > ../backend.log 2>&1 &
cd ..

sleep 2

echo "=== START EXPO ==="
nohup npx expo start --tunnel > expo.log 2>&1 &

sleep 3

echo
echo "=== PORTS ==="
npx expo diagnostics >/dev/null 2>&1 || true
lsof -i -P -n | grep LISTEN | grep -E "8000|19000|19001" || true

echo
echo "App relancée"
