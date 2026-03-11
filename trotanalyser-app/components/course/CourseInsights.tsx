import { View, Text } from "react-native";
import type { Participant } from "../../types/courseScreen";

type Props = {
  participants: Participant[];
  styles: any;
};

export default function CourseInsights({ participants, styles }: Props) {
  const top3 = participants.slice(0, 3);
  const outsiders = participants.slice(3, 6);

  return (
    <View style={styles.dashboardWrap}>
      <View style={styles.dashboardCard}>
        <Text style={styles.dashboardTitle}>SYNTHÈSE PARI</Text>
        {top3.map((c, i) => (
          <Text key={String(c.numero)} style={styles.dashboardText}>
            #{i + 1} {c.numero} {c.nom}
          </Text>
        ))}
      </View>

      <View style={styles.dashboardCard}>
        <Text style={styles.dashboardTitle}>OUTSIDERS</Text>
        {outsiders.map((c) => (
          <Text key={String(c.numero)} style={styles.dashboardText}>
            {c.numero} {c.nom}
          </Text>
        ))}
      </View>
    </View>
  );
}
