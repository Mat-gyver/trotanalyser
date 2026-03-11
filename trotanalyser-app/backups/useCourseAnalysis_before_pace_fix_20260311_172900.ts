import { useMemo } from "react";

type Participant = any;
type CourseData = any;


const impliedProb = (cote?: number | null) => {
  const c = Number(cote || 0);
  if (!c || c <= 0) return 0;
  return 100 / c;
};

const computeValueSignal = (p: any) => {
  const probIA = Number(p?.probabiliteIA || 0);
  const probPMU = impliedProb(p?.cotePMU);
  return Math.round((probIA - probPMU) * 10) / 10;
};

const isFavoriFragile = (p: any) => {
  const cotePMU = Number(p?.cotePMU || 0);
  const scoreIA = Number(p?.scoreIA || 0);
  const driverIndex = Number(p?.driverIndex || 0);

  return cotePMU > 0 && cotePMU <= 3 && scoreIA < 15 && driverIndex < 5;
};

const isGrosTocard = (p: any) => {
  const probIA = Number(p?.probabiliteIA || 0);
  const cotePMU = Number(p?.cotePMU || 0);
  const retardGains = Number(p?.retardGains || 0);

  return probIA >= 10 && cotePMU >= 20 && retardGains >= 5;
};

const detectRunStyle = (p: any) => {
  const txt = String(
    p?.analyseIA || p?.dataTurfPro || p?.shortAnalyse || ""
  ).toLowerCase();

  if (
    txt.includes("vite") ||
    txt.includes("en tête") ||
    txt.includes("anime") ||
    txt.includes("allant") ||
    txt.includes("devant")
  ) return "leader";

  if (
    txt.includes("attentiste") ||
    txt.includes("attendre") ||
    txt.includes("caché") ||
    txt.includes("sur une 3e ligne")
  ) return "closer";

  if (
    txt.includes("progression") ||
    txt.includes("vient bien") ||
    txt.includes("finisseur") ||
    txt.includes("finit vite")
  ) return "finisher";

  return "neutral";
};

const buildPaceAnalysis = (participants: any[]) => {
  const list = Array.isArray(participants) ? participants : [];

  const leaders = list.filter((p) => detectRunStyle(p) === "leader");
  const closers = list.filter((p) => detectRunStyle(p) === "closer");
  const finishers = list.filter((p) => detectRunStyle(p) === "finisher");

  let train: "LENT" | "NORMAL" | "RAPIDE" = "NORMAL";
  if (leaders.length >= 3) train = "RAPIDE";
  else if (leaders.length <= 1) train = "LENT";

  const alerts: string[] = [];
  if (train === "RAPIDE" && finishers.length > 0) {
    alerts.push("Rythme rapide : avantage aux finisseurs");
  }
  if (train === "LENT" && leaders.length > 0) {
    alerts.push("Rythme lent : avantage aux chevaux près de la tête");
  }
  if (leaders.length >= 4) {
    alerts.push("Possible bagarre en tête");
  }

  return {
    train,
    leaders,
    closers,
    finishers,
    alerts,
    paceAnalysis,
    valueBets,
    topValue: valueBets[0] || null,
  
  };
};

const enrichParticipantSignals = (p: any, pace: any) => {
  const valueSignal = computeValueSignal(p);
  const favoriFragile = isFavoriFragile(p);
  const grosTocard = isGrosTocard(p);

  const baseBadges = Array.isArray(p?.badges) ? [...p.badges] : [];

  if (valueSignal > 8 && !baseBadges.includes("VALUE BET")) {
    baseBadges.push("VALUE BET");
  }
  if (valueSignal > 15 && !baseBadges.includes("VALUE FORTE")) {
    baseBadges.push("VALUE FORTE");
  }
  if (favoriFragile && !baseBadges.includes("FAVORI FRAGILE")) {
    baseBadges.push("FAVORI FRAGILE");
  }
  if (grosTocard && !baseBadges.includes("GROS TOCARD")) {
    baseBadges.push("GROS TOCARD");
  }

  const style = detectRunStyle(p);
  if (pace?.train === "RAPIDE" && (style === "finisher" || style === "closer")) {
    if (!baseBadges.includes("PROFIL RYTHME")) {
      baseBadges.push("PROFIL RYTHME");
    }
  }
  if (pace?.train === "LENT" && style === "leader") {
    if (!baseBadges.includes("PROFIL RYTHME")) {
      baseBadges.push("PROFIL RYTHME");
    }
  }

  return {
    ...p,
    valueSignal,
    favoriFragile,
    grosTocard,
    runStyle: style,
    badges: baseBadges,
  };
};

export function useCourseAnalysis(data: CourseData | null) {
  const sortedParticipants = useMemo(() => {
    return [...(data?.participants || [])].sort(
      (a: Participant, b: Participant) =>
        Number(b.value || -999) - Number(a.value || -999) ||
        Number(b.scoreIA || 0) - Number(a.scoreIA || 0)
    );

  const paceAnalysis = useMemo(() => {
    return buildPaceAnalysis(sortedParticipants as any[]);
  }, [sortedParticipants]);


  }, [data]);

  const top3IA = useMemo(() => {
    return (sortedParticipants as any[])
      .map((p) => enrichParticipantSignals(p, paceAnalysis))
      .slice(0, 3);
  }, [sortedParticipants, paceAnalysis]);

  const valueBets = useMemo(() => {
    return [...sortedParticipants]
      .filter((c: Participant) => Number(c.value || 0) > 0)
      .sort((a: Participant, b: Participant) => Number(b.value || 0) - Number(a.value || 0))
      .slice(0, 3);
  }, [sortedParticipants]);

  const topValue = valueBets[0] || null;

  return {
    sortedParticipants: enrichedSortedParticipants,
    top3IA,
    valueBets,
    topValue,
  };
}
