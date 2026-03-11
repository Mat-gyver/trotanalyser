export type Participant = {
  numero: number | string;
  nom: string;
  driver?: string;
  entraineur?: string;
  ferrure?: string;
  musique?: string;
  analyseIA?: string;
  scoreIA?: number;
  probabiliteIA?: number;
  confianceIA?: number;
  cotePMU?: number;
  coteIA?: number;
  value?: number;
  driverIndex?: number;
  trainerIndex?: number;
  retardGains?: number;
  rankIA?: number;
  badges?: string[];
  casaque?: string;
};

export type CourseData = {
  reunion?: string;
  course?: string;
  hippodrome?: string;
  distance?: number | string;
  partants?: number;
  meteo?: string;
  temperature?: number | string;
  vent?: number | string;
  souplesse?: string | number;
  participants?: Participant[];
};
