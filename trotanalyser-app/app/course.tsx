import { useEffect, useState } from "react";
import { ScrollView, Text, View } from "react-native";
import { router, useLocalSearchParams } from "expo-router";

import CourseHeader from "../components/course/CourseHeader";
import CourseInsights from "../components/course/CourseInsights";
import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";
import { styles } from "../components/course/courseScreenStyles";
import type { Participant, CourseData } from "../types/courseScreen";
import { API_BASE } from "../constants/courseApiBase";
import { useCourseAnalysis } from "../hooks/useCourseAnalysis";

export default function CourseScreen() {
  const params = useLocalSearchParams();

  const reunion =
    typeof params.reunion === "string" ? params.reunion : undefined;

  const course =
    typeof params.course === "string" ? params.course : undefined;

  const [data, setData] = useState<CourseData | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!reunion || !course) return;

    let isMounted = true;

    const loadCourse = async () => {
      try {
        setError("");

        const base = API_BASE;

        if (!base) {
          throw new Error("API_BASE manquant");
        }

        const res = await fetch(`${base}/api/course/${reunion}/${course}`, {
          method: "GET",
          headers: {
            Accept: "application/json",
          },
        });

        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }

        const json = await res.json();
        const nextData = (json?.data ?? json ?? null) as CourseData | null;

        if (isMounted) {
          setData(nextData);
        }
      } catch (e) {
        console.error("Erreur chargement course:", e);
        if (isMounted) {
          setError(e instanceof Error ? e.message : "Erreur inconnue");
        }
      }
    };

    loadCourse();

    return () => {
      isMounted = false;
    };
  }, [reunion, course]);

  const { sortedParticipants = [] } = useCourseAnalysis(data);

  const shortFerrure = (f?: string) => {
    if (!f || f === "NR") return "NR";
    const u = String(f).toUpperCase();

    if (u.includes("ANTERIEURS_POSTERIEURS")) return "D4";
    if (u.includes("ANTERIEURS")) return "DA";
    if (u.includes("POSTERIEURS")) return "DP";

    return u;
  };

  const shortAnalyse = (txt?: string) => {
    if (!txt) return "";

    const cleaned = txt
      .replace(/Distance à confirmer\./gi, "")
      .replace(/Repères hippodrome encore limités\./gi, "")
      .replace(
        /Aptitude piste et météo à confirmer avec les données hippodrome\./gi,
        "",
      )
      .trim();

    const parts = cleaned
      .split(".")
      .map((x) => x.trim())
      .filter(Boolean);

    return parts.slice(0, 1).join(" • ");
  };

  const scoreBar = (score?: number) => {
    const s = Math.max(0, Math.min(40, Number(score || 0)));
    const full = Math.round(s / 4);
    return "█".repeat(full) + "░".repeat(10 - full);
  };

  const noteColor = (n?: number) => {
    const v = Number(n || 0);
    if (v <= 3) return "#ff6b6b";
    if (v <= 5) return "#f5b041";
    if (v <= 7) return "#7DFFB3";
    return "#37d67a";
  };

  const renderStars = (n?: number) => {
    const count = Math.max(1, Math.min(5, Number(n || 0)));
    return "⭐".repeat(count);
  };

  const renderIaProbBar = (probabiliteIA?: number) => {
    const iaProb = Number(probabiliteIA || 0);
    const width = Math.max(6, Math.min(100, Math.round(iaProb)));

    return (
      <View
        style={{
          width: 120,
          height: 10,
          borderRadius: 99,
          overflow: "hidden",
          backgroundColor: "rgba(255,255,255,0.10)",
          borderWidth: 1,
          borderColor: "rgba(255,255,255,0.08)",
        }}
      >
        <View
          style={{
            width: `${width}%`,
            height: "100%",
            backgroundColor: "#22c55e",
          }}
        />
      </View>
    );
  };

  const renderPmuProbBar = (probabilitePMU?: number) => {
    const pmuProb = Number(probabilitePMU || 0);
    const width = Math.max(6, Math.min(100, Math.round(pmuProb)));

    return (
      <View
        style={{
          width: 120,
          height: 10,
          borderRadius: 99,
          overflow: "hidden",
          backgroundColor: "rgba(255,255,255,0.10)",
          borderWidth: 1,
          borderColor: "rgba(255,255,255,0.08)",
        }}
      >
        <View
          style={{
            width: `${width}%`,
            height: "100%",
            backgroundColor: "#60a5fa",
          }}
        />
      </View>
    );
  };

  const renderCasaque = (c: Participant) => {
    if (c.casaque) {
      return <Text style={styles.casaque}>{c.casaque}</Text>;
    }

    return (
      <View style={styles.casaqueBox}>
        <Text style={styles.casaqueText}>🏇</Text>
      </View>
    );
  };

  if (!reunion || !course) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorText}>Paramètres de course manquants</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorText}>
          Impossible de charger la course{"\n"}
          <Text style={styles.infoText}>{error}</Text>
        </Text>
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

      <View
        style={{
          backgroundColor: "#0f2232",
          borderRadius: 16,
          padding: 14,
          marginBottom: 14,
          borderWidth: 1,
          borderColor: "#1b4667",
        }}
      >
        <Text style={{ color: "#ffffff", fontSize: 16, fontWeight: "800" }}>
          Contexte de course
        </Text>

        <Text style={{ color: "#c8deec", marginTop: 8 }}>
          Hippodrome : {data.hippodrome || "-"}
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Distance : {data.distance || "-"} m
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Partants : {data.partants || "-"}
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Météo : {data.meteo || "-"}
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Température : {data.temperature || "-"}
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Vent : {data.vent || "-"}
        </Text>
        <Text style={{ color: "#c8deec", marginTop: 4 }}>
          Souplesse : {data.souplesse || "-"}
        </Text>
      </View>

      <CourseInsights participants={sortedParticipants} styles={styles} />

      {sortedParticipants.map((c: Participant) => (
        <CourseHorseInlineCard key={String(c.numero)}>
          <View style={[styles.cardHeader, { alignItems: "center" }]}>
            <View style={styles.nameWrap}>
              {renderCasaque(c)}
              <Text style={styles.lineStats}>
                {c.numero} - {c.nom}
              </Text>
            </View>

            <View style={styles.rankPill}>
              <Text style={styles.rankText}>#{c.rankIA || "-"}</Text>
            </View>
          </View>

          <View
            style={{
              marginTop: 6,
              marginBottom: 8,
              gap: 6,
            }}
          >
            <Text style={styles.lineStats}>
              SCORE IA {scoreBar(c.scoreIA)} {c.scoreIA ?? "-"}
            </Text>

            <View
              style={{
                flexDirection: "row",
                alignItems: "center",
                gap: 8,
                flexWrap: "wrap",
              }}
            >
              <Text style={styles.lineStats}>
                IA {c.probabiliteIA ?? 0}%
              </Text>
              {renderIaProbBar(c.probabiliteIA)}
            </View>

            <View
              style={{
                flexDirection: "row",
                alignItems: "center",
                gap: 8,
                flexWrap: "wrap",
              }}
            >
              <Text style={styles.lineStats}>
                PMU {c.probabilitePMU ?? 0}%
              </Text>
              {renderPmuProbBar(c.probabilitePMU)}
            </View>
          </View>

          <View style={styles.badgesRow}>
            {(c.badges || []).slice(0, 4).map((badge: string, index: number) => (
              <View
                key={`${c.numero}-${badge}-${index}`}
                style={[
                  styles.badge,
                  badge === "VALUE BET" && styles.badgeValue,
                  badge === "TOP IA" && styles.badgeTop,
                  badge === "FAVORI FRAGILE" && styles.badgeFragile,
                  badge === "FAVORI SURCOTÉ" && styles.badgeSurcote,
                  badge === "TOCARD IA" && styles.badgeTocard,
                  badge === "OUTSIDER INTÉRESSANT" && styles.badgeOutsider,
                ]}
              >
                <Text style={styles.badgeText}>{badge}</Text>
              </View>
            ))}
          </View>

          <View style={styles.cardBody}>
            <View style={styles.cardLeft}>
              <Text style={styles.lineCompact}>
                {c.driver || "NR"}{" "}
                <Text
                  style={[
                    styles.noteInline,
                    { color: noteColor(c.driverIndex) },
                  ]}
                >
                  ({c.driverIndex ?? 0}/10)
                </Text>
                {" / "}
                {c.entraineur || "NR"}{" "}
                <Text
                  style={[
                    styles.noteInline,
                    { color: noteColor(c.trainerIndex) },
                  ]}
                >
                  ({c.trainerIndex ?? 0}/10)
                </Text>
                {" • "}
                {shortFerrure(c.ferrure)}
                {" • Cote PMU ≈ "}
                {c.cotePMU ?? "-"}
              </Text>

              <Text style={styles.lineCompact}>{c.musique || "-"}</Text>
              <Text style={styles.analysis}>{shortAnalyse(c.analyseIA)}</Text>
            </View>

            <View style={styles.cardRight}>
              <Text style={styles.scoreMeta}>
                Value{" "}
                <Text
                  style={[
                    styles.valueText,
                    (c.value || 0) > 5
                      ? styles.valueStrong
                      : (c.value || 0) > 0
                        ? styles.valuePositive
                        : styles.valueNegative,
                  ]}
                >
                  {c.value ?? "-"}
                </Text>
              </Text>

              <Text style={styles.microStats}>
                G{c.retardGains ?? 0} • R{c.regulariteIndex ?? 0}
              </Text>

              <View style={styles.inlineRow}>
                <Text
                  style={[
                    styles.levelBadge,
                    (c.probabiliteIA || 0) >= 20
                      ? styles.levelFavori
                      : (c.probabiliteIA || 0) >= 10
                        ? styles.levelChance
                        : styles.levelOutsider,
                  ]}
                >
                  {(c.probabiliteIA || 0) >= 20
                    ? "🟢 Favori"
                    : (c.probabiliteIA || 0) >= 10
                      ? "🟡 Chance"
                      : "🔴 Outsider"}
                </Text>

                <Text style={styles.pariIndex}>
                  Indice Pari : {renderStars(c.indicePari)}
                </Text>
              </View>
            </View>
          </View>
        </CourseHorseInlineCard>
      ))}
    </ScrollView>
  );
}
