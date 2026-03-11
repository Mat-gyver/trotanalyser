#!/bin/bash
set -e

FILE="components/course/CourseInsights.tsx"

mkdir -p components/course

cat > "$FILE" <<'EOT'
import React from "react";
import { View, Text } from "react-native";

type Props = {
  summary: string[];
  lecture: string[];
  strategy: string[];
  scanTop3: string[];
  scanValueBets: string[];
  physio: {
    trainProbable?: string;
    trainTactique?: string;
    tete?: string;
    attentistes?: string;
    finisseurs?: string;
  };
  styles: any;
};

export default function CourseInsights({
  summary,
  lecture,
  strategy,
  scanTop3,
  scanValueBets,
  physio,
  styles,
}: Props) {
  return (
    <>
      <View style={styles.dashboardWrap}>
        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>SYNTHÈSE PARI</Text>
          {summary?.length ? summary.map((line, i) => (
            <Text key={i} style={styles.dashboardText}>{line}</Text>
          )) : <Text style={styles.dashboardText}>-</Text>}
        </View>

        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>LECTURE DE COURSE</Text>
          {lecture?.length ? lecture.map((line, i) => (
            <Text key={i} style={styles.dashboardText}>{line}</Text>
          )) : <Text style={styles.dashboardText}>-</Text>}

          {strategy?.length ? (
            <>
              <Text style={[styles.dashboardTitle, { marginTop: 10 }]}>STRATÉGIE CONSEILLÉE</Text>
              {strategy.map((line, i) => (
                <Text key={i} style={styles.dashboardText}>{line}</Text>
              ))}
            </>
          ) : null}
        </View>

        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>SCAN COURSE</Text>

          <Text style={[styles.dashboardText, { fontWeight: "800" }]}>TOP 3 IA</Text>
          {scanTop3?.length ? scanTop3.map((line, i) => (
            <Text key={i} style={styles.dashboardText}>{line}</Text>
          )) : <Text style={styles.dashboardText}>-</Text>}

          <Text style={[styles.dashboardText, { fontWeight: "800", marginTop: 10 }]}>VALUE BETS</Text>
          {scanValueBets?.length ? scanValueBets.map((line, i) => (
            <Text key={i} style={styles.dashboardText}>{line}</Text>
          )) : <Text style={styles.dashboardText}>-</Text>}
        </View>
      </View>

      <View style={styles.physioBox}>
        <Text style={styles.physioTitle}>PHYSIONOMIE DE COURSE</Text>
        <Text style={styles.physioText}>Train probable : {physio?.trainProbable || "-"}</Text>
        <Text style={styles.physioText}>Train tactique : {physio?.trainTactique || "-"}</Text>
        <Text style={styles.physioText}>Tête : {physio?.tete || "-"}</Text>
        <Text style={styles.physioText}>Attentistes : {physio?.attentistes || "-"}</Text>
        <Text style={styles.physioText}>Finisseurs : {physio?.finisseurs || "-"}</Text>
      </View>
    </>
  );
}
EOT

echo "Composant créé : $FILE"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
