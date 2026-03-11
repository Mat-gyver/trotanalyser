#!/bin/bash
set -e

API_URL="https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups/api_url_fix_$STAMP

echo "=== RECHERCHE AVANT ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=backups \
  -E 'localhost:8000|127\.0\.0\.1:8000' app hooks services constants . || true

echo
echo "=== BACKUP DES FICHIERS CONCERNÉS ==="
FILES=$(grep -RIl --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=backups \
  -E 'localhost:8000|127\.0\.0\.1:8000' app hooks services constants . || true)

if [ -z "$FILES" ]; then
  echo "Aucune occurrence trouvée."
  exit 0
fi

for f in $FILES; do
  mkdir -p "backups/api_url_fix_$STAMP/$(dirname "$f")"
  cp "$f" "backups/api_url_fix_$STAMP/$f"
done

echo
echo "=== REMPLACEMENT ==="
for f in $FILES; do
  sed -i "s|https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev|$API_URL|g" "$f"
  sed -i "s|https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev|$API_URL|g" "$f"
  sed -i "s|https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev|$API_URL|g" "$f"
  sed -i "s|https://ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev|$API_URL|g" "$f"
done

echo
echo "=== VERIFICATION APRES ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=backups \
  -E 'localhost:8000|127\.0\.0\.1:8000' app hooks services constants . || true

echo
echo "=== NOUVELLE URL ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=backups \
  'ideal-sniffle-5gwgq4vq6x5gc4556-8000.app.github.dev' app hooks services constants . || true

echo
echo "Correction terminée."
