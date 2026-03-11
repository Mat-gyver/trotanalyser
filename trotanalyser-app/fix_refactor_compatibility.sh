#!/bin/bash
set -e

HOOK_FILE="hooks/useCourseAnalysis.ts"
COURSE_FILE="app/course.tsx"
BACKUP_DIR="backups/fix_refactor_compat_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"
cp "$HOOK_FILE" "$BACKUP_DIR/$(basename "$HOOK_FILE")"
cp "$COURSE_FILE" "$BACKUP_DIR/$(basename "$COURSE_FILE")"

echo "Backups créés dans : $BACKUP_DIR"

python3 <<'PY'
from pathlib import Path
import re

hook = Path("hooks/useCourseAnalysis.ts")
course = Path("app/course.tsx")

hs = hook.read_text(encoding="utf-8", errors="ignore")
cs = course.read_text(encoding="utf-8", errors="ignore")

# 1) rendre le hook compatible avec data (objet course) au lieu d'un tableau brut
hs = re.sub(
    r'export function useCourseAnalysis\(\s*participants\s*:\s*any\[\]\s*\)',
    'export function useCourseAnalysis(data: any)',
    hs
)

hs = re.sub(
    r'if\s*\(!participants\)\s*return\s*\[\]',
    'if (!data?.participants) return []',
    hs
)

hs = re.sub(
    r'return\s+\[\.\.\.participants\]\.sort\(',
    'return [...data.participants].sort(',
    hs
)

hs = re.sub(
    r'\},\s*\[participants\]\s*\)',
    '}, [data])',
    hs,
    count=1
)

# 2) garantir topValue dans le return
if 'topValue' not in hs:
    hs = re.sub(
        r'(const\s+top3IA\s*=\s*useMemo\([\s\S]*?\)\s*)',
        r'\1\n\n  const topValue = useMemo(() => {\n    return valueBets[0] || null\n  }, [valueBets])\n',
        hs,
        count=1
    )

hs = re.sub(
    r'return\s*\{\s*([\s\S]*?)\s*paceAnalysis\s*\n\s*\}',
    lambda m: 'return {\n    ' + m.group(1).strip() + '\n    paceAnalysis,\n    topValue\n  }',
    hs,
    count=1
)

# si le return ne contient pas valueBets/topValue proprement, le normaliser
if 'topValue' not in hs.split('return {')[-1]:
    hs = re.sub(
        r'return\s*\{([\s\S]*?)\}',
        lambda m: (
            'return {\n'
            '    sortedParticipants: enrichedSortedParticipants,\n'
            '    top3IA,\n'
            '    valueBets,\n'
            '    paceAnalysis,\n'
            '    topValue\n'
            '  }'
        ),
        hs,
        count=1
    )

hook.write_text(hs, encoding="utf-8")

# 3) remettre la bonne prop pour CourseHorseInlineCard
cs = cs.replace('participant={c}', 'c={c}')

course.write_text(cs, encoding="utf-8")
print("Compatibilité hook/course corrigée")
PY

echo
echo "=== VERIFICATION HOOK ==="
grep -n "export function useCourseAnalysis" "$HOOK_FILE" || true
grep -n "topValue" "$HOOK_FILE" || true
grep -n "return {" "$HOOK_FILE" || true

echo
echo "=== VERIFICATION COURSE ==="
grep -n "CourseHorseInlineCard" "$COURSE_FILE" || true
grep -n "participant={c}" "$COURSE_FILE" || true
grep -n "c={c}" "$COURSE_FILE" || true

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
