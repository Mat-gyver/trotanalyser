#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
STYLES_FILE="components/course/courseScreenStyles.ts"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups components/course
cp "$COURSE_FILE" "backups/course_before_extract_styles_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
styles_path = Path("components/course/courseScreenStyles.ts")

s = course_path.read_text(encoding="utf-8", errors="ignore")

marker = "const styles = StyleSheet.create({"
start = s.find(marker)
if start == -1:
    raise SystemExit("Bloc styles introuvable dans app/course.tsx")

end = s.rfind("});")
if end == -1 or end < start:
    raise SystemExit("Fin du bloc styles introuvable")

styles_block = s[start:end+3]

exported_block = styles_block.replace(
    "const styles = StyleSheet.create({",
    "export const styles = StyleSheet.create({",
    1
)

styles_file_content = '''import { StyleSheet } from "react-native";

''' + exported_block + "\n"

styles_path.write_text(styles_file_content, encoding="utf-8")

# Supprimer le bloc styles du fichier course.tsx
s2 = s[:start].rstrip() + "\n"

# Ajouter l'import si absent
import_line = 'import { styles } from "../components/course/courseScreenStyles";'
if import_line not in s2:
    imports = list(re.finditer(r'^import .+?;$', s2, flags=re.M))
    if not imports:
        raise SystemExit("Bloc imports introuvable dans app/course.tsx")
    insert_at = imports[-1].end()
    s2 = s2[:insert_at] + "\n" + import_line + s2[insert_at:]

course_path.write_text(s2, encoding="utf-8")

print("Bloc styles extrait vers components/course/courseScreenStyles.ts")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
