#!/bin/bash
set -e

FILE="app/course.tsx"
BACKUP="backups/course_before_final_refactor_$(date +%Y%m%d_%H%M%S).tsx"

mkdir -p backups
cp "$FILE" "$BACKUP"
echo "Backup créé : $BACKUP"

cat > "$FILE" <<'TSX'
import React, { useEffect, useState } from "react";
import { ScrollView, Text, View, useWindowDimensions } from "react-native";
import { router, useLocalSearchParams } from "expo-router";

import CourseHeader from "../components/course/CourseHeader";
import CourseInsights from "../components/course/CourseInsights";
import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";
import { styles } from "../components/course/courseScreenStyles";
import type { Participant, CourseData } from "../types/courseScreen";
import { API_BASE } from "../constants/courseApiBase";
import { useCourseAnalysis } from "../hooks/useCourseAnalysis";

export default function CourseScreen() {
  const { reunion, course } = useLocalSearchParams<{
    reunion?: string;
    course?: string;
  }>();

  const { width } = useWindowDimensions();
  const isWide = width >= 600;

  const [data, setData] = useState<CourseData | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    if (!reunion || !course) return;

    let cancelled = false;

    const loadCourse = async () => {
      try {
        setError(false);

        const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`);
        const json = await res.json();

        if (!cancelled) {
          setData((json?.data ?? json) as CourseData);
        }
      } catch (e) {
        console.error("Erreur chargement course:", e);
        if (!cancelled) setError(true);
      }
    };

    loadCourse();

    return () => {
      cancelled = true;
    };
  }, [reunion, course]);

  const {
    sortedParticipants,
    top3IA,
    valueBets,
    topValue,
  } = useCourseAnalysis(data);

  if (error) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorText}>Impossible de charger la course</Text>
      </View>
    );
  }

  if (!data) {
    return (
      <View style={styles.center}>
        <Text style={styles.infoText}>Chargement...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.topBar}>
        <Text style={styles.back} onPress={() => router.back()}>
          ←
        </Text>
        <Text style={styles.topTitle}>Analyse course</Text>
      </View>

      <CourseHeader data={data} styles={styles} />

      <CourseInsights
        participants={sortedParticipants as Participant[]}
        styles={styles}
      />

      {!!top3IA?.length && (
        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>Top 3 IA</Text>
          <Text style={styles.dashboardText}>
            {top3IA.map((c: Participant) => `${c.numero}`).join(" - ")}
          </Text>
        </View>
      )}

      {!!valueBets?.length && (
        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>Value bets</Text>
          <Text style={styles.dashboardText}>
            {valueBets
              .slice(0, 3)
              .map((c: Participant) => `${c.numero}`)
              .join(" - ")}
          </Text>
        </View>
      )}

      {topValue && (
        <View style={styles.dashboardCard}>
          <Text style={styles.dashboardTitle}>Top value</Text>
          <Text style={styles.dashboardText}>
            #{topValue.numero} {topValue.nom}
          </Text>
        </View>
      )}

      {(sortedParticipants as Participant[]).map((c: Participant) => (
        <CourseHorseInlineCard
          key={String(c.numero)}
          c={c}
          sortedParticipants={sortedParticipants as Participant[]}
          styles={styles}
        />
      ))}

      {isWide && <View style={{ height: 24 }} />}
    </ScrollView>
  );
}
TSX

echo
echo "=== NOUVELLE TAILLE ==="
wc -l "$FILE"

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
