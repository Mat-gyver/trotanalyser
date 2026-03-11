import CourseHeader from "../components/course/CourseHeader";
import { useEffect, useMemo, useState } from "react";
import {
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
} from "react-native";
import { router, useLocalSearchParams } from "expo-router";
import CourseSummary from "../components/course/CourseSummary";
import CoursePhysiology from "../components/course/CoursePhysiology";
import CourseHorseInlineCard from "../components/course/CourseHorseInlineCard";
import { styles } from "../components/course/courseScreenStyles";
import type { Participant, CourseData } from "../types/courseScreen";
import { API_BASE } from "../constants/courseApiBase";
import CourseInsights from "../components/course/CourseInsights";


export default function CourseScreen() {
  const { reunion, course } = useLocalSearchParams<{
    reunion?: string;
    course?: string;
  }>();

  const { width } = useWindowDimensions();
  const isWide = width >= 600;

  const [data, setData] = useState<CourseData | null>(null);
  const [error, setError] = useState(false)

  const sortedParticipants = useMemo(
    () =>
      [...(data?.participants || [])].sort(
        (a, b) =>
          Number(b.value || -999) - Number(a.value || -999) ||
          Number(b.scoreIA || 0) - Number(a.scoreIA || 0)
      ),
    [data]
  );

  useEffect(() => {
    const load = async () => {
      try {
        setError(false);
        const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`);
        const json = await res.json();
        setData(json);
      } catch {
        setError(true);
      }
    };

    if (reunion && course) load();
  }, [reunion, course]);

  const participants = useMemo<Participant[]>(
    () => data?.participants || [],
    [data],
  );

  const topIa = participants[0];
  const top3 = participants.slice(0, 3);

  const valueBets = [...participants]
    .filter((c) => (c.value || 0) > 0)
    .sort((a, b) => (b.value || 0) - (a.value || 0))
    .slice(0, 3);

  const topValue = [...participants].sort(
    (a, b) => (b.value || 0) - (a.value || 0),
  )[0];

  const topTocard = participants.find((c) =>
    (c.badges || []).includes("TOCARD IA"),
  );

  const topDriver = [...participants].sort(
    (a, b) => (b.driverIndex || 0) - (a.driverIndex || 0),
  )[0];

  const pronosticIa = participants.slice(0, 5).map((c) => c.numero).join(" - ");

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
      .replace(/Aptitude piste et météo à confirmer avec les données hippodrome\./gi, "")
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

  const pariStars = (c: Participant) => {
    const total =
      (c.scoreIA || 0) +
      (c.driverIndex || 0) +
      (c.trainerIndex || 0) +
      (c.retardGains || 0) +
      Math.max(0, Math.min(10, Number(c.value || 0))) +
      (c.confianceIA || 0) / 20;

    if (total >= 45) return "⭐⭐⭐⭐⭐";
    if (total >= 34) return "⭐⭐⭐⭐";
    if (total >= 25) return "⭐⭐⭐";
    if (total >= 16) return "⭐⭐";
    return "⭐";
  };

  const noteColor = (n?: number) => {
    const v = Number(n || 0);
    if (v <= 3) return "#ff6b6b";
    if (v <= 5) return "#f5b041";
    if (v <= 7) return "#7DFFB3";
    return "#37d67a";
  };

  const alertTags = (c: Participant) => {
    const tags: string[] = [];

    if ((c.badges || []).includes("FAVORI FRAGILE")) tags.push("⚠️ FAVORI FRAGILE");
    if (
      (c.badges || []).includes("TOCARD IA") ||
      ((c.value || 0) > 3 && (c.probabiliteIA || 0) <= 10)
    ) {
      tags.push("💣 GROS TOCARD");
    }
    if ((c.retardGains || 0) >= 5 && (c.scoreIA || 0) >= 12) tags.push("📈 EN PROGRÈS");
    if ((c.driverIndex || 0) >= 8) tags.push("🔥 DRIVER CHAUD");

    return tags.slice(0, 2);
  };

  const getMeteoIcon = (meteo?: string) => {
    const m = String(meteo || "").toLowerCase();
    if (m.includes("soleil") || m.includes("ensole")) return "☀️";
    if (m.includes("orage")) return "⛈️";
    if (m.includes("pluie") || m.includes("averse")) return "🌧️";
    if (m.includes("nuage") || m.includes("couvert")) return "☁️";
    if (m.includes("brouillard") || m.includes("brume")) return "🌫️";
    return "🌤️";
  };

  const souplesseIndex = (souplesse?: string | number) => {
    if (typeof souplesse === "number") {
      return Math.max(0, Math.min(4, Math.round(souplesse)));
    }
    const s = String(souplesse || "").toLowerCase();
    if (s.includes("très souple") || s.includes("tres souple")) return 0;
    if (s.includes("souple")) return 1;
    if (s.includes("bon") || s.includes("standard") || s.includes("normal")) return 2;
    if (s.includes("très dur") || s.includes("tres dur")) return 4;
    if (s.includes("dur")) return 3;
    return 2;
  };

  const souplesseLabel = (souplesse?: string | number) => {
    if (typeof souplesse === "string" && souplesse.trim()) return souplesse;
    return "Bon";
  };

  const lectureCourse = () => {
    const scores = participants.map((c) => c.scoreIA || 0);
    const max = scores.length ? Math.max(...scores) : 0;
    const min = scores.length ? Math.min(...scores) : 0;
    const ecart = max - min;

    const outsiders = participants
      .filter((c) => (c.badges || []).includes("TOCARD IA") || (c.value || 0) > 3)
      .slice(0, 3);

    const lines: string[] = [];

    if (topIa && (topIa.probabiliteIA || 0) >= 25) lines.push(`🔒 Favori solide : ${topIa.numero}`);
    else if (topIa) lines.push(`⚠️ Favori discutable : ${topIa.numero}`);

    if (ecart < 10) lines.push("⚡ Course ouverte pour les places");
    else if (ecart > 20) lines.push("🎯 Course assez lisible");
    else lines.push("🧩 Course intermédiaire");

    if (outsiders.length) {
      lines.push(`💣 Outsiders dangereux : ${outsiders.map((c) => c.numero).join(" ")}`);
    }

    return lines.slice(0, 3);
  };

  const strategieConseil = () => {
    const base = topIa ? `${topIa.numero}` : "-";
    const chances = participants.slice(1, 4).map((c) => c.numero).join(" ");
    const outsiders = participants
      .filter((c) => (c.badges || []).includes("TOCARD IA") || (c.value || 0) > 3)
      .slice(0, 3)
      .map((c) => c.numero)
      .join(" ");

    let jeu = "Jeu conseillé : Couplé / 2sur4";
    if (participants.filter((c) => (c.value || 0) > 3).length >= 3) {
      jeu = "Jeu conseillé : Quinté champ réduit";
    } else if ((participants[0]?.scoreIA || 0) - (participants[3]?.scoreIA || 0) < 8) {
      jeu = "Jeu conseillé : Trio / Multi";
    }

    return {
      base,
      chances: chances || "-",
      outsiders: outsiders || "-",
      jeu,
    };
  };

  const physionomieCourse = () => {
    const leaders = participants
      .filter((c) => (c.driverIndex || 0) >= 7 && (c.scoreIA || 0) >= 12)
      .slice(0, 3);

    const finishers = participants
      .filter((c) => (c.retardGains || 0) >= 4)
      .slice(0, 3);

    const attentistes = participants
      .filter((c) => (c.scoreIA || 0) < 12 && (c.value || 0) > 0)
      .slice(0, 3);

    let train: "RAPIDE" | "LENT" | "NORMAL" = "NORMAL";
    if (leaders.length >= 3) train = "RAPIDE";
    if (leaders.length <= 1) train = "LENT";

    const alerts: string[] = [];

    if (train === "RAPIDE") {
      alerts.push("⚡ Train sélectif probable");
      if (finishers.length >= 2) alerts.push("🔥 Avantage finisseurs");
      if ((participants[0]?.probabiliteIA || 0) >= 20) alerts.push("⚠️ Favoris exposés");
    } else if (train === "LENT") {
      alerts.push("🐢 Train tactique probable");
      alerts.push("🎯 Avantage chevaux de tête");
      if (leaders.length >= 1 && participants[0]) {
        alerts.push(`🔒 Base avantagée : ${participants[0].numero}`);
      }
    } else {
      alerts.push("➖ Train régulier probable");
      alerts.push("🧩 Course équilibrée");
      if (attentistes.length >= 2) alerts.push("🎲 Arrivée ouverte pour les places");
    }

    return {
      train,
      leaders,
      attentistes,
      finishers,
      alerts: alerts.slice(0, 3),
    };
  };

  const impliedProbPmu = (cote?: number) => {
    const c = Number(cote || 0);
    if (!c || c <= 0) return 0;
    return Math.max(0, Math.min(100, 100 / c));
  };

  
const iaProbBar = (probabiliteIA?: number, cotePMU?: number) => {
  const iaProb = Number(probabiliteIA || 0);
  const pmuProb = Number(cotePMU || 0) > 0 ? 100 / Number(cotePMU) : 0;

  const fillColor =
    iaProb > pmuProb ? "#22c55e" : iaProb < pmuProb ? "#ef4444" : "#d9efff";

  const width = Math.max(6, Math.min(100, Math.round(iaProb)));

  return (
    <View
      style={{
        width: "42%",
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
          backgroundColor: fillColor,
        }}
      />
    </View>
  );
};


const iaMiniBar = (prob?: number, cotePMU?: number) => {
  const ia = Math.max(0, Math.min(100, Number(prob || 0)))
  const pmuProb = cotePMU ? impliedProbPmu(cotePMU) : 0

  const color =
    ia > pmuProb
      ? "#22c55e"
      : ia < pmuProb
      ? "#ef4444"
      : "#d9efff"

  const scaled = Math.max(0, Math.min(100, ia * 0.4))

  return (
    <View style={styles.topBar}>
      <View
        style={[
          styles.topFill,
          { width: `${scaled}%`, backgroundColor: color },
        ]}
      />
    </View>
  )
}


const valueBadgeText = (value?: number) => {
  const v = Number(value || 0)
  if (v >= 8) return "VALUE FORTE"
  if (v >= 3) return "VALUE"
  if (v <= -3) return "SURCOTÉ"
  return null
}

const lectureValueSummary = (participants: Participant[] = []) => {
  const sorted = [...participants]
    .filter((c) => Number.isFinite(Number(c.value || 0)))
    .sort((a, b) => Number(b.value || 0) - Number(a.value || 0))

  const fortes = sorted.filter((c) => Number(c.value || 0) >= 8).slice(0, 3)
  if (fortes.length > 0) {
    return `Values fortes : ${fortes.map((c) => c.numero).join(" ")}`
  }

  const positives = sorted.filter((c) => Number(c.value || 0) >= 3).slice(0, 3)
  if (positives.length > 0) {
    return `Values à suivre : ${positives.map((c) => c.numero).join(" ")}`
  }

  const negatives = sorted.filter((c) => Number(c.value || 0) <= -3).slice(0, 2)
  if (negatives.length > 0) {
    return `Favoris surcotés : ${negatives.map((c) => c.numero).join(" ")}`
  }

  return "Pas de value nette"
}



const pmuBar = (cote?: number) => {
    const prob = impliedProbPmu(cote);
    const full = Math.round(Math.max(0, Math.min(100, prob)) / 10);
    return "█".repeat(full) + "░".repeat(10 - full);
  };

  const renderCasaque = (c: Participant) => {
    if (c.casaque) return <Text style={styles.casaque}>{c.casaque}</Text>;
    return (
      <View style={styles.casaqueBox}>
        <Text style={styles.casaqueText}>🏇</Text>
      </View>
    );
  };

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

            <CourseHeader data={data} />

      <CourseInsights
        summary={[
          `🎯 Cheval à battre : ${top3IA[0]?.numero || "-"} ${top3IA[0]?.nom || ""}`.trim(),
          `💰 Value principale : ${topValue ? `${topValue.numero} ${topValue.nom}` : "-"}`,
          `⚠️ Tocard dangereux : ${topTocard ? `${topTocard.numero} ${topTocard.nom}` : "-"}`,
          `🔥 Driver chaud : ${topDriver ? `${topDriver.driver || "-"}` : "-"}`
        ]}
        lecture={[
          `⚠️ Favori discutable : ${top3IA[0]?.numero || "-"}`,
          `🎯 Course assez lisible`,
          `🪨 Outsiders dangereux : ${sortedParticipants.slice(3, 6).map((c) => c.numero).join(" ") || "-"}`
        ]}
        strategy={[
          `Base : ${top3IA[0]?.numero || "-"}`,
          `Chances : ${top3IA.slice(1, 4).map((c) => c.numero).join(" ") || "-"}`,
          `Outsiders : ${sortedParticipants.slice(3, 6).map((c) => c.numero).join(" ") || "-"}`,
          `Jeu conseillé : Quinté champ réduit`
        ]}
        scanTop3={top3IA.map((c, i) => `#${i + 1} ${c.numero} ${c.nom}`)}
        scanValueBets={valueBets.map((c) => `${c.numero} ${c.nom} · ${c.value ?? "-"}`)}
        physio={{
          trainProbable: physionomieCourse.trainProbable,
          trainTactique: physionomieCourse.trainTactique,
          tete: physionomieCourse.tete,
          attentistes: physionomieCourse.attentistes,
          finisseurs: physionomieCourse.finisseurs,
        }}
        styles={styles}
      />

      
{sortedParticipants.map((c) => (
         <CourseHorseInlineCard key={String(c.numero)}> 
          <View style={[styles.cardHeader,{alignItems:"center"}]}>
            <View style={styles.nameWrap}>
              {renderCasaque(c)}
              <Text style={styles.lineStats}>
                {c.numero} - {c.nom}   SCORE IA {scoreBar(c.scoreIA)} {c.scoreIA ?? "-"}   IA {iaProbBar(c.probabiliteIA, c.cotePMU)} {c.probabiliteIA ?? 0}%   PMU {pmuBar(c.cotePMU)} {Math.round(impliedProbPmu(c.cotePMU))}%
              </Text>
            </View>

            

            <View style={styles.rankPill}>
              <Text style={styles.rankText}>#{c.rankIA || "-"}</Text>
            </View>
          </View>

          <View style={styles.badgesRow}>
            {(c.badges || []).slice(0, 3).map((badge, index) => (
              <View
                key={`${c.numero}-${badge}-${index}`}
                style={[
                  styles.badge,
                  badge === "VALUE BET" && styles.badgeValue,
                  badge === "TOP IA" && styles.badgeTop,
                  badge === "FAVORI FRAGILE" && styles.badgeFragile,
                  badge === "VALUE FORTE"
                ? styles.badgeValueStrong
                : badge === "VALUE"
                ? styles.badgeValue
                : badge === "SURCOTÉ"
                ? styles.badgeSurcote
                : badge === "TOCARD IA" && styles.badgeTocard,
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
                <Text style={[styles.noteInline, { color: noteColor(c.driverIndex) }]}>
                  ({c.driverIndex ?? 0}/10)
                </Text>
                {" / "}
                {c.entraineur || "NR"}{" "}
                <Text style={[styles.noteInline, { color: noteColor(c.trainerIndex) }]}>
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
              
              <Text style={styles.name}>
                
              </Text>

              <Text style={styles.scoreMeta}>
                 Value{" "}
                <Text
                  style={[
                    styles.valueText,
                    (c.value || 0) > 3
                      ? styles.valueStrong
                      : (c.value || 0) > 0
                      ? styles.valuePositive
                      : styles.valueNegative,
                  ]}
                >
                  {c.value ?? "-"}
                </Text>{" "}
                </Text>

              <Text style={styles.microStats}>
                G{c.retardGains ?? 0}
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

                <Text style={styles.pariIndex}>Indice Pari : {pariStars(c)}</Text>
              </View>

              <View style={styles.alertRow}>
                {alertTags(c).map((tag, index) => (
                  <View key={`${c.numero}-alert-${index}`} style={styles.alertPill}>
                    <Text style={styles.alertText}>{tag}</Text>
                  </View>
                ))}
              </View>
            </View>
          </View>
        </CourseHorseInlineCard>
      ))}
    </ScrollView>
  );
}
