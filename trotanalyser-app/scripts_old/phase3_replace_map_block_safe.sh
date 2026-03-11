#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_phase3_mapreplace_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

python - <<'PY'
from pathlib import Path

p = Path("app/course.tsx")
lines = p.read_text(encoding="utf-8", errors="ignore").splitlines()

import_line = 'import CourseHorseCard from "../components/course/CourseHorseCard";'

# 1) Ajouter l'import si absent
if import_line not in "\n".join(lines):
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.startswith("import "):
            last_import_idx = i
    if last_import_idx == -1:
        raise SystemExit("Aucune ligne import trouvée dans app/course.tsx")
    lines.insert(last_import_idx + 1, import_line)

# 2) Trouver le début exact du bloc map
start_idx = -1
for i, line in enumerate(lines):
    if "{sortedParticipants.map((c) => (" in line:
        start_idx = i
        break

if start_idx == -1:
    raise SystemExit("Début du bloc map introuvable : {sortedParticipants.map((c) => (")

# 3) Trouver la fin du bloc : première ligne égale à '))}' (en ignorant les espaces)
end_idx = -1
for j in range(start_idx + 1, len(lines)):
    if lines[j].strip() == "))}":
        end_idx = j
        break

if end_idx == -1:
    raise SystemExit("Fin du bloc map introuvable : ligne '))}' non trouvée")

# 4) Remplacer tout le bloc par CourseHorseCard
indent = lines[start_idx][:len(lines[start_idx]) - len(lines[start_idx].lstrip())]

new_block = [
    f"{indent}{{sortedParticipants.map((c) => (",
    f"{indent}  <CourseHorseCard key={{String(c.numero)}} horse={{c}} />",
    f"{indent}))}}",
]

new_lines = lines[:start_idx] + new_block + lines[end_idx + 1:]

p.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
print(f"Bloc map remplacé entre lignes {start_idx+1} et {end_idx+1}")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
