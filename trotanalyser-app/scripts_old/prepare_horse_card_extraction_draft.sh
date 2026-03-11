#!/bin/bash
set -e

LATEST=$(ls -t snapshots/horse_block_STABLE_*.tsx 2>/dev/null | head -n 1)

if [ -z "$LATEST" ]; then
  echo "Aucun snapshot stable trouvé."
  exit 1
fi

STAMP=$(date +%Y%m%d_%H%M%S)
OUT="snapshots/CourseHorseInlineCard_draft_${STAMP}.tsx"

cat > "$OUT" <<EOF2
import React from "react";
import { View, Text } from "react-native";

type Props = {
  c: any;
  renderCasaque: (c: any) => React.ReactNode;
  scoreBar: (v?: number) => React.ReactNode;
  iaProbBar: (a?: number, b?: number) => React.ReactNode;
  noteColor: (n?: number) => string;
  shortAnalyse: (s?: string) => string;
  alertTags: (c: any) => string[];
  pariStars: (c: any) => React.ReactNode;
  styles: any;
};

export default function CourseHorseInlineCardDraft({
  c,
  renderCasaque,
  scoreBar,
  iaProbBar,
  noteColor,
  shortAnalyse,
  alertTags,
  pariStars,
  styles,
}: Props) {
  return (
    <>
/*
Bloc source actuel extrait depuis :
$LATEST
*/
EOF2

cat "$LATEST" >> "$OUT"

cat >> "$OUT" <<'EOF2'
    </>
  );
}
EOF2

echo "Brouillon créé : $OUT"
echo
echo "=== APERÇU ==="
nl -ba "$OUT" | sed -n '1,220p'
