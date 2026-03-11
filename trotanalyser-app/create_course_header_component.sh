#!/bin/bash
set -e

FILE="components/course/CourseHeader.tsx"

mkdir -p components/course

cat > "$FILE" <<'EOT'
import React from "react";
import { View, Text } from "react-native";

type Props = {
  course: any;
  meteo: any;
  styles: any;
};

export default function CourseHeader({
  course,
  meteo,
  styles
}: Props) {

  if (!course) return null;

  return (
    <View style={styles.topCard}>
      <Text style={styles.courseTitle}>
        {course.hippodrome} — R{course.reunion}C{course.numero}
      </Text>

      <Text style={styles.courseMeta}>
        {course.distance}m • {course.partants} partants
      </Text>

      {meteo && (
        <Text style={styles.weather}>
          {meteo.temperature}° • {meteo.condition}
        </Text>
      )}
    </View>
  );
}
EOT

echo "Composant créé : $FILE"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
