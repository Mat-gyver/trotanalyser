#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_wire_card_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
s = p.read_text(encoding="utf-8", errors="ignore")

# 1) Ajouter l'import si absent
import_line = 'import CourseHorseCard from "../components/CourseHorseCard";'
if import_line not in s:
    marker = 'import { useLocalSearchParams, router } from "expo-router";'
    if marker in s:
        s = s.replace(marker, marker + "\n" + import_line)
    else:
        raise SystemExit("Import expo-router introuvable dans app/course.tsx")

# 2) Remplacer le rendu simple des participants par le composant
old_block = """      {participants.map((p, index) => (
        <View key={`${p.numero}-${p.nom}-${index}`} style={styles.horseCard}>
          <View style={styles.rowBetween}>
            <Text style={styles.horseTitle}>
              #{p.numero} {p.nom}
            </Text>
            <Text style={styles.pmuText}>
              {p.cotePMU ? `PMU ${p.cotePMU}` : ""}
            </Text>
          </View>

          <Text style={styles.line2}>
            {p.driver || "-"} / {p.entraineur || "-"} • {p.ferrure || "-"} • {p.musique || "-"}
          </Text>

          <Text style={styles.line3}>
            IA {p.probabiliteIA ?? 0}% • Score {p.scoreIA ?? 0} • Value {p.value ?? 0}
          </Text>

          <Text style={styles.line4}>
            {p.analyseIA || "Analyse IA indisponible"}
          </Text>
        </View>
      ))}"""

new_block = """      {participants.map((horse: any, index) => (
        <CourseHorseCard
          key={`${horse.numero}-${horse.nom}-${index}`}
          horse={horse}
        />
      ))}"""

if old_block in s:
    s = s.replace(old_block, new_block)
else:
    raise SystemExit("Bloc participants attendu introuvable dans app/course.tsx")

p.write_text(s, encoding="utf-8")
print("course.tsx branché sur CourseHorseCard")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false

echo
echo "=== REDÉMARRAGE ==="
pkill -f "expo" || true
pkill -f "node.*expo" || true
rm -rf .expo web-build /tmp/metro-* /tmp/expo-* || true
./start.sh
