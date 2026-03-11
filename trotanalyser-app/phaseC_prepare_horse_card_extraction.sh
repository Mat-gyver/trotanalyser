#!/bin/bash
set -e

LATEST=$(ls -t snapshots/course_horse_block_*.tsx | head -n 1)

if [ -z "$LATEST" ]; then
  echo "Aucun snapshot trouvé. Lance d'abord phaseA_freeze_working_state.sh"
  exit 1
fi

mkdir -p backups
STAMP=$(date +%Y%m%d_%H%M%S)
cp components/course/CourseHorseInlineCard.tsx "backups/CourseHorseInlineCard_before_phaseC_${STAMP}.tsx" 2>/dev/null || true

cat > components/course/CourseHorseInlineCard.tsx <<EOF2
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
  pariStars: (c: any) => string;
  styles: any;
};

export default function CourseHorseInlineCard(props: Props) {
  const {
    c,
    renderCasaque,
    scoreBar,
    iaProbBar,
    noteColor,
    shortAnalyse,
    alertTags,
    pariStars,
    styles,
  } = props;

  return (
$(cat "$LATEST")
  );
}
EOF2

echo "CourseHorseInlineCard préparé depuis snapshot : $LATEST"
npx tsc --noEmit --pretty false || true
