#!/bin/bash
set -e

FILE="components/course/CourseHorseCard.tsx"
BACKUP="backups/CourseHorseCard_before_4lines_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

cat > "$FILE" <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";
import type { Participant } from "../../types/course";

function pct(v: any) {
  const n = Number(v || 0);
  return `${Math.round(n)}%`;
}

function cote(v: any) {
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

function cleanBadgeName(name: string) {
  return String(name || "")
    .replaceAll("_", " ")
    .trim();
}

function badgeStyle(name: string) {
  const n = name.toUpperCase();
  if (n.includes("VALUE")) return styles.badgeValue;
  if (n.includes("TOCARD")) return styles.badgeTocard;
  if (n.includes("OUTSIDER")) return styles.badgeOutsider;
  if (n.includes("PROGRES")) return styles.badgeProgress;
  if (n.includes("TOP")) return styles.badgeTop;
  return styles.badgeNeutral;
}

function gainsInfo(horse: Participant) {
  const gains = horse.gains;
  const gap = horse.texteEcartLimite;
  if (gains != null && gap) return `${gains}€ (${gap})`;
  if (gains != null) return `${gains}€`;
  if (gap) return gap;
  return null;
}

function alertBadges(horse: Participant) {
  return Array.isArray(horse.badges) ? horse.badges.slice(0, 3) : [];
}

export default function CourseHorseCard({ horse }: { horse: Participant }) {
  const gains = gainsInfo(horse);
  const badges = alertBadges(horse);

  return (
    <View style={styles.card}>
      {/* LIGNE 1 */}
      <View style={styles.row1}>
        <Text style={styles.title} numberOfLines={1}>
          #{horse.numero} {horse.nom}
        </Text>

        <View style={styles.pmuBox}>
          <Text style={styles.pmuLabel}>Cote PMU</Text>
          <Text style={styles.pmuValue}>{cote(horse.cotePMU)}</Text>
        </View>
      </View>

      {/* LIGNE 2 */}
      <Text style={styles.line2}>
        {horse.driver || "-"} / {horse.entraineur || "-"} • {horse.ferrure || "-"}
        {gains ? ` • ${gains}` : ""} • {horse.musique || "-"}
      </Text>

      {/* LIGNE 3 */}
      <View style={styles.row3}>
        <Text style={styles.metric}>IA {pct(horse.probabiliteIA)}</Text>
        <Text style={styles.dot}>•</Text>
        <Text style={styles.metric}>PMU {pct(horse.probabilitePMU)}</Text>

        {badges.map((b, i) => (
          <View key={`${b}-${i}`} style={[styles.badge, badgeStyle(b)]}>
            <Text style={styles.badgeText}>{cleanBadgeName(b)}</Text>
          </View>
        ))}

        <Text style={styles.indiceLabel}>Indice Pari :</Text>
        <Text style={styles.stars}>{stars(horse.rankIA)}</Text>
      </View>

      {/* LIGNE 4 */}
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

  row1: {
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
    minWidth: 72,
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

  row3: {
    flexDirection: "row",
    alignItems: "center",
    flexWrap: "nowrap",
    gap: 8,
    marginBottom: 10,
    overflow: "hidden",
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
    fontSize: 10,
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

  badgeProgress: {
    backgroundColor: "#6a3e3e",
  },

  badgeTop: {
    backgroundColor: "#23435c",
  },

  badgeNeutral: {
    backgroundColor: "#3c4b57",
  },

  indiceLabel: {
    color: "#f0d98a",
    fontSize: 12,
    fontWeight: "700",
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

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false
