
import React from "react";
import { View, Text } from "react-native";

type Props = {
  participants: any[];
  styles: any;
};

export default function CourseInsights({ participants, styles }: Props) {

  const top3 = [...participants].slice(0,3)
  const outsiders = [...participants].slice(3,6)

  return (
    <>
      <View style={styles.dashboardWrap}>
        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>SYNTHÈSE PARI</Text>
          {top3.map((c,i)=>(
            <Text key={i} style={styles.dashboardText}>
              #{i+1} {c.numero} {c.nom}
            </Text>
          ))}
        </View>

        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>OUTSIDERS</Text>
          {outsiders.map((c,i)=>(
            <Text key={i} style={styles.dashboardText}>
              {c.numero} {c.nom}
            </Text>
          ))}
        </View>
      </View>
    </>
  )
}
