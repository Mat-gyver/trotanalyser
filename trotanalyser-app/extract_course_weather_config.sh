#!/bin/bash
set -e

COURSE_FILE="app/course.tsx"
WEATHER_FILE="constants/courseWeather.ts"
STAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p backups constants
cp "$COURSE_FILE" "backups/course_before_extract_weather_${STAMP}.tsx"

python3 <<'PY'
from pathlib import Path
import re

course_path = Path("app/course.tsx")
weather_path = Path("constants/courseWeather.ts")

s = course_path.read_text(encoding="utf-8", errors="ignore")

pattern = re.compile(
    r'const METEO_ICONS\s*=\s*\{[\s\S]*?\};',
    re.MULTILINE
)

m = pattern.search(s)

if not m:
    print("Bloc METEO_ICONS introuvable, aucune extraction faite.")
    exit()

block = m.group(0)

export_block = block.replace(
    "const METEO_ICONS",
    "export const METEO_ICONS",
    1
)

weather_file = export_block + "\n"
weather_path.write_text(weather_file, encoding="utf-8")

s = s.replace(block, "", 1)

import_line = 'import { METEO_ICONS } from "../constants/courseWeather";'

if import_line not in s:
    imports = list(re.finditer(r'^import .+?;$', s, flags=re.M))
    if imports:
        insert_at = imports[-1].end()
        s = s[:insert_at] + "\n" + import_line + s[insert_at:]

course_path.write_text(s, encoding="utf-8")

print("Configuration météo extraite vers constants/courseWeather.ts")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
