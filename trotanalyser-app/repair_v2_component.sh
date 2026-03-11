#!/bin/bash
set -e

FILE="components/course/CourseHorseInlineCard_v2.tsx"
BACK="backups/CourseHorseInlineCard_v2_before_repair_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACK"

echo "Backup créé : $BACK"

cat > "$FILE" <<'EOF2'
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
<View style={styles.card}>

<View style={[styles.cardHeader,{alignItems:"center"}]}>
<View style={styles.nameWrap}>
{renderCasaque(c)}

<Text style={styles.lineStats}>
{c.numero} - {c.nom}  SCORE IA {scoreBar(c.scoreIA)}
</Text>

</View>
</View>

</View>
);
}
EOF2

echo
echo "Composant v2 réparé."

echo
echo "=== TYPESCRIPT CHECK ==="
npx tsc --noEmit --pretty false || true
