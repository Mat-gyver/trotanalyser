import type { CourseData, Participant } from "../types/courseScreen";

type CourseAnalysisResult = {
  sortedParticipants: Participant[];
  top3IA: Participant[];
  valueBets: Participant[];
  topValue: Participant | null;
};

function toNumber(value: unknown, fallback = 0): number {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function normaliseParticipant(participant: Participant, index: number): Participant {
  return {
    ...participant,
    numero: toNumber(participant.numero, index + 1),
    scoreIA: toNumber(participant.scoreIA, 0),
    probabiliteIA: toNumber(participant.probabiliteIA, 0),
    confianceIA: toNumber(participant.confianceIA, 0),
    value: toNumber(participant.value, 0),
    retardGains: toNumber(participant.retardGains, 0),
    driverIndex: toNumber(participant.driverIndex, 0),
    trainerIndex: toNumber(participant.trainerIndex, 0),
    rankIA: toNumber(participant.rankIA, 0),
    cotePMU: toNumber(participant.cotePMU, 0),
    badges: Array.isArray(participant.badges) ? participant.badges : [],
    nom: participant.nom || `Cheval ${index + 1}`,
    musique: participant.musique || "",
    ferrure: participant.ferrure || "NR",
    driver: participant.driver || "NR",
    entraineur: participant.entraineur || "NR",
    analyseIA: participant.analyseIA || "",
    casaque: participant.casaque || "",
  };
}

function compareParticipants(a: Participant, b: Participant): number {
  const scoreDiff = toNumber(b.scoreIA) - toNumber(a.scoreIA);
  if (scoreDiff !== 0) return scoreDiff;

  const confianceDiff = toNumber(b.confianceIA) - toNumber(a.confianceIA);
  if (confianceDiff !== 0) return confianceDiff;

  const valueDiff = toNumber(b.value) - toNumber(a.value);
  if (valueDiff !== 0) return valueDiff;

  const driverDiff = toNumber(b.driverIndex) - toNumber(a.driverIndex);
  if (driverDiff !== 0) return driverDiff;

  return toNumber(a.numero) - toNumber(b.numero);
}

export function useCourseAnalysis(data: CourseData | null | undefined): CourseAnalysisResult {
  const rawParticipants = Array.isArray(data?.participants) ? data!.participants : [];

  const participants = rawParticipants.map((participant, index) =>
    normaliseParticipant(participant, index)
  );

  const sortedParticipants = [...participants]
    .sort(compareParticipants)
    .map((participant, index) => ({
      ...participant,
      rankIA: index + 1,
    }));

  const top3IA = sortedParticipants.slice(0, 3);

  const valueBets = sortedParticipants.filter(
    (participant) => toNumber(participant.value, 0) > 0
  );

  const topValue =
    valueBets.length > 0
      ? [...valueBets].sort(
          (a, b) => toNumber(b.value, 0) - toNumber(a.value, 0)
        )[0]
      : null;

  return {
    sortedParticipants,
    top3IA,
    valueBets,
    topValue,
  };
}
