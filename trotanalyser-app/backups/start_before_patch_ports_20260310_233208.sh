#!/bin/bash
set -e

ROOT="/workspaces/trotanalyser/trotanalyser-app"
BACKEND_DIR="$ROOT/backend"

cd "$ROOT"

echo "=== STOP anciens process ==="
pkill -f "uvicorn main:app" || true
pkill -f "expo start" || true
pkill -f "node .*expo" || true

sleep 2

echo "=== START backend : 8000 ==="
cd "$BACKEND_DIR"
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &
cd "$ROOT"

sleep 3

echo "=== START expo web : 8081 ==="
nohup npx expo start --web --port 8081 > "$ROOT/expo.log" 2>&1 &

sleep 10

echo "=== PORTS en public ==="
gh codespace ports visibility 8000:public 8081:public || true

echo
echo "=== STATUS ==="
echo "Backend log : $ROOT/backend.log"
echo "Expo log    : $ROOT/expo.log"
echo
echo "Lance si besoin :"
echo "  tail -n 50 backend.log"
echo "  tail -n 50 expo.log"
echo
echo "=== DONE ==="