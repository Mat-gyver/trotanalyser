import React from "react";
import { View, Text } from "react-native";

type Props = {
  data: any;
  meteo?: any;
  styles?: any;
};

export default function CourseHeader({
  data,
  meteo,
  styles
}: Props) {

  if (!data) return null;

  return (
    <View style={styles.topCard}>
      <Text style={styles.courseTitle}>
        {data.hippodrome} — R{data.reunion}C{data.numero}
      </Text>

      <Text style={styles.courseMeta}>
        {data.distance}m • {data.partants} partants
      </Text>

      {meteo && (
        <Text style={styles.weather}>
          {meteo.temperature}° • {meteo.condition}
        </Text>
      )}
    </View>
  );
}
