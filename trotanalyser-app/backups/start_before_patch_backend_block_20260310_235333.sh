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
nohup cd "$ROOT/backend"
nohup uvicorn api_before_value_fix:app --host 0.0.0.0 --port 8000 > "$ROOT/backend.log" 2>&1 &
cd "$ROOT"
cd "$ROOT"

sleep 3

echo "=== START expo web : 8081 ==="
nohup npx expo start --web --port 8081 > "$ROOT/expo.log" 2>&1 &

echo "=== ATTENTE DES PORTS CODESPACES ==="
for i in $(seq 1 20); do
  PORTS_JSON="$(gh codespace ports --json sourcePort,visibility -c "$CODESPACE_NAME" 2>/dev/null || true)"

    echo "$PORTS_JSON" | grep '"sourcePort":8000' >/dev/null && BACKEND_READY=1 || BACKEND_READY=0
      echo "$PORTS_JSON" | grep '"sourcePort":8081' >/dev/null && EXPO_READY=1 || EXPO_READY=0

        echo "Tentative $i -> 8000:$BACKEND_READY 8081:$EXPO_READY"

          if [ "$BACKEND_READY" = "1" ] && [ "$EXPO_READY" = "1" ]; then
              break
                fi

                  sleep 2
                  done

                  echo "=== PORTS en public ==="
                  gh codespace ports visibility 8000:public -c "$CODESPACE_NAME" || true
                  gh codespace ports visibility 8081:public -c "$CODESPACE_NAME" || true

                  echo
                  echo "=== STATUS ==="
                  echo "Backend log : $ROOT/backend.log"
                  echo "Expo log    : $ROOT/expo.log"
                  echo
                  echo "Pour vérifier :"
                  echo "  gh codespace ports --json sourcePort,visibility -c \"$CODESPACE_NAME\""
                  echo
                  echo "=== DONE ==="