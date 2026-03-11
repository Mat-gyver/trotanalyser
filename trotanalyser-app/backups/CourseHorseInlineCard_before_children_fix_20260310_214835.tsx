import React from "react";
import { View, Text } from "react-native";

type Props = {
  c: any;
  renderCasaque: (c:any)=>React.ReactNode;
  scoreBar: (v?:number)=>React.ReactNode;
  iaProbBar: (v?:number)=>React.ReactNode;
  noteColor: (v?:number)=>string;
  shortAnalyse: (s?:string)=>string;
  alertTags: (c:any)=>string[];
  pariStars: (c:any)=>React.ReactNode;
  styles: any;
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
}: Props) {

  return (
    <View style={styles.card}>
      <View style={[styles.cardHeader,{alignItems:"center"}]}>
        <View style={styles.nameWrap}>
          {renderCasaque(c)}

          <Text style={styles.lineStats}>
            {c.numero} - {c.nom} SCORE IA {scoreBar(c.scoreIA)} {c.scoreIA ?? "-"}
          </Text>
        </View>
      </View>
    </View>
  );
}
