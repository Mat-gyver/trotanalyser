#!/bin/bash
set -e

mkdir -p components

cat > components/CourseHorseCard.tsx <<'TSX'
import { View, Text, StyleSheet } from "react-native";

export default function CourseHorseCard({ horse }: any) {

  const ia = horse?.probabiliteIA ?? 0;
  const pmu = horse?.probabilitePMU ?? 0;

  return (
    <View style={styles.card}>

      {/* LIGNE 1 */}
      <View style={styles.rowBetween}>
        <Text style={styles.title}>
          #{horse.numero} {horse.nom}
        </Text>

        <View style={styles.coteBox}>
          <Text style={styles.coteLabel}>Cote PMU</Text>
          <Text style={styles.coteValue}>{horse.cotePMU ?? "-"}</Text>
        </View>
      </View>

      {/* LIGNE 2 */}
      <Text style={styles.line2}>
        {horse.driver} / {horse.entraineur} • {horse.ferrure} • {horse.musique}
      </Text>

      {/* LIGNE 3 */}
      <View style={styles.row}>
        <Text style={styles.metric}>IA {ia}%</Text>
        <Text style={styles.metric}>PMU {pmu}%</Text>

        {horse.badges?.includes("GROS_TOCARD") && (
          <Text style={styles.badge}>💣 GROS TOCARD</Text>
        )}

        <Text style={styles.stars}>⭐⭐⭐</Text>
      </View>

      {/* LIGNE 4 */}
      <Text style={styles.analysis}>
        {horse.analyseIA ?? "Analyse IA indisponible"}
      </Text>

    </View>
  );
}

const styles = StyleSheet.create({

card:{
backgroundColor:"#0b2a3c",
borderRadius:16,
padding:16,
marginBottom:12,
borderWidth:1,
borderColor:"rgba(255,255,255,0.08)"
},

rowBetween:{
flexDirection:"row",
justifyContent:"space-between",
alignItems:"center",
marginBottom:6
},

title:{
color:"#ffffff",
fontSize:22,
fontWeight:"700"
},

coteBox:{
alignItems:"flex-end"
},

coteLabel:{
color:"#9fc6da",
fontSize:12
},

coteValue:{
color:"#ffd66b",
fontSize:22,
fontWeight:"700"
},

line2:{
color:"#d6e7f2",
fontSize:14,
marginBottom:8
},

row:{
flexDirection:"row",
alignItems:"center",
gap:10,
marginBottom:8
},

metric:{
color:"#9fe0b1",
fontWeight:"700"
},

badge:{
backgroundColor:"#5a2b2b",
color:"#ff9b9b",
paddingHorizontal:8,
paddingVertical:3,
borderRadius:8,
fontSize:12
},

stars:{
color:"#ffd66b"
},

analysis:{
color:"#e6f2f8",
fontSize:14,
lineHeight:20
}

});
TSX

echo "Composant CourseHorseCard créé."

