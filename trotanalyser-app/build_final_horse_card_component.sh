#!/bin/bash
set -e

LATEST=$(ls -t snapshots/CourseHorseInlineCard_clean_*.tsx 2>/dev/null | head -n 1)

if [ -z "$LATEST" ]; then
  echo "Aucun snapshot nettoyé trouvé."
  exit 1
fi

OUT="components/course/CourseHorseInlineCard_v2.tsx"

mkdir -p components/course

cat > "$OUT" <<EOF2
import React from "react";
import { View, Text } from "react-native";

type Props = {
  c: any;
  renderCasaque: (c:any)=>React.ReactNode;
  scoreBar: (v?:number)=>React.ReactNode;
  iaProbBar: (a?:number,b?:number)=>React.ReactNode;
  noteColor: (n?:number)=>string;
  shortAnalyse: (s?:string)=>string;
  alertTags: (c:any)=>string[];
  pariStars: (c:any)=>React.ReactNode;
  styles:any;
};

export default function CourseHorseInlineCard({
  c,
  renderCasaque,
  scoreBar,
  iaProbBar,
  noteColor,
  shortAnalyse,
  alertTags,
  pariStars,
  styles
}:Props){

return (
<>
EOF2

cat "$LATEST" >> "$OUT"

cat >> "$OUT" <<'EOF2'
</>
);
}
EOF2

echo "Composant créé : $OUT"

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
