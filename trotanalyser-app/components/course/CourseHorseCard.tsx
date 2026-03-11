import React from "react";
import { View, Text, StyleSheet } from "react-native";
import type { Participant } from "../../types/course";

function pct(v: unknown) {
  const n = Number(v || 0);
  return `${Math.round(n)}%`;
}

function fmt(v: unknown) {
  if (v === null || v === undefined || v === "") return "-";
  return String(v);
}

function cleanText(v: unknown) {
  return String(v || "").trim();
}

function stars(rankIA?: number) {
  const r = Number(rankIA || 99);
  if (r <= 3) return "⭐⭐⭐⭐";
  if (r <= 5) return "⭐⭐⭐";
  if (r <= 8) return "⭐⭐";
  return "⭐";
}

function badgeStyle(name: string) {
  const n = name.toUpperCase();
  if (n.includes("VALUE")) return styles.badgeValue;
  if (n.includes("TOCARD")) return styles.badgeTocard;
  if (n.includes("OUTSIDER")) return styles.badgeOutsider;
  if (n.includes("PROGRES")) return styles.badgeProgress;
  if (n.includes("TOP")) return styles.badgeTop;
  if (n.includes("SURCOTE")) return styles.badgeSurcote;
  return styles.badgeNeutral;
}

function displayBadges(horse: Participant) {
  return Array.isArray(horse.badges) ? horse.badges.slice(0, 3) : [];
}

function gainsAndGap(horse: Participant) {
  const gains = horse.gains;
  const gap = horse.texteEcartLimite;
  if (gains != null && gap) return `${gains}€ (${gap})`;
  if (gains != null) return `${gains}€`;
  if (gap) return String(gap);
  return null;
}

export default function CourseHorseCard({ horse }: { horse: Participant }) {
  const badges = displayBadges(horse);
  const gainsGap = gainsAndGap(horse);

  const line2Parts = [
    `${fmt(horse.driver)} / ${fmt(horse.entraineur)}`,
    fmt(horse.ferrure),
    gainsGap,
    fmt(horse.musique),
  ].filter(Boolean);

  return (
    <View style={styles.card}>
      {/* LIGNE 1 */}
      <View style={styles.row1}>
        <Text style={styles.title} numberOfLines={1}>
          #{horse.numero} {horse.nom}
        </Text>

        <View style={styles.pmuBox}>
          <Text style={styles.pmuLabel}>Cote PMU</Text>
          <Text style={styles.pmuValue}>{fmt(horse.cotePMU)}</Text>
        </View>
      </View>

      {/* LIGNE 2 */}
      <Text style={styles.line2} numberOfLines={1}>
        {line2Parts.join(" • ")}
      </Text>

      {/* LIGNE 3 */}
      <View style={styles.row3}>
        <Text style={styles.metric}>IA {pct(horse.probabiliteIA)}</Text>
        <Text style={styles.dot}>•</Text>
        <Text style={styles.metric}>PMU {pct((horse as any).probabilitePMU)}</Text>

        {badges.map((badge, index) => (
          <View key={`${badge}-${index}`} style={[styles.badge, badgeStyle(String(badge))]}>
            <Text style={styles.badgeText} numberOfLines={1}>
              {cleanText(badge).replaceAll("_", " ")}
            </Text>
          </View>
        ))}

        <Text style={styles.indiceLabel}>Indice Pari :</Text>
        <Text style={styles.stars}>{stars(horse.rankIA)}</Text>
      </View>

      {/* LIGNE 4 */}
      <Text style={styles.analysis}>
        {cleanText(horse.analyseIA) || "Analyse IA indisponible"}
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
    minWidth: 76,
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

  badgeSurcote: {
    backgroundColor: "#7f1d1d",
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
