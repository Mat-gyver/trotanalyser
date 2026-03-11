#!/bin/bash
set -e

FILE="hooks/useCourseAnalysis.ts"
mkdir -p hooks

cat > "$FILE" <<'EOT'
import { useMemo } from "react";

type Participant = any;
type CourseData = any;

export function useCourseAnalysis(data: CourseData | null) {
  const sortedParticipants = useMemo(() => {
    return [...(data?.participants || [])].sort(
      (a: Participant, b: Participant) =>
        Number(b.value || -999) - Number(a.value || -999) ||
        Number(b.scoreIA || 0) - Number(a.scoreIA || 0)
    );
  }, [data]);

  const top3IA = useMemo(() => sortedParticipants.slice(0, 3), [sortedParticipants]);

  const valueBets = useMemo(() => {
    return [...sortedParticipants]
      .filter((c: Participant) => Number(c.value || 0) > 0)
      .sort((a: Participant, b: Participant) => Number(b.value || 0) - Number(a.value || 0))
      .slice(0, 3);
  }, [sortedParticipants]);

  const topValue = valueBets[0] || null;

  return {
    sortedParticipants,
    top3IA,
    valueBets,
    topValue,
  };
}
EOT

echo "Hook créé : $FILE"
echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
