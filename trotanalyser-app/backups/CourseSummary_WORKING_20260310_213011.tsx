import React from "react";
import { View, Text, StyleSheet } from "react-native";

type Props = {
  data: any;
};

export default function CourseSummary({ data }: Props) {
  if (!data) return null;

  return (
    <View style={styles.wrapper}>

      <View style={styles.block}>
        <Text style={styles.title}>SYNTHÈSE PARI</Text>
        <Text style={styles.text}>{data?.synthese || "-"}</Text>
      </View>

      <View style={styles.block}>
        <Text style={styles.title}>LECTURE DE COURSE</Text>
        <Text style={styles.text}>{data?.lecture || "-"}</Text>
      </View>

      <View style={styles.block}>
        <Text style={styles.title}>SCAN COURSE</Text>
        <Text style={styles.text}>{data?.scan || "-"}</Text>
      </View>

    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginTop: 12,
    marginBottom: 12,
    gap: 10,
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
    marginBottom: 6,
  },

  text: {
    color: "#e7f1f7",
    fontSize: 13,
    lineHeight: 18,
  },
});
