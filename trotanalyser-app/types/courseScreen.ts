export type Participant = {
  numero: number | string
  nom: string

  driver?: string
  entraineur?: string
  ferrure?: string
  musique?: string
  analyseIA?: string

  scoreIA: number
  probabiliteIA?: number
  probabilitePMU?: number
  confianceIA?: number

  cotePMU?: number
  coteIA?: number
  value?: number

  driverIndex?: number
  trainerIndex?: number
  retardGains?: number
  regulariteIndex?: number

  rankIA?: number
  indicePari?: number

  badges?: string[]

  casaque?: string

  dataTurfPro?: string
}

export type CourseData = {
  reunion?: string
  course?: string
  numero?: number | string

  hippodrome?: string
  distance?: number | string
  partants?: number

  meteo?: string
  temperature?: number | string
  vent?: number | string
  souplesse?: string | number

  participants?: Participant[]
}
