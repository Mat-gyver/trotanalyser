#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_precise_fix_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) API_BASE sécurisé
old_api = '''const API_BASE =
process.env.EXPO_PUBLIC_API_BASE ||
window.location.origin.replace(/-\\d+\\.app\\.github\\.dev$/, "-8000.app.github.dev");'''
new_api = '''const API_BASE =
  (process.env.EXPO_PUBLIC_API_BASE || "") ||
  (typeof window !== "undefined"
    ? window.location.origin.replace(/-\\d+\\.app\\.github\\.dev$/, "-8000.app.github.dev")
    : "");'''
if old_api in s:
    s = s.replace(old_api, new_api, 1)

# 2) fonction introuvable
s = s.replace("impliedProbFromCote(cotePMU)", "impliedProbPmu(cotePMU)")

# 3) ajouter topFill si absent
if "topFill:" not in s:
    anchor = '''  topBar: {
    flexDirection: "row",
    alignItems: "center",
    paddingTop: 16,
    paddingHorizontal: 16,
    paddingBottom: 12,
    backgroundColor: "#051726",
  },'''
    insert = '''  topBar: {
    flexDirection: "row",
    alignItems: "center",
    paddingTop: 16,
    paddingHorizontal: 16,
    paddingBottom: 12,
    backgroundColor: "#051726",
  },

  topFill: {
    height: "100%",
    borderRadius: 99,
  },'''
    if anchor in s:
        s = s.replace(anchor, insert, 1)

# 4) ajouter scoreMeta si absent
if "scoreMeta:" not in s:
    anchor = '''  microStats: {
    color: "#9fc4da",
    fontSize: 10,
    marginBottom: 3,
    fontWeight: "700",
    textAlign: "right",
  },'''
    insert = '''  scoreMeta: {
    color: "#d9efff",
    fontSize: 11,
    fontWeight: "700",
    textAlign: "right",
    marginBottom: 2,
  },

  microStats: {
    color: "#9fc4da",
    fontSize: 10,
    marginBottom: 3,
    fontWeight: "700",
    textAlign: "right",
  },'''
    if anchor in s:
        s = s.replace(anchor, insert, 1)

# 5) supprimer le 2e doublon badgeValue
dup = '''  badgeValue: {
    backgroundColor: "#7c5a10",
  },
'''
if dup in s:
    s = s.replace(dup, "", 1)

p.write_text(s, encoding="utf-8")
print("course.tsx corrigé sur les 5 points exacts")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
