#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_wire_insights_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python3 <<'PY'
from pathlib import Path
import re

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

import_line = 'import CourseInsights from "../components/course/CourseInsights";'
if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable")
    insert_at = imports[-1].end()
    s = s[:insert_at] + "\n" + import_line + s[insert_at:]

start_marker = '<View style={styles.dashboardWrap}>'
start = s.find(start_marker)
if start == -1:
    raise SystemExit("Début dashboard introuvable")

physio_marker = '<View style={styles.physioBox}>'
physio_start = s.find(physio_marker, start)
if physio_start == -1:
    raise SystemExit("Bloc physio introuvable")

# trouve la fin du bloc physio en comptant les View imbriqués
i = physio_start
depth = 0
end = -1
while i < len(s):
    next_open = s.find('<View', i)
    next_close = s.find('</View>', i)

    if next_close == -1:
        break

    if next_open != -1 and next_open < next_close:
        depth += 1
        i = next_open + 5
    else:
        depth -= 1
        i = next_close + 7
        if depth == 0:
            end = i
            break

if end == -1:
    raise SystemExit("Fin du bloc physio introuvable")

replacement = '''<CourseInsights
        summary={[
          `🎯 Cheval à battre : ${top3IA[0]?.numero || "-"} ${top3IA[0]?.nom || ""}`.trim(),
          `💰 Value principale : ${topValue ? `${topValue.numero} ${topValue.nom}` : "-"}`,
          `⚠️ Tocard dangereux : ${topTocard ? `${topTocard.numero} ${topTocard.nom}` : "-"}`,
          `🔥 Driver chaud : ${topDriver ? `${topDriver.driver || "-"}` : "-"}`
        ]}
        lecture={[
          `⚠️ Favori discutable : ${top3IA[0]?.numero || "-"}`,
          `🎯 Course assez lisible`,
          `🪨 Outsiders dangereux : ${sortedParticipants.slice(3, 6).map((c) => c.numero).join(" ") || "-"}`
        ]}
        strategy={[
          `Base : ${top3IA[0]?.numero || "-"}`,
          `Chances : ${top3IA.slice(1, 4).map((c) => c.numero).join(" ") || "-"}`,
          `Outsiders : ${sortedParticipants.slice(3, 6).map((c) => c.numero).join(" ") || "-"}`,
          `Jeu conseillé : Quinté champ réduit`
        ]}
        scanTop3={top3IA.map((c, i) => `#${i + 1} ${c.numero} ${c.nom}`)}
        scanValueBets={valueBets.map((c) => `${c.numero} ${c.nom} · ${c.value ?? "-"}`)}
        physio={{
          trainProbable: physionomieCourse.trainProbable,
          trainTactique: physionomieCourse.trainTactique,
          tete: physionomieCourse.tete,
          attentistes: physionomieCourse.attentistes,
          finisseurs: physionomieCourse.finisseurs,
        }}
        styles={styles}
      />'''

s = s[:start] + replacement + s[end:]

p.write_text(s, encoding="utf-8")
print("Dashboard + physio remplacés par CourseInsights")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
