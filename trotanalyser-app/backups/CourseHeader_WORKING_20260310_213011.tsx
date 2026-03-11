import React from "react";
import { View, Text, StyleSheet } from "react-native";

type Props = {
  data: any;
};

export default function CourseHeader({ data }: Props) {
  if (!data) return null;

  const reunion = data?.reunion || "R?";
  const course = data?.course || "C?";
  const hippodrome = data?.hippodrome || "Hippodrome";
  const distance = data?.distance || "-";
  const partants = data?.participants?.length ?? data?.partants ?? "-";
  const meteo = data?.meteo || "NR";
  const vent = data?.vent || "NR";
  const sol = data?.sol || "Bon";

  return (
    <View style={styles.wrapper}>
      <Text style={styles.rc}>
        {reunion} {course}
      </Text>

      <Text style={styles.meta}>
        {hippodrome} • {distance} • {partants} partants
      </Text>

      <View style={styles.infoRow}>
        <Text style={styles.info}>🌤️ Météo {meteo}</Text>
        <Text style={styles.info}>🏁 {vent} km/h</Text>
        <Text style={styles.info}>Sol : {sol}</Text>
      </View>

      <View style={styles.pronoBox}>
        <Text style={styles.pronoTitle}>⭐ PRONOSTIC IA</Text>
        <Text style={styles.pronoText}>{data?.pronosticIA || "-"}</Text>
        <Text style={styles.pronoSub}>{data?.strategieBase || "-"}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginBottom: 12,
  },

  rc: {
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 2,
  },

  meta: {
    color: "#c7dceb",
    fontSize: 13,
    fontWeight: "600",
    marginBottom: 8,
  },

  infoRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
    marginBottom: 10,
  },

  info: {
    color: "#dfeef7",
    fontSize: 12,
    fontWeight: "700",
  },

  pronoBox: {
    backgroundColor: "#0b2a3c",
    borderRadius: 14,
    padding: 14,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  pronoTitle: {
    color: "#ffd76b",
    fontSize: 15,
    fontWeight: "800",
    marginBottom: 6,
  },

  pronoText: {
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "800",
    marginBottom: 4,
  },

  pronoSub: {
    color: "#c7dceb",
    fontSize: 13,
    fontWeight: "600",
  },
});
