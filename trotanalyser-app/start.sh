#!/bin/bash
gh codespace ports visibility 8000:public -c ideal-sniffle-5gwgq4vq6x5gc4556

echo "🚀 Lancement TrotAnalyser"

echo "▶️ API Python..."
uvicorn backend.api:app --host 0.0.0.0 --port 8000 --reload &

sleep 3

echo "▶️ App Expo..."
npx expo start --web
