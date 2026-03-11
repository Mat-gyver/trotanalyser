#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_fix_last3_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) impliedProbFromCote -> impliedProbPmu
s = s.replace("impliedProbFromCote(cotePMU)", "impliedProbPmu(cotePMU)")
s = s.replace("impliedProbFromCote(", "impliedProbPmu(")

# 2) ajouter topFill si absent
if "topFill:" not in s and "topBar:" in s:
    s = s.replace(
        "topBar: {",
        '''topBar: {''',
        1
    )
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

# 3) ajouter scoreMeta si absent
if "scoreMeta:" not in s:
    anchor = '''  badgeText: {
    color: "#ffffff",
    fontSize: 9,
    fontWeight: "800",
  },'''
    insert = '''  badgeText: {
    color: "#ffffff",
    fontSize: 9,
    fontWeight: "800",
  },

  scoreMeta: {
    color: "#d9efff",
    fontSize: 11,
    fontWeight: "700",
    textAlign: "right",
    marginBottom: 2,
  },'''
    if anchor in s:
        s = s.replace(anchor, insert, 1)

p.write_text(s, encoding="utf-8")
print("3 corrections appliquées")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
