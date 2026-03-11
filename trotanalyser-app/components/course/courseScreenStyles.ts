import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#061923",
  },

  content: {
    paddingBottom: 24,
  },

  center: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#061923",
  },

  topBar: {
    flexDirection: "row",
    alignItems: "center",
    paddingTop: 16,
    paddingHorizontal: 16,
    paddingBottom: 12,
    backgroundColor: "#051726",
  },

  topFill: {
    height: "100%",
    borderRadius: 99,
  },

  back: {
    color: "#ffffff",
    fontSize: 24,
    marginRight: 14,
  },

  topTitle: {
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "700",
  },

  courseCode: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "800",
    marginBottom: 2,
  },

  meta: {
    color: "#c6d7e2",
    fontSize: 11,
    marginBottom: 6,
  },

  conditionsRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },

  conditionItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
  },

  conditionIcon: {
    fontSize: 16,
  },

  conditionText: {
    color: "#d9efff",
    fontSize: 10,
    fontWeight: "600",
  },

  soilWrap: {
    width: "42%",
    marginLeft: 6,
  },

  soilLabel: {
    color: "#d9efff",
    fontSize: 10,
    fontWeight: "700",
    marginBottom: 3,
  },

  soilTrack: {
    position: "relative",
    flexDirection: "row",
    height: 8,
    width: "100%",
    borderRadius: 99,
    overflow: "hidden",
  },

  soilSeg: {
    flex: 1,
  },

  soilVerySoft: {
    backgroundColor: "#2f7fd1",
  },

  soilSoft: {
    backgroundColor: "#52b7ff",
  },

  soilGood: {
    backgroundColor: "#5dbb63",
  },

  soilFirm: {
    backgroundColor: "#d4a24c",
  },

  soilVeryFirm: {
    backgroundColor: "#c95b4c",
  },

  soilMarker: {
    position: "absolute",
    top: -2,
    width: 10,
    height: 12,
    borderRadius: 99,
    backgroundColor: "#ffffff",
    borderWidth: 2,
    borderColor: "#082131",
    marginLeft: -5,
  },

  pronoLine: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "800",
    letterSpacing: 0.2,
    marginBottom: 2,
  },

  pronoSub: {
    color: "#d9efff",
    fontSize: 11,
    fontWeight: "700",
  },

  dashboardGrid: {
    gap: 12,
  },

  dashboardGridWide: {
    flexDirection: "row",
    alignItems: "stretch",
  },

  blockTitle: {
    color: "#ffffff",
    fontSize: 12,
    fontWeight: "800",
    marginBottom: 4,
  },

  summaryLine: {
    color: "#d9efff",
    fontSize: 10,
    marginBottom: 2,
    fontWeight: "700",
  },

  scanSection: {
    color: "#7fc6ff",
    fontSize: 10,
    fontWeight: "700",
    marginTop: 3,
    marginBottom: 2,
  },

  strategyBox: {
    marginTop: 6,
    paddingTop: 6,
    borderTopColor: "#234a61",
    borderTopWidth: 1,
  },

  strategyTitle: {
    color: "#ffffff",
    fontSize: 10,
    fontWeight: "800",
    marginBottom: 3,
  },

  strategyGame: {
    color: "#ffe082",
    fontSize: 10,
    fontWeight: "800",
    marginTop: 3,
  },

  physioTrain: {
    color: "#ffe082",
    fontWeight: "800",
    fontSize: 10,
    marginBottom: 3,
  },

  physioInfo: {
    color: "#d9efff",
    fontSize: 10,
    fontWeight: "700",
    marginBottom: 2,
  },

  physioRow: {
    color: "#d9efff",
    fontSize: 10,
    lineHeight: 14,
    fontWeight: "700",
  },

  card: {
    marginHorizontal: 16,
    marginBottom: 4,
    backgroundColor: "#0d2b3e",
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },

  cardHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 4,
  },

  nameWrap: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
    paddingRight: 10,
  },

  casaqueBox: {
    width: 22,
    height: 22,
    borderRadius: 6,
    backgroundColor: "#17384d",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 8,
  },

  casaqueText: {
    fontSize: 11,
  },

  casaque: {
    fontSize: 16,
    marginRight: 8,
  },

  name: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
  },

  rankPill: {
    backgroundColor: "#123a57",
    borderRadius: 8,
    paddingHorizontal: 6,
    paddingVertical: 3,
  },

  rankText: {
    color: "#d9efff",
    fontSize: 10,
    fontWeight: "700",
  },

  badgesRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 4,
    marginBottom: 4,
  },

  badge: {
    borderRadius: 8,
    paddingHorizontal: 6,
    paddingVertical: 3,
    backgroundColor: "#23435c",
  },

  badgeText: {
    color: "#ffffff",
    fontSize: 9,
    fontWeight: "800",
  },

  scoreMeta: {
    color: "#d9efff",
    fontSize: 11,
    fontWeight: "700",
    textAlign: "right",
    marginBottom: 2,
  },

  badgeValue: {
    backgroundColor: "#1f6b45",
  },

  badgeTop: {
    backgroundColor: "#355c1f",
  },

  badgeFragile: {
    backgroundColor: "#7a4a1e",
  },

  badgeValueStrong: {
    backgroundColor: "#14532d",
  },
  
  badgeSurcote: {
    backgroundColor: "#7f1d1d",
  },

  badgeTocard: {
    backgroundColor: "#6b2a6b",
  },

  badgeOutsider: {
    backgroundColor: "#1d4f73",
  },

  cardBody: {
    flexDirection: "row",
    gap: 10,
    justifyContent: "space-between",
  },

  cardLeft: {
    flex: 1.35,
  },

  cardRight: {
    flex: 1,
    alignItems: "flex-end",
  },

  lineCompact: {
    color: "#d9efff",
    fontSize: 11,
    marginBottom: 2,
  },

  noteInline: {
    fontSize: 11,
    fontWeight: "800",
  },

  analysis: {
    color: "#c6d7e2",
    fontSize: 10,
    lineHeight: 12,
  },

  lineStats: {
    color: "#d9efff",
    fontSize: 11,
    marginBottom: 1,
    fontWeight: "700",
    textAlign: "right",
  },

  microStats: {
    color: "#9fc4da",
    fontSize: 10,
    marginBottom: 3,
    fontWeight: "700",
    textAlign: "right",
  },

  compareBox: {
    marginBottom: 3,
    alignItems: "flex-end",
  },

  compareLabel: {
    color: "#d9efff",
    fontSize: 10,
    fontWeight: "700",
    marginBottom: 1,
    minWidth: 122,
    textAlign: "right",
  },

  valueText: {
    fontSize: 11,
    fontWeight: "800",
  },

  valueStrong: {
    color: "#7cff7c",
  },

  valuePositive: {
    color: "#5ee28d",
  },

  valueNegative: {
    color: "#ff7a7a",
  },

  inlineRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6,
    alignItems: "center",
    marginBottom: 3,
    justifyContent: "flex-end",
  },

  levelBadge: {
    fontSize: 9,
    fontWeight: "800",
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 7,
  },

  levelFavori: {
    color: "#dfffe8",
    backgroundColor: "#1f6b45",
  },

  levelChance: {
    color: "#fff5d6",
    backgroundColor: "#7a5a1e",
  },

  levelOutsider: {
    color: "#ffdede",
    backgroundColor: "#7a2b2b",
  },

  pariIndex: {
    color: "#ffe082",
    fontSize: 10,
    fontWeight: "800",
  },

  alertRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 4,
    justifyContent: "flex-end",
  },

  alertPill: {
    backgroundColor: "#3a2430",
    borderRadius: 7,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },

  alertText: {
    color: "#ffd7d7",
    fontSize: 9,
    fontWeight: "800",
  },

  errorText: {
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "700",
  },

  infoText: {
    color: "#d9efff",
    fontSize: 15,
  },

  horseGridTest: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
  },

  horseCardTest: {
    width: "32%",
    backgroundColor: "#0e2a3b",
    borderRadius: 14,
    paddingVertical: 5,
    marginBottom: 4,
  },

  dashboardWrap: {
    flexDirection: "row",
    gap: 12,
    marginTop: 12,
    marginBottom: 12,
  },

  dashboardCard: {
    flex: 1,
    backgroundColor: "#0b2a3c",
    borderRadius: 16,
    padding: 14,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  dashboardTitle: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
    marginBottom: 8,
  },

  dashboardText: {
    color: "#d9eefc",
    fontSize: 13,
    lineHeight: 20,
  },

  physioBox: {
    backgroundColor: "#0b2a3c",
    borderRadius: 16,
    padding: 14,
    marginTop: 12,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
  },

  physioTitle: {
    color: "#ffffff",
    fontSize: 14,
    fontWeight: "800",
    marginBottom: 8,
  },

  physioText: {
    color: "#d9eefc",
    fontSize: 13,
    lineHeight: 20,
  },

});
