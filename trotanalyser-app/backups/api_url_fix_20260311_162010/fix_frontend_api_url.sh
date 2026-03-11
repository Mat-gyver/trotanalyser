#!/bin/bash
set -e

API_URL="https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev"

echo "=== Recherche des appels API ==="

grep -R "localhost:8000" -n app || true
grep -R "127.0.0.1:8000" -n app || true

echo
echo "=== Remplacement par URL Codespace ==="

find app -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" \) \
-exec sed -i "s|http://localhost:8000|$API_URL|g" {} +

find app -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" \) \
-exec sed -i "s|http://127.0.0.1:8000|$API_URL|g" {} +

echo
echo "=== Vérification ==="

grep -R "$API_URL" -n app || true

echo
echo "Frontend connecté à l'API."
