import { useEffect, useState } from "react";
import { router } from "expo-router";
import {
  ActivityIndicator,
  RefreshControl,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { API_BASE } from "../../constants/courseApiBase";

type Course = {
  reunion: string;
  course: string;
  titre: string;
  heure?: string;
  distance?: number | string;
  partants?: number | string;
  quinte?: boolean;
  valueMax?: number;
};

type Reunion = {
  reunion: string;
  hippodrome: string;
  courses: Course[];
};

export default function ReunionsScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [reunions, setReunions] = useState<Reunion[]>([]);
  const [error, setError] = useState("");

  async function loadData() {
    try {
      setError("");

      const base = API_BASE;

      if (!base) {
        throw new Error("API_BASE manquant");
      }

      // lecture cache
      const cache = await AsyncStorage.getItem("reunions_cache");

      if (cache) {
        try {
          const parsed = JSON.parse(cache);
          if (Array.isArray(parsed)) {
            setReunions(parsed);
          }
        } catch {
          await AsyncStorage.removeItem("reunions_cache");
        }
      }

      const res = await fetch(`${base}/api/programme/today`, {
        headers: {
          Accept: "application/json",
        },
      });

      if (!res.ok) {
        throw new Error(`HTTP ${res.status}`);
      }

      const json = await res.json();
      const reunionsData = Array.isArray(json?.reunions) ? json.reunions : [];

      const enriched = await Promise.all(
        reunionsData.map(async (reunion: any) => {
          const courses = await Promise.all(
            (Array.isArray(reunion?.courses) ? reunion.courses : []).map(
              async (course: any) => {
                try {
                  const resCourse = await fetch(
                    `${base}/api/course/${course.reunion}/${course.course}`,
                    {
                      headers: { Accept: "application/json" },
                    }
                  );

                  if (!resCourse.ok) {
                    throw new Error(`HTTP ${resCourse.status}`);
                  }

                  const jsonCourse = await resCourse.json();
                  const participants = Array.isArray(jsonCourse?.participants)
                    ? jsonCourse.participants
                    : [];

                  const values = participants
                    .map((p: any) => {
                      const probIA = Number(p?.probabiliteIA || 0);
                      const cotePMU = Number(p?.cotePMU || 0);

                      if (!cotePMU || cotePMU <= 0) return null;

                      const probPMU = 100 / cotePMU;
                      const value = probIA - probPMU;

                      return Number.isFinite(value) ? Math.round(value) : null;
                    })
                    .filter((v: number | null): v is number => v !== null);

                  return {
                    ...course,
                    valueMax: values.length ? Math.max(...values) : 0,
                  };
                } catch {
                  return {
                    ...course,
                    valueMax: 0,
                  };
                }
              }
            )
          );

          return {
            ...reunion,
            courses,
          };
        })
      );

      setReunions(enriched);

      await AsyncStorage.setItem(
        "reunions_cache",
        JSON.stringify(enriched)
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : "Erreur inconnue");
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  if (loading) {
    return (
      <SafeAreaView style={styles.center}>
        <ActivityIndicator />
        <Text style={styles.small}>Chargement des réunions...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              setRefreshing(true);
              loadData();
            }}
          />
        }
      >
        <Text style={styles.screenTitle}>Réunions du jour</Text>

        {error ? <Text style={styles.error}>{error}</Text> : null}

        {reunions.map((reunion) => (
          <View key={reunion.reunion} style={styles.card}>
            <Text style={styles.hippodrome}>
              {reunion.reunion} • {reunion.hippodrome}
            </Text>

            {reunion.courses.map((course) => (
              <TouchableOpacity
                key={`${course.reunion}-${course.course}`}
                style={styles.courseButton}
                onPress={() =>
                  router.push({
                    pathname: "/course",
                    params: {
                      reunion: course.reunion,
                      course: course.course,
                    },
                  })
                }
              >
                <View style={{ flex: 1 }}>
                  <View style={styles.courseHeader}>
                    <Text style={styles.courseTitle}>{course.titre}</Text>

                    {typeof course.valueMax === "number" &&
                    course.valueMax >= 8 ? (
                      <Text style={styles.valueBadge}>
                        🔥 VALUE +{course.valueMax}
                      </Text>
                    ) : null}
                  </View>

                  <Text style={styles.courseMeta}>
                    {course.heure || "-"} • {course.distance || "-"} m •{" "}
                    {course.partants || "-"} partants
                  </Text>

                  {course.quinte ? (
                    <Text style={styles.quinte}>Quinté+</Text>
                  ) : null}
                </View>

                <Text style={styles.arrow}>›</Text>
              </TouchableOpacity>
            ))}
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    backgroundColor: "#04101a",
    justifyContent: "center",
    alignItems: "center",
  },
  small: {
    color: "#b9d6ea",
    marginTop: 8,
  },
  container: {
    flex: 1,
    backgroundColor: "#04101a",
  },
  content: {
    padding: 16,
    paddingBottom: 40,
  },
  screenTitle: {
    color: "#ffffff",
    fontSize: 26,
    fontWeight: "800",
    marginBottom: 16,
  },
  error: {
    color: "#ff9c9c",
    marginBottom: 12,
  },
  card: {
    backgroundColor: "#0b1c2b",
    borderRadius: 18,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: "#1f3d5a",
  },
  hippodrome: {
    color: "#ffffff",
    fontSize: 20,
    fontWeight: "800",
    marginBottom: 10,
  },
  courseButton: {
    backgroundColor: "#10283b",
    borderRadius: 14,
    padding: 14,
    marginTop: 10,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#1b4667",
  },
  courseHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    gap: 8,
  },
  valueBadge: {
    backgroundColor: "#ff7043",
    color: "#ffffff",
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 6,
    fontSize: 12,
    fontWeight: "700",
  },
  courseTitle: {
    color: "#ffffff",
    fontSize: 15,
    fontWeight: "700",
    flexShrink: 1,
  },
  courseMeta: {
    color: "#9fc0d8",
    marginTop: 4,
  },
  quinte: {
    color: "#ffd166",
    marginTop: 4,
    fontWeight: "700",
  },
  arrow: {
    color: "#7fd3ff",
    fontSize: 28,
    marginLeft: 10,
  },
});
