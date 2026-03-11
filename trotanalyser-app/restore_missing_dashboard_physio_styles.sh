#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_restore_missing_styles_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

block = """
  dashboardWrap: {
    flexDirection: "row",
    gap: 12,
    marginTop: 12,
    marginBottom: 12,
  },

  dashboardCard: {
    flex: 1,
    backgroundColor: "#0b2a3c",
    borderRadius: 16,
    padding: 14,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  dashboardTitle: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
    marginBottom: 8,
  },

  dashboardText: {
    color: "#d9eefc",
    fontSize: 13,
    lineHeight: 20,
  },

  physioBox: {
    backgroundColor: "#0b2a3c",
    borderRadius: 16,
    padding: 14,
    marginTop: 12,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  physioTitle: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
    marginBottom: 8,
  },

  physioText: {
    color: "#d9eefc",
    fontSize: 13,
    lineHeight: 20,
  },
"""

needed = [
    "dashboardWrap:",
    "dashboardCard:",
    "dashboardTitle:",
    "dashboardText:",
    "physioBox:",
    "physioTitle:",
    "physioText:",
]

missing = [k for k in needed if k not in s]

if not missing:
    print("Aucun style manquant à restaurer")
else:
    marker = "\n});"
    idx = s.rfind(marker)
    if idx == -1:
        raise SystemExit("Fin de StyleSheet.create introuvable")
    s = s[:idx] + block + s[idx:]
    p.write_text(s, encoding="utf-8")
    print("Styles restaurés :", ", ".join(missing))
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
