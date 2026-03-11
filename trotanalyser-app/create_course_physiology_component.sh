#!/bin/bash
set -e

DIR="components/course"
FILE="$DIR/CoursePhysiology.tsx"

mkdir -p "$DIR"

cat > "$FILE" <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";

type Props = {
  data: any;
};

export default function CoursePhysiology({ data }: Props) {
  if (!data) return null;

  return (
    <View style={styles.wrapper}>
      <View style={styles.block}>
        <Text style={styles.title}>PHYSIONOMIE DE COURSE</Text>

        <Text style={styles.line}>
          <Text style={styles.label}>Train probable : </Text>
          <Text style={styles.value}>{data?.trainProbable || "-"}</Text>
        </Text>

        <Text style={styles.line}>
          <Text style={styles.label}>Train tactique : </Text>
          <Text style={styles.value}>{data?.trainTactique || "-"}</Text>
        </Text>

        <Text style={styles.line}>
          <Text style={styles.label}>Tête : </Text>
          <Text style={styles.value}>{data?.tete || "-"}</Text>
        </Text>

        <Text style={styles.line}>
          <Text style={styles.label}>Attentistes : </Text>
          <Text style={styles.value}>{data?.attentistes || "-"}</Text>
        </Text>

        <Text style={styles.line}>
          <Text style={styles.label}>Finisseurs : </Text>
          <Text style={styles.value}>{data?.finisseurs || "-"}</Text>
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginTop: 12,
    marginBottom: 12,
  },

  block: {
    backgroundColor: "#0b2a3c",
    borderRadius: 12,
    padding: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  title: {
    color: "#ffd76b",
    fontSize: 14,
    fontWeight: "800",
    marginBottom: 8,
  },

  line: {
    marginBottom: 4,
  },

  label: {
    color: "#9fc6da",
    fontSize: 13,
    fontWeight: "700",
  },

  value: {
    color: "#e7f1f7",
    fontSize: 13,
    lineHeight: 18,
  },
});
TSX

echo "CoursePhysiology.tsx créé"
