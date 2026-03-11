import { useMemo } from "react";
import type { CourseData, Participant } from "../types/courseScreen";

type EnrichedParticipant = Participant & {
  valueSignal: number;
  favoriFragile: boolean;
  grosTocard: boolean;
};

export function useCourseAnalysis(data: CourseData | null) {
  const participants = useMemo<Participant[]>(() => {
    if (!Array.isArray(data?.participants)) return [];
    return data.participants;
  }, [data]);

  const sortedParticipants = useMemo<Participant[]>(() => {
    return [...participants].sort(
      (a, b) => (Number(b.scoreIA) || 0) - (Number(a.scoreIA) || 0),
    );
  }, [participants]);

  const paceAnalysis = useMemo(() => {
    const leaders = sortedParticipants.filter((p) =>
      String(p.analyseIA || "").toLowerCase().includes("tête"),
    );

    const finishers = sortedParticipants.filter((p) =>
      String(p.analyseIA || "").toLowerCase().includes("fin"),
    );

    let train: "RAPIDE" | "NORMAL" | "LENT" = "NORMAL";

    if (leaders.length >= 3) train = "RAPIDE";
    else if (leaders.length <= 1) train = "LENT";

    return {
      train,
      leaders,
      finishers,
    };
  }, [sortedParticipants]);

  const enrichedSortedParticipants = useMemo<EnrichedParticipant[]>(() => {
    return sortedParticipants.map((p) => {
      const probIA = Number((p as any).probabiliteIA || 0);
      const cote = Number(p.cotePMU || 0);
      const retard = Number(p.retardGains || 0);
      const scoreIA = Number(p.scoreIA || 0);
      const driverIndex = Number(p.driverIndex || 0);

      const probPMU = cote > 0 ? 100 / cote : 0;
      const value = probIA - probPMU;

      const favoriFragile =
        cote > 0 && cote <= 3 && scoreIA < 15 && driverIndex < 5;

      const grosTocard = probIA >= 10 && cote >= 20 && retard >= 5;

      return {
        ...p,
        valueSignal: value,
        favoriFragile,
        grosTocard,
      };
    });
  }, [sortedParticipants]);

  const valueBets = useMemo<EnrichedParticipant[]>(() => {
    return enrichedSortedParticipants
      .filter((p) => p.valueSignal > 8)
      .sort((a, b) => b.valueSignal - a.valueSignal);
  }, [enrichedSortedParticipants]);

  const top3IA = useMemo<EnrichedParticipant[]>(() => {
    return enrichedSortedParticipants.slice(0, 3);
  }, [enrichedSortedParticipants]);

  const topValue = useMemo<EnrichedParticipant | null>(() => {
    return valueBets.length > 0 ? valueBets[0] : null;
  }, [valueBets]);

  return {
    sortedParticipants: enrichedSortedParticipants,
    top3IA,
    valueBets,
    paceAnalysis,
    topValue,
  };
}
