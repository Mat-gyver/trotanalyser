#!/bin/bash
set -e

FILE="components/course/CourseHeader.tsx"
BACKUP="backups/course_header_before_harden_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

cat > "$FILE" <<'EOT'
import React from "react";
import { View, Text } from "react-native";

type Props = {
  data?: any;
  styles?: any;
};

export default function CourseHeader({ data, styles }: Props) {
  if (!data) {
    return null;
  }

  const safeStyles = styles || {};

  const hippodrome = data?.hippodrome ?? "-";
  const reunion = data?.reunion ?? "-";
  const numero = data?.numero ?? "-";
  const distance = data?.distance ?? "-";
  const partants = data?.partants ?? "-";

  return (
    <View style={safeStyles.topCard}>
      <Text style={safeStyles.courseTitle}>
        {hippodrome} — R{reunion}C{numero}
      </Text>

      <Text style={safeStyles.courseMeta}>
        {distance}m • {partants} partants
      </Text>
    </View>
  );
}
EOT

echo "CourseHeader sécurisé"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
