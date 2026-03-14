import { API_BASE } from "../constants/courseApiBase";

export type Participant = {
  numero: number;
  nom: string;
  musique?: string;
  ferrure?: string;
  driver?: string;
  entraineur?: string;
  corde?: string;
  gains?: number;
  age?: number;
  sexe?: string;
  cotePMU?: number;
  probabiliteIA?: number;
  scoreIA?: number;
  confianceIA?: number;
  value?: number;
  badges?: string[];
  analyseIA?: string;
  retardGains?: number;
  driverIndex?: number;
  trainerIndex?: number;
  rankIA?: number;
  casaque?: string;
};

export type CourseData = {
  reunion: string;
  course: string;
  hippodrome?: string;
  nomCourse?: string;
  heure?: string;
  distance?: string | number;
  piste?: string;
  corde?: string;
  allocation?: number;
  meteo?: string;
  participants: Participant[];
};

export async function fetchCourse(
  reunion: string,
  course: string
): Promise<CourseData> {
  if (!API_BASE) {
    throw new Error("API_BASE manquant");
  }

  const res = await fetch(`${API_BASE}/api/course/${reunion}/${course}`, {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  });

  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`);
  }

  const json = await res.json();
  const data = json?.data ?? json;

  if (!data) {
    throw new Error("Réponse vide");
  }

  return data as CourseData;
}

export { API_BASE };
