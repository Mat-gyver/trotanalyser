#!/usr/bin/env bash
set -e

echo "🚀 Starting TrotAnalyser"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/trotanalyser-app"
BACKEND_DIR="$APP_DIR/backend"

if [ ! -d "$APP_DIR" ]; then
  echo "❌ Folder not found: $APP_DIR"
  exit 1
fi

if [ ! -f "$APP_DIR/package.json" ]; then
  echo "❌ package.json not found in $APP_DIR"
  exit 1
fi

if [ ! -f "$BACKEND_DIR/api.py" ]; then
  echo "❌ api.py not found in $BACKEND_DIR"
  exit 1
fi

echo "🧹 Closing previous backend and Expo processes..."
pkill -f "uvicorn api:app --host 0.0.0.0 --port 8000" || true
pkill -f "python3 -m uvicorn api:app --host 0.0.0.0 --port 8000" || true
pkill -f "expo start" || true
pkill -f "node .*expo" || true
pkill -f "metro" || true

echo "📦 Installing frontend dependencies if needed..."
cd "$APP_DIR"
npm install

echo "🐍 Installing backend dependencies if needed..."
cd "$BACKEND_DIR"
python3 -m pip install -r requirements.txt

echo "🔌 Starting backend on port 8000..."
python3 -m uvicorn api:app --host 0.0.0.0 --port 8000 > "$ROOT_DIR/backend.log" 2>&1 &

echo "⏳ Waiting 3 seconds for backend startup..."
sleep 3

echo "📱 Starting Expo on fixed port 8081..."
cd "$APP_DIR"
npx expo start --tunnel --port 8081 --clear
