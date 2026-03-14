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
  probabilitePMU?: number;
  gains?: number;
  texteEcartLimite?: string;
  couleurEcartLimite?: string;
};

export type CourseData = {
  reunion: string;
  course: string;
  hippodrome?: string;
  distance?: string | number;
  discipline?: string;
  participants?: Participant[];
};
