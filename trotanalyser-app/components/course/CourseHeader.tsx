import { View, Text } from "react-native";
import type { CourseData } from "../../types/courseScreen";

type Props = {
  data?: CourseData | null;
  styles: any;
};

export default function CourseHeader({ data, styles }: Props) {
  if (!data) return null;

  const hippodrome = data.hippodrome ?? "-";
  const reunion = data.reunion ?? "-";
  const numero = data.numero ?? "-";
  const distance = data.distance ?? "-";
  const partants = data.partants ?? "-";

  return (
    <View style={{ paddingHorizontal: 16, paddingTop: 10, paddingBottom: 12 }}>
      <Text style={styles.courseCode}>
        {hippodrome} — R{reunion}C{numero}
      </Text>

      <Text style={styles.meta}>
        {distance}m • {partants} partants
      </Text>
    </View>
  );
}
