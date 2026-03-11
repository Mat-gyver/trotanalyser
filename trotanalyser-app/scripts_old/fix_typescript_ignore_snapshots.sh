#!/bin/bash
set -e

echo "Sauvegarde tsconfig"
cp tsconfig.json backups/tsconfig_before_ignore_snapshots_$(date +%Y%m%d_%H%M%S).json

python3 <<'PY'
import json

with open("tsconfig.json") as f:
    config = json.load(f)

exclude = config.get("exclude", [])

if "snapshots" not in exclude:
    exclude.append("snapshots")

config["exclude"] = exclude

with open("tsconfig.json","w") as f:
    json.dump(config, f, indent=2)

print("snapshots ajouté dans exclude")
PY

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false
