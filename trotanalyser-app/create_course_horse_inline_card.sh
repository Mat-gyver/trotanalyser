#!/bin/bash
set -e

DIR="components/course"
FILE="$DIR/CourseHorseInlineCard.tsx"

mkdir -p "$DIR"

cat > "$FILE" <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";
import type { Participant } from "../../types/course";

type Props = {
  horse: Participant;
};

function pct(v: unknown) {
  const n = Number(v || 0);
  return `${Math.round(n)}%`;
}

function fmt(v: unknown) {
  if (v === null || v === undefined || v === "") return "-";
  return String(v);
}

function stars(rankIA?: number) {
  const r = Number(rankIA || 99);
  if (r <= 3) return "⭐⭐⭐⭐";
  if (r <= 5) return "⭐⭐⭐";
  if (r <= 8) return "⭐⭐";
  return "⭐";
}

export default function CourseHorseInlineCard({ horse }: Props) {
  return (
    <View style={styles.card}>
      <View style={styles.header}>
        <Text style={styles.name}>
          {horse.numero} - {horse.nom}
        </Text>
        <Text style={styles.rank}>#{fmt(horse.rankIA)}</Text>
      </View>

      <View style={styles.scoreRow}>
        <Text style={styles.scoreLabel}>SCORE IA</Text>
        <Text style={styles.scoreValue}>{fmt(horse.scoreIA)}</Text>
        <Text style={styles.sep}>IA</Text>
        <Text style={styles.percent}>{pct(horse.probabiliteIA)}</Text>
        <Text style={styles.sep}>PMU</Text>
        <Text style={styles.percent}>{pct((horse as any).probabilitePMU)}</Text>
      </View>

      <Text style={styles.line}>
        {fmt(horse.driver)} / {fmt(horse.entraineur)} • {fmt(horse.ferrure)} • Cote PMU ≈ {fmt(horse.cotePMU)}
      </Text>

      <Text style={styles.music}>{fmt(horse.musique)}</Text>

      <View style={styles.footer}>
        <Text style={styles.badge}>Indice Pari : {stars(horse.rankIA)}</Text>
        <Text style={styles.value}>Value {fmt(horse.value)}</Text>
      </View>

      <Text style={styles.analysis}>
        {fmt(horse.analyseIA)}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: "#0b2a3c",
    borderRadius: 14,
    padding: 14,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  name: {
    flex: 1,
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "800",
  },
  rank: {
    color: "#c7dceb",
    fontSize: 13,
    fontWeight: "700",
  },
  scoreRow: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 6,
    marginBottom: 8,
  },
  scoreLabel: {
    color: "#dfeef7",
    fontSize: 12,
    fontWeight: "800",
  },
  scoreValue: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "800",
  },
  sep: {
    color: "#9fc6da",
    fontSize: 12,
    fontWeight: "700",
  },
  percent: {
    color: "#ffffff",
    fontSize: 12,
    fontWeight: "800",
  },
  line: {
    color: "#d8e8f2",
    fontSize: 13,
    fontWeight: "600",
    marginBottom: 6,
  },
  music: {
    color: "#e7f1f7",
    fontSize: 13,
    marginBottom: 8,
  },
  footer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  badge: {
    color: "#ffd76b",
    fontSize: 12,
    fontWeight: "800",
  },
  value: {
    color: "#9df0a8",
    fontSize: 14,
    fontWeight: "800",
  },
  analysis: {
    color: "#dfeef7",
    fontSize: 13,
    lineHeight: 18,
  },
});
TSX

echo "CourseHorseInlineCard.tsx créé"
