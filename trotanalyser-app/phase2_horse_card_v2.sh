#!/bin/bash
set -e

mkdir -p components/course backups

cat > components/course/CourseHorseCard.tsx <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";
import type { Participant } from "../../types/course";

function formatPct(v: any) {
  const n = Number(v || 0);
  return `${Math.round(n)}%`;
}

function formatMusic(music?: string) {
  return music || "-";
}

function formatCote(v: any) {
  if (v === null || v === undefined || v === "") return "-";
  return String(v);
}

function starsFromRank(rankIA?: number) {
  const r = Number(rankIA || 99);
  if (r <= 3) return "⭐⭐⭐⭐";
  if (r <= 5) return "⭐⭐⭐";
  if (r <= 8) return "⭐⭐";
  return "⭐";
}

function badgeList(horse: Participant) {
  const badges = Array.isArray(horse.badges) ? horse.badges : [];
  return badges;
}

function badgeStyle(name: string) {
  const n = name.toUpperCase();
  if (n.includes("VALUE")) return styles.badgeValue;
  if (n.includes("TOCARD")) return styles.badgeTocard;
  if (n.includes("OUTSIDER")) return styles.badgeOutsider;
  if (n.includes("TOP")) return styles.badgeTop;
  if (n.includes("SURCOTE")) return styles.badgeSurcote;
  return styles.badgeNeutral;
}

function gainsText(horse: Participant) {
  const gains = horse.gains;
  const gap = horse.texteEcartLimite;
  if (gains == null && !gap) return null;
  if (gains != null && gap) return `${gains}€ (${gap})`;
  if (gains != null) return `${gains}€`;
  return gap || null;
}

export default function CourseHorseCard({ horse }: { horse: Participant }) {
  const badges = badgeList(horse);
  const gainsInfo = gainsText(horse);

  return (
    <View style={styles.card}>
      <View style={styles.rowTop}>
        <Text style={styles.title}>
          #{horse.numero} {horse.nom}
        </Text>

        <View style={styles.pmuBox}>
          <Text style={styles.pmuLabel}>Cote PMU</Text>
          <Text style={styles.pmuValue}>{formatCote(horse.cotePMU)}</Text>
        </View>
      </View>

      <Text style={styles.line2}>
        {horse.driver || "-"} / {horse.entraineur || "-"} • {horse.ferrure || "-"}
        {gainsInfo ? ` • ${gainsInfo}` : ""} • {formatMusic(horse.musique)}
      </Text>

      <View style={styles.line3}>
        <Text style={styles.metric}>IA {formatPct(horse.probabiliteIA)}</Text>
        <Text style={styles.dot}>•</Text>
        <Text style={styles.metric}>PMU {formatPct(horse.probabilitePMU)}</Text>

        {badges.slice(0, 2).map((b, idx) => (
          <View key={`${b}-${idx}`} style={[styles.badge, badgeStyle(b)]}>
            <Text style={styles.badgeText}>{b}</Text>
          </View>
        ))}

        <Text style={styles.stars}>{starsFromRank(horse.rankIA)}</Text>
      </View>

      <Text style={styles.analysis}>
        {horse.analyseIA || "Analyse IA indisponible"}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: "#0b2a3c",
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },
  rowTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: 10,
    marginBottom: 8,
  },
  title: {
    flex: 1,
    color: "#ffffff",
    fontSize: 20,
    fontWeight: "800",
  },
  pmuBox: {
    alignItems: "flex-end",
    minWidth: 64,
  },
  pmuLabel: {
    color: "#e1c979",
    fontSize: 12,
    fontWeight: "700",
  },
  pmuValue: {
    color: "#ffd76b",
    fontSize: 20,
    fontWeight: "800",
  },
  line2: {
    color: "#d8e8f2",
    fontSize: 14,
    fontWeight: "600",
    marginBottom: 10,
  },
  line3: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 8,
    marginBottom: 10,
  },
  metric: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
  },
  dot: {
    color: "#9ab6c8",
    fontSize: 14,
    fontWeight: "700",
  },
  badge: {
    borderRadius: 10,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  badgeText: {
    color: "#ffffff",
    fontSize: 11,
    fontWeight: "800",
  },
  badgeValue: {
    backgroundColor: "#7b6514",
  },
  badgeTocard: {
    backgroundColor: "#5a2b44",
  },
  badgeOutsider: {
    backgroundColor: "#1f5a7a",
  },
  badgeTop: {
    backgroundColor: "#23435c",
  },
  badgeSurcote: {
    backgroundColor: "#7f1d1d",
  },
  badgeNeutral: {
    backgroundColor: "#3c4b57",
  },
  stars: {
    color: "#ffd76b",
    fontSize: 18,
    fontWeight: "800",
  },
  analysis: {
    color: "#e7f1f7",
    fontSize: 14,
    lineHeight: 21,
  },
});
TSX

npx tsc --noEmit --pretty false
